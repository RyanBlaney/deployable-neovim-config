-- modules/cursor_sync.lua
local M = {}
local active_clients = {}
local heartbeat_timer = nil

-- Function to safely send a message over WebSocket
local function safe_send(ws, data)
    -- Check if the connection is still alive
    if not ws then
        return false
    end

    local success, err = pcall(function()
        ws:send(data)
    end)

    if not success then
        print("error sending data")
        return false
        -- Connection is likely dead, remove from active clients
        -- for i, client in ipairs(active_clients) do
        --  if client == ws then
        --    table.remove(active_clients, i)
        --  print("Removed dead WebSocket client")
        -- break
        -- end
        -- end
        -- return false
    end

    return true
end

-- Function to handle cursor movements from client
local function handle_cursor_move(data)
    vim.schedule(function()
        local ok, position = pcall(vim.json.decode, data)
        if ok and position then
            vim.api.nvim_win_set_cursor(0, position)
        else
            print("Invalid cursor data:", data)
        end
    end)
end

-- Send cursor position to connected clients
function M.send_cursor_position()
    -- Get cursor position
    local position = vim.api.nvim_win_get_cursor(0)
    print("Cursor position:", vim.inspect(position))

    -- Create message
    local data = vim.json.encode({
        type = "cursor_move",
        data = position,
        timestamp = os.time(),
    })
    print("Sending data:", data)

    -- Send to all active clients
    local clients_to_remove = {}
    for i, ws in ipairs(active_clients) do
        print("Sending to client", i)
        if not safe_send(ws, data) then
            print("Failed to send to client", i)
            table.insert(clients_to_remove, i)
        else
            print("Successfully sent to client", i)
        end
    end
    -- Remove dead clients
    for i = #clients_to_remove, 1, -1 do
        print("Removing dead client at index", clients_to_remove[i])
        table.remove(active_clients, clients_to_remove[i])
    end
end

-- Setup cursor tracking for a new WebSocket client
function M.setup(ws)
    -- Add to active clients if not already there
    local found = false
    for _, client in ipairs(active_clients) do
        if client == ws then
            found = true
            break
        end
    end

    if not found then
        table.insert(active_clients, ws)
    end

    -- Handle message from client
    ws.on_message = function(message)
        local success, decoded = pcall(vim.json.decode, message)
        if success and decoded then
            if decoded.action == "ping" then
                -- Respond to ping with pong
                safe_send(
                    ws,
                    vim.json.encode({
                        action = "pong",
                        timestamp = os.time(),
                    })
                )
            elseif decoded.action == "cursor_moved" then
                handle_cursor_move(decoded.data)
            end
        else
            print("Failed to decode message:", message)
        end
    end

    -- Create autocommand for cursor movements if not already set
    if #active_clients == 1 then
        vim.api.nvim_create_autocmd("CursorMoved", {
            callback = function()
                M.send_cursor_position()
            end,
            pattern = "*",
        })
    end

    -- Send initial cursor position
    M.send_cursor_position()
end

-- function to initiate the heartbeat health check
function M.start_heartbeat()
    if heartbeat_timer then
        heartbeat_timer:stop()
    end

    heartbeat_timer = vim.loop.new_timer()
    heartbeat_timer:start(
        1000,
        10000,
        vim.schedule_wrap(function()
            -- Use active_clients from this module, not active_connections
            for _, client in ipairs(active_clients) do
                pcall(function()
                    client:send(vim.json.encode({
                        type = "heartbeat",
                        timestamp = os.time(),
                    }))
                end)
            end
        end)
    )
end

function M.stop_heartbeat()
    if heartbeat_timer then
        heartbeat_timer:stop()
        heartbeat_timer = nil
    end
end

return M
