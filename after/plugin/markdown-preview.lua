-- Basic markdown-preview.nvim settings
--[[ vim.g.mkdp_refresh_slow = 0
vim.g.mkdp_auto_close = 0
vim.g.mkdp_page_title = "${name}"

-- Important: Disable image caching to ensure images refresh
vim.g.mkdp_preview_options = {
    disable_sync_scroll = 0,
    sync_scroll_type = "middle",
    disable_filename = 0,
    disable_image_cache = 1, -- This is the key setting
} ]]
