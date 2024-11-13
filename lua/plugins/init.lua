return {
	{
		require("plugins.treesitter")
	},
	{
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    {
      "sho-87/kanagawa-paper.nvim",
      lazy = false,
      priority = 1000,
      opts = {}
    },
    {"theprimeagen/harpoon"},
    {"mbbill/undotree",},
    {"tpope/vim-fugitive"},
    {
        "VonHeikemen/lsp-zero.nvim",
        dependencies = {
            -- LSP Support
            {'neovim/nvim-lspconfig'},
            {'williamboman/mason.nvim'},
            {'williamboman/mason-lspconfig.nvim'},

            -- Autocompletion
            {'hrsh7th/nvim-cmp'},
            {'hrsh7th/cmp-buffer'},
            {'hrsh7th/cmp-path'},
            {'saadparwaiz1/cmp_luasnip'},
            {'hrsh7th/cmp-nvim-lsp'},
            {'hrsh7th/cmp-nvim-lua'},

            -- Snippets
            {'L3MON4D3/LuaSnip'},
            {'rafamadriz/friendly-snippets'},
        },
    }
}
