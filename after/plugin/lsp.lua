local lspconfig = require("lspconfig")
local cmp = require("cmp")
local lsp_defaults = lspconfig.util.default_config

-- Reserve a space in the gutter for diagnostics and signs
vim.opt.signcolumn = "yes"

-- Add cmp_nvim_lsp capabilities settings to lspconfig
lsp_defaults.capabilities =
    vim.tbl_deep_extend("force", lsp_defaults.capabilities, require("cmp_nvim_lsp").default_capabilities())

-- Minimal nvim-cmp configuration
cmp.setup({
    sources = {
        { name = "nvim_lsp" },
    },
    snippet = {
        expand = function(args)
            vim.snippet.expand(args.body) -- Requires Neovim v0.10
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-y>"] = cmp.mapping.confirm({ select = true }),
        ["<C-Space>"] = cmp.mapping.complete(),
    }),
})

local signs = { Error = "⚠", Warn = "𝕨", Hint = "💡", Info = "" }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Set up LSP keybindings only when an LSP server is active
vim.api.nvim_create_autocmd("LspAttach", {
    desc = "LSP actions",
    callback = function(event)
        local opts = { buffer = event.buf }

        vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
        vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
        vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
        vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
        vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
        vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
        vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
        vim.keymap.set("n", "<leader>vrn>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
        vim.keymap.set("n", "<leader>vws>", "<cmd>lua vim.lsp.buf.workspace_symbol()<cr>", opts)
        vim.keymap.set("n", "<leader>vd>", "<cmd>lua vim.diagnostic.open_float()<cr>", opts)
        vim.keymap.set({ "n", "x" }, "<leader>vrf", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
        vim.keymap.set("n", "<leader>vca", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
        vim.keymap.set("i", "<C-h>", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
        vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open diagnostic float" })
        vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Show diagnostics in location list" })
    end,
})

require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "lua_ls", "eslint", "gopls", "tailwindcss", "ts_ls", "jdtls", "sqlls" },
})

-- Ensure LSP servers are installed and set up
local servers = { "eslint", "lua_ls", "gopls", "ts_ls", "jdtls", "sqlls" }
for _, server in ipairs(servers) do
    lspconfig[server].setup({})
end

lspconfig.clangd.setup({
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
})

lspconfig.tailwindcss.setup({
    filetypes = { "html", "javascript", "javascriptreact", "typescript", "typescriptreact" },
})

lspconfig.buf_ls.setup({
    cmd = { "bufls", "serve" },
    filetypes = { "proto" },
    root_dir = lspconfig.util.root_pattern("buf.yaml", ".git"), -- Ensure `buf.yaml` is in your project root
})

lspconfig.asm_lsp.setup({
    cmd = { "asm-lsp" },
    filetypes = { "asm", "arm" },
    root_dir = function(fname)
        return vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
    end,
    settings = {
        asm = {
            dialect = "arm",
            assembler = "gcc",
        },
    },
})

vim.g.rustaceanvim = {
    tools = {
        inlay_hints = {
            -- automatically set inlay hints (type hints)
            -- default: true
            auto = true,

            -- Only show inlay hints for the current line
            only_current_line = false,

            -- whether to show parameter hints with the inlay hints or not
            -- default: true
            show_parameter_hints = true,

            -- prefix for parameter hints
            -- default: "<-"
            parameter_hints_prefix = "<- ",

            -- prefix for all the other hints (type, chaining)
            -- default: "=>"
            other_hints_prefix = "=> ",

            -- whether to align to the length of the longest line in the file
            max_len_align = false,

            -- padding from the left if max_len_align is true
            max_len_align_padding = 1,

            -- whether to align to the extreme right or not
            right_align = false,

            -- padding from the right if right_align is true
            right_align_padding = 7,

            -- The color of the hints
            highlight = "Comment",
        },
    },
    server = {
        on_attach = lsp_defaults.on_attach,
        capabilities = lsp_defaults.capabilities,
        settings = {
            ["rust-analyzer"] = {
                cargo = {
                    allFeatures = true,
                },
            },
        },
    },
    dap = {},
}
