-- LSP config in new style (Neovim 0.11+)
local cmp = require("cmp")

-- Configure diagnostics & UI
vim.opt.signcolumn = "yes"
local signs = { Error = "⚠", Warn = "𝕨", Hint = "💡", Info = "" }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Floating window border
local border = {
    { "╔", "FloatBorder" },
    { "═", "FloatBorder" },
    { "╗", "FloatBorder" },
    { "║", "FloatBorder" },
    { "╝", "FloatBorder" },
    { "═", "FloatBorder" },
    { "╚", "FloatBorder" },
    { "║", "FloatBorder" },
}

local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or border
    return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- Setup cmp
cmp.setup({
    sources = {
        { name = "nvim_lsp" },
    },
    snippet = {
        expand = function(args)
            vim.snippet.expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-y>"] = cmp.mapping.confirm({ select = true }),
        ["<C-Space>"] = cmp.mapping.complete(),
    }),
})

-- Global LSP settings
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Keybindings for LSP attach
vim.api.nvim_create_autocmd("LspAttach", {
    desc = "LSP actions",
    callback = function(event)
        local opts = { buffer = event.buf }
        vim.keymap.set('n', 'K', function()
            vim.lsp.buf.hover { border = "single", max_height = 25, max_width = 120 }
        end, { desc = "Hover documentation" })
        vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
        vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
        vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
        vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
        vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
        vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
        vim.keymap.set("n", "<leader>vrn", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
        vim.keymap.set("n", "<leader>vws", "<cmd>lua vim.lsp.buf.workspace_symbol()<cr>", opts)
        vim.keymap.set("n", "<leader>vd", "<cmd>lua vim.diagnostic.open_float()<cr>", opts)
        vim.keymap.set({ "n", "x" }, "<leader>vrf", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
        vim.keymap.set("n", "<leader>vca", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
        vim.keymap.set("i", "<C-h>", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
        vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open diagnostic float" })
        vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Show diagnostics in location list" })
    end,
})

-- Setup Mason
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = {
        "lua_ls", "eslint", "gopls", "tailwindcss", "ts_ls", "jdtls", "sqlls", "clangd"
    },
})

-- Utility: Find root dir
local function root_pattern(...)
    local patterns = { ... }
    return function(fname)
        return vim.fs.dirname(vim.fs.find(patterns, { path = fname, upward = true })[1])
    end
end

-- Start LSP servers manually
local function start_server(name, config)
    vim.lsp.start(vim.tbl_deep_extend("force", {
        name = name,
        capabilities = capabilities,
        on_attach = function(client, bufnr)
            -- handle attach logic here if needed
        end,
    }, config))
end

-- Server-specific configs
start_server("lua_ls", {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_dir = root_pattern(".git", ".luarc.json", "init.lua"),
    settings = {
        Lua = {
            runtime = { version = "LuaJIT", path = vim.split(package.path, ";") },
            diagnostics = { globals = { "vim" } },
            workspace = { library = vim.api.nvim_get_runtime_file("", true) },
        },
    },
})

start_server("eslint", {
    cmd = { "vscode-eslint-language-server", "--stdio" },
    filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    root_dir = root_pattern(".git", "package.json"),
})

start_server("gopls", {
    cmd = { "gopls" },
    filetypes = { "go", "gomod" },
    root_dir = root_pattern("go.work", "go.mod", ".git"),
})

start_server("ts_ls", {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = { "typescript", "typescriptreact" },
    root_dir = root_pattern("tsconfig.json", "package.json", ".git"),
})

start_server("jdtls", {
    cmd = { "jdtls" },
    filetypes = { "java" },
    root_dir = root_pattern("pom.xml", "build.gradle", ".git"),
})

start_server("sqlls", {
    cmd = { "sql-language-server" },
    filetypes = { "sql" },
    root_dir = root_pattern(".git"),
})

start_server("clangd", {
    cmd = {
        "clangd",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--cxx=clang++",
        "--std=c++17"
    },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
    root_dir = root_pattern("compile_commands.json", "compile_flags.txt", ".git", "CMakeLists.txt"),
})

start_server("tailwindcss", {
    cmd = { "tailwindcss-language-server", "--stdio" },
    filetypes = { "html", "javascript", "javascriptreact", "typescript", "typescriptreact" },
    root_dir = root_pattern("tailwind.config.js", "tailwind.config.ts", "package.json", ".git"),
})

start_server("buf_ls", {
    cmd = { "bufls", "serve" },
    filetypes = { "proto" },
    root_dir = root_pattern("buf.yaml", ".git"),
})

start_server("asm_lsp", {
    cmd = { "asm-lsp" },
    filetypes = { "asm", "arm" },
    root_dir = root_pattern(".git"),
    settings = {
        asm = {
            dialect = "arm",
            assembler = "gcc",
        },
    },
})

start_server("racket_langserver", {
    cmd = { "racket", "-l", "racket-langserver" },
    filetypes = { "racket", "scheme" },
    root_dir = root_pattern(".git", "info.rkt"),
})

-- Rust setup via rustaceanvim
vim.g.rustaceanvim = {
    tools = {
        inlay_hints = {
            auto = true,
            only_current_line = false,
            show_parameter_hints = true,
            parameter_hints_prefix = "<- ",
            other_hints_prefix = "=> ",
            highlight = "Comment",
        },
    },
    server = {
        on_attach = function(client, bufnr)
            -- reuse general keybindings
        end,
        capabilities = capabilities,
        settings = {
            ["rust-analyzer"] = {
                cargo = { allFeatures = true },
            },
        },
    },
    dap = {},
}
