local none_ls = require("null-ls")

vim.g.autoformat_enabled = true

none_ls.setup({
    sources = {
        -- none_ls.builtins.formatting.gofumpt.with({
        -- extra_args = { "--extra" },
        -- }),
        none_ls.builtins.formatting.gofmt,
        none_ls.builtins.formatting.goimports,
        none_ls.builtins.formatting.clang_format,
        -- none_ls.builtins.formatting.golines.with({
        -- extra_args = { "--max-len=80", "--base-formatter=gofumpt" },
        -- }),
        none_ls.builtins.formatting.stylua,
        none_ls.builtins.formatting.prettier,
    },
    on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = bufnr,
                callback = function()
                    if vim.g.autoformat_enabled then
                        vim.lsp.buf.format({ bufnr = bufnr })
                    end
                end,
            })
        end
    end,
})

vim.keymap.set("n", "<leader>af", function()
    vim.g.autoformat_enabled = not vim.g.autoformat_enabled
    print("Autoformatting " .. (vim.g.autoformat_enabled and "enabled" or "disabled"))
end, { noremap = true, silent = true })

return {}
