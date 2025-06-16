-- Set tab width
vim.opt.tabstop = 4      -- Number of spaces tabs count for
vim.opt.softtabstop = 4  -- Number of spaces tabs count for
vim.opt.shiftwidth = 4   -- Number of spaces to use for each step of (auto)indent
vim.opt.expandtab = true -- Use spaces instead of tabs

vim.opt.smartindent = true

vim.opt.wrap = false

-- Backups handled by undotree
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.g.mapleader = " "

-- Enable relative line numbers
vim.opt.number = true         -- Enable absolute line number on the current line
vim.opt.relativenumber = true -- Enable relative line numbers on all other lines

vim.opt.conceallevel = 1

vim.g.mkdp_browser = "brave"

-- Handle `-32802` errors from rust-analyzer gracefully
for _, method in ipairs({ "textDocument/diagnostic", "workspace/diagnostic" }) do
    local default_diagnostic_handler = vim.lsp.handlers[method]
    vim.lsp.handlers[method] = function(err, result, context, config)
        if err ~= nil and err.code == -32802 then
            return -- Suppress the error
        end
        return default_diagnostic_handler(err, result, context, config)
    end
end
