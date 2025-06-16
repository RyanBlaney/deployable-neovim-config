local function recursive_add_to_paths(base_dir, namespace)
    local handle = vim.loop.fs_scandir(base_dir)
    while handle do
        local name, type = vim.loop.fs_scandir_next(handle)
        if not name then
            break
        end
        local full_path = base_dir .. "/" .. name

        if type == "directory" then
            -- Add namespace to package.path
            package.path = package.path .. ";" .. full_path .. "/?.lua;" .. full_path .. "/?/init.lua"
            vim.opt.runtimepath:append(full_path)

            -- Recursively process the subdirectory
            recursive_add_to_paths(full_path, namespace and (namespace .. "." .. name) or name)
        end
    end
end

-- Add 'my-plugins' recursively to package.path and runtimepath
local my_plugins_path = vim.fn.stdpath("config") .. "/lua/ryanblaney/my-plugins"
recursive_add_to_paths(my_plugins_path)

-- Automatically load all plugins in 'my-plugins'
local function load_plugins()
    local my_plugins_path = vim.fn.stdpath("config") .. "/lua/ryanblaney/my-plugins"
    local handle = vim.loop.fs_scandir(my_plugins_path)
    while handle do
        local name, type = vim.loop.fs_scandir_next(handle)
        if not name then
            break
        end
        if type == "directory" then
            -- Require the plugin's init.lua if it exists
            local plugin_init = "ryanblaney.my-plugins." .. name .. ".init"
            local ok, err = pcall(require, plugin_init)
            if not ok then
                print("Error loading plugin:", name, err)
            end
        end
    end
end

load_plugins()

-- require("ryanblaney.my-plugins.google_docs_lsp")
