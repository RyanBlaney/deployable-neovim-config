local copas = require("copas")
local websocket = require("websocket").server.copas
local timer = vim.loop.new_timer()
local ws_server

-- Define the WebSocket server setup
local function start_websocket_server()
    ws_server = websocket.listen({
        port = 9090,
        protocols = {
            ["google-docs-sync"] = function(ws)
                print("WebSocket client connected")
                pcall(function()
                    while true do
                        local message, err = ws:receive()
                        if message then
                            print("Received from client:", message)
                            ws:send("Echo: " .. message)
                        else
                            print("Client disconnected:", err)
                            ws:close()
                            return
                        end
                    end
                end, function(err)
                    print("Error in WebSocket handler:", err)
                    ws:close()
                end)
            end,
        },
    })

    if ws_server then
        print("WebSocket server started on ws://127.0.0.1:9090 with protocol 'google-docs-sync'")
    else
        print("Failed to start WebSocket server.")
    end

    -- Non-blocking Copas loop
    timer:start(
        0,
        100,
        vim.schedule_wrap(function()
            local success, err = pcall(copas.step)
            if not success then
                print("Error in copas loop:", err)
            end
        end)
    )
end

-- Function to stop the WebSocket server
local function stop_websocket_server()
    if ws_server then
        ws_server:close()
        ws_server = nil
        timer:stop() -- Stop the timer when the server stops
        print("WebSocket server stopped")
    end
end

-- Command to start syncing with Google Docs
vim.api.nvim_create_user_command("SyncWithGoogleDocs", function()
    if not ws_server then
        start_websocket_server()

        -- Automatically stop the server when the buffer is deleted
        vim.api.nvim_create_autocmd("BufDelete", {
            buffer = vim.api.nvim_get_current_buf(),
            callback = function()
                stop_websocket_server()
            end,
        })
    else
        print("WebSocket server already running")
    end
end, {})

-- Optional command to manually stop the server
vim.api.nvim_create_user_command("StopSyncWithGoogleDocs", function()
    stop_websocket_server()
end, {})
