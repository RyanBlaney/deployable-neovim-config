local copas = require("copas")
local websocket = require("websocket").server.copas
local timer = vim.loop.new_timer()
local modules = require("modules")
local ws_server
local active_connections = {}

-- Function to handle messages from clients
local function handle_message(ws, message)
    local success, decoded = pcall(vim.json.decode, message)
    if success and decoded then
        -- Handle ping messages for heartbeat
        if decoded.type == "ping" then
            ws:send(vim.json.encode({
                type = "pong",
                timestamp = os.time(),
            }))
            return
        end

        -- Handle other message types here
        print("Received message type: " .. decoded.type)

        -- Forward to appropriate module
        if decoded.type == "cursor_move" then
            -- Handle cursor messages
            if decoded.data then
                io.write(string.format("cursor moved %s\n", decoded.data))
                -- Module will handle cursor movement
            end
        elseif decoded.action == "text_change" then
            print("text_change")
            -- Handle text messages
            -- ...
        end
    else
        print("Received raw message:", message)
    end
end

-- Define the WebSocket server setup
local function start_websocket_server()
    modules.cursor_sync.start_heartbeat()

    local watchdog_timer = vim.loop.new_timer()
    watchdog_timer:start(
        10000,
        10000,
        vim.schedule_wrap(function()
            if ws_server == nil and #vim.api.nvim_list_bufs() > 0 then
                -- Only restart if we still have buffers open
                print("WebSocket server is down, attempting to restart")
                start_websocket_server()
            end
        end)
    )

    ws_server = websocket.listen({
        port = 8080,
        default = function(ws) -- Fallback handler for any connection
            print("WebSocket client connected")

            -- Add to active connections
            table.insert(active_connections, ws)

            -- Set up cursor sync for this connection
            modules.cursor_sync.setup(ws)

            -- Message handling loop
            pcall(function()
                while true do
                    local message, err = ws:receive()
                    if message then
                        local success, handle_err = pcall(handle_message, ws, message)
                        if not success then
                            print("Error handling message:", handle_err)
                        end
                    else
                        print("Client disconnected:", err)

                        -- Remove from active connections
                        for i, conn in ipairs(active_connections) do
                            if conn == ws then
                                table.remove(active_connections, i)
                                break
                            end
                        end

                        ws:close()
                        return
                    end
                end
            end, function(err)
                print("Error in WebSocket handler:", err)

                -- Clean up this connection
                for i, conn in ipairs(active_connections) do
                    if conn == ws then
                        table.remove(active_connections, i)
                        break
                    end
                end

                pcall(function()
                    ws:close()
                end)
            end)
        end,
    })

    if ws_server then
        print("WebSocket server started on ws://127.0.0.1:8080")
    else
        print("Failed to start WebSocket server.")
        return false
    end

    -- Non-blocking Copas loop with better error handling
    timer:start(
        0,
        100,
        vim.schedule_wrap(function()
            local success, err = pcall(copas.step)
            if not success then
                print("Error in copas loop:", err)
                -- We should restart the copas step on the next iteration
                -- rather than letting it completely fail
            end
        end)
    )

    return true
end

-- Function to safely close all connections
local function close_all_connections()
    for _, ws in ipairs(active_connections) do
        pcall(function()
            ws:close()
        end)
    end
    active_connections = {}
end

-- Function to stop the WebSocket server
local function stop_websocket_server()
    if ws_server then
        modules.cursor_sync.stop_heartbeat()

        -- Close all active connections
        close_all_connections()

        -- Close the server
        ws_server:close()
        ws_server = nil

        -- Stop the timer
        timer:stop()

        print("WebSocket server stopped")
    end
end

-- Command to start syncing with Google Docs
vim.api.nvim_create_user_command("SyncWithGoogleDocs", function()
    if not ws_server then
        if start_websocket_server() then
            -- Automatically stop the server when the buffer is deleted
            vim.api.nvim_create_autocmd("BufDelete", {
                buffer = vim.api.nvim_get_current_buf(),
                callback = function()
                    stop_websocket_server()
                end,
            })

            -- Also add a VimLeave handler just in case
            vim.api.nvim_create_autocmd("VimLeave", {
                callback = function()
                    stop_websocket_server()
                end,
            })
        end
    else
        print("WebSocket server already running")
    end
end, {})

-- Optional command to manually stop the server
vim.api.nvim_create_user_command("StopSyncWithGoogleDocs", function()
    stop_websocket_server()
end, {})

-- Return the module if needed
return {
    start = start_websocket_server,
    stop = stop_websocket_server,
}
