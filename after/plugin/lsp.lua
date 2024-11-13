local lspconfig = require('lspconfig')
local cmp = require('cmp')
local lsp_defaults = lspconfig.util.default_config

-- Reserve a space in the gutter for diagnostics and signs
vim.opt.signcolumn = 'yes'

-- Add cmp_nvim_lsp capabilities settings to lspconfig
lsp_defaults.capabilities = vim.tbl_deep_extend(
  'force',
  lsp_defaults.capabilities,
  require('cmp_nvim_lsp').default_capabilities()
)

-- Minimal nvim-cmp configuration
cmp.setup({
  sources = {
    {name = 'nvim_lsp'},
  },
  snippet = {
    expand = function(args)
      vim.snippet.expand(args.body)  -- Requires Neovim v0.10
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ['<C-Space>'] = cmp.mapping.complete(),
  }),
})

-- Set up LSP keybindings only when an LSP server is active
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local opts = { buffer = event.buf }
    
    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
    vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
    vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
    vim.keymap.set('n', '<leader>vrn>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
    vim.keymap.set('n', '<leader>vws>', '<cmd>lua vim.lsp.buf.workspace_symbol()<cr>', opts)
    vim.keymap.set('n', '<leader>vd>', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
    vim.keymap.set({'n', 'x'}, '<leader>vrf', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
    vim.keymap.set('n', '<leader>vca', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
    vim.keymap.set("i", "<C-h>", '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
  end,
})

require('mason').setup()
            require('mason-lspconfig').setup({
                ensure_installed = { 'lua_ls', 'ts_ls', 'rust_analyzer', 'eslint' }
            })

-- Ensure LSP servers are installed and set up
local servers = { 'ts_ls', 'eslint', 'lua_ls', 'rust_analyzer', 'clangd' }
for _, server in ipairs(servers) do
  lspconfig[server].setup({})
end

