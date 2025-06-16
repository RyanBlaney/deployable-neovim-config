local M = {}

-- Module variables
local job_id = nil
local krita_edit_file = nil -- The file that Krita is directly editing
local original_image_name = nil
local polling_timer = nil
local last_modified_time = 0
local current_index = 1 -- Track current index
local assets_dir = nil

-- Create assets directory if it doesn't exist
local function ensure_assets_dir()
    local dir = vim.fn.getcwd() .. "/assets"
    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.mkdir(dir, "p")
    end
    return dir
end

-- Create a transparent template image
local function create_template(path)
    local cmd = string.format("convert -size 1000x1000 xc:transparent -alpha set -background none %s", path)
    vim.fn.system(cmd)
end

-- Update the reference in the markdown buffer
local function update_markdown_reference(old_index, new_index)
    local current_buffer = vim.api.nvim_get_current_buf()

    -- Construct old and new references
    local old_ref = "%.%/assets%/" .. original_image_name .. old_index .. "%.png"
    local new_ref = "./assets/" .. original_image_name .. new_index .. ".png"

    -- Search for the reference in the buffer
    local lines = vim.api.nvim_buf_get_lines(current_buffer, 0, -1, false)
    for i, line in ipairs(lines) do
        if line:match(old_ref) then
            -- Update the line directly in the buffer
            local new_line = line:gsub(old_ref, new_ref)
            vim.api.nvim_buf_set_lines(current_buffer, i - 1, i, false, { new_line })
            return true
        end
    end

    return false
end

-- Update to final non-indexed reference
local function update_to_final_reference(index)
    local current_buffer = vim.api.nvim_get_current_buf()

    -- Construct old and new references
    local old_ref = "%.%/assets%/" .. original_image_name .. index .. "%.png"
    local new_ref = "./assets/" .. original_image_name .. ".png"

    -- Search for the reference in the buffer
    local lines = vim.api.nvim_buf_get_lines(current_buffer, 0, -1, false)
    for i, line in ipairs(lines) do
        if line:match(old_ref) then
            -- Update the line directly in the buffer
            local new_line = line:gsub(old_ref, new_ref)
            vim.api.nvim_buf_set_lines(current_buffer, i - 1, i, false, { new_line })
            return true
        end
    end

    return false
end

-- Clean up old indexed files, keeping only the last N
local function cleanup_old_files(keep_latest_n)
    -- Only delete if we have more than keep_latest_n files
    if current_index > keep_latest_n then
        -- Delete files older than (current - keep_latest_n)
        local delete_index = current_index - keep_latest_n

        -- Delete the file
        local old_file = assets_dir .. "/" .. original_image_name .. delete_index .. ".png"
        if vim.fn.filereadable(old_file) == 1 then
            vim.fn.delete(old_file)
            print("Deleted old file: " .. old_file)
        end
    end
end

-- Check for changes in the Krita file
local function check_for_changes()
    if krita_edit_file and vim.fn.filereadable(krita_edit_file) == 1 then
        local mod_time = vim.fn.getftime(krita_edit_file)

        -- If the file has changed since we last checked
        if mod_time > last_modified_time then
            print("Detected change in Krita file: " .. krita_edit_file)
            last_modified_time = mod_time

            -- Calculate the next index to use (always incrementing)
            local next_index = current_index + 1
            local next_file = assets_dir .. "/" .. original_image_name .. next_index .. ".png"

            -- Copy the edited file to the next indexed file
            vim.fn.system("cp " .. krita_edit_file .. " " .. next_file)

            -- Update the markdown reference
            local success = update_markdown_reference(current_index, next_index)
            if success then
                -- Update our current index
                current_index = next_index

                -- Clean up old files, keeping latest 2
                cleanup_old_files(2)
            else
                print("Warning: Could not find markdown reference to update")
            end
        end
    end
end

-- Cleanup resources
function M.cleanup()
    if polling_timer then
        polling_timer:stop()
        polling_timer:close()
        polling_timer = nil
    end

    if job_id then
        vim.fn.jobstop(job_id)
        job_id = nil
    end

    -- Make final cleanup - rename the latest indexed file to the clean name
    if krita_edit_file and vim.fn.filereadable(krita_edit_file) == 1 and assets_dir and original_image_name then
        -- Copy the final Krita file to the clean name
        local final_file = assets_dir .. "/" .. original_image_name .. ".png"
        vim.fn.system("cp " .. krita_edit_file .. " " .. final_file)

        -- Update the reference to the clean name
        update_to_final_reference(current_index)

        -- Clean up all indexed files
        for i = 1, current_index do
            local index_file = assets_dir .. "/" .. original_image_name .. i .. ".png"
            if vim.fn.filereadable(index_file) == 1 then
                vim.fn.delete(index_file)
            end
        end
    end

    -- Reset variables
    krita_edit_file = nil
    original_image_name = nil
    last_modified_time = 0
    current_index = 1
    assets_dir = nil

    print("Cleanup complete")
end

-- Start drawing
function M.start_drawing()
    -- Prompt for diagram name
    local diagram_name = vim.fn.input("Enter diagram name: ")
    if diagram_name == "" then
        return
    end

    -- Remember the original name without index
    original_image_name = diagram_name

    -- Setup directories and paths
    assets_dir = ensure_assets_dir()

    -- The file Krita will edit
    krita_edit_file = assets_dir .. "/" .. diagram_name .. ".png"

    -- Create initial indexed file
    local indexed_file = assets_dir .. "/" .. diagram_name .. "1.png"

    -- Create template if main image doesn't exist
    if vim.fn.filereadable(krita_edit_file) == 0 then
        create_template(krita_edit_file)
    end

    -- Create the indexed version
    vim.fn.system("cp " .. krita_edit_file .. " " .. indexed_file)

    -- Record initial modified time
    last_modified_time = vim.fn.getftime(krita_edit_file)

    -- Insert image reference in markdown if it doesn't exist
    local current_buffer = vim.api.nvim_get_current_buf()
    local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
    local img_markdown = "![" .. diagram_name .. "](./assets/" .. diagram_name .. "1.png)"

    local lines = vim.api.nvim_buf_get_lines(current_buffer, 0, -1, false)
    local found = false
    for i, line in ipairs(lines) do
        if line:match("!%[" .. diagram_name .. "%]") then
            found = true
            break
        end
    end

    if not found then
        vim.api.nvim_buf_set_lines(current_buffer, cursor_line - 1, cursor_line - 1, false, { img_markdown })
    end

    -- Start Krita with the file
    job_id = vim.fn.jobstart("krita --nosplash " .. krita_edit_file, {
        detach = true,
        on_exit = function()
            M.cleanup()
        end,
    })

    if job_id <= 0 then
        print("Error: Failed to start Krita")
        return
    end

    -- Start the polling timer for checking changes
    polling_timer = vim.loop.new_timer()
    polling_timer:start(
        500,
        100,
        vim.schedule_wrap(function()
            check_for_changes()
        end)
    )

    -- Setup cleanup autocmd
    vim.cmd([[
    augroup KritaMarkdownDraw
      autocmd!
      autocmd BufUnload <buffer> lua require('ryanblaney.my-plugins.krita-markdown-draw').cleanup()
    augroup END
  ]])

    -- Print debug information
    print("Krita drawing setup complete!")
    print("Editing file: " .. krita_edit_file)
    print("")
    print("In Krita:")
    print("1. Make your changes")
    print("2. Press Ctrl+S to save")
    print("3. The markdown preview will update automatically")
    print("")
    print("When finished, just close Krita")
end

-- Set up the plugin once it's loaded
local function setup()
    -- Register key mappings
    vim.api.nvim_set_keymap(
        "n",
        "<leader>mw",
        "<cmd>lua require('ryanblaney.my-plugins.krita-markdown-draw').start_drawing()<CR>",
        { noremap = true, silent = true }
    )

    -- Create user command if needed
    vim.api.nvim_create_user_command("KritaDraw", function()
        M.start_drawing()
    end, {})
end

-- Run setup
setup()

-- Return the module
return M
