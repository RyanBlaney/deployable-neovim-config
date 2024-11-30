return {
    -- Treesitter configuration
    {
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        config = function()
            require("plugins.treesitter")
        end,
    },

    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "Mofiqul/dracula.nvim",
        },
        config = function()
            require("plugins.lualine")
        end,
    },

    -- Telescope and extensions
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = { "nvim-lua/plenary.nvim" },
    },
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

    -- Kanagawa colorscheme
    {
        "sho-87/kanagawa-paper.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
    },

    -- Additional plugins
    { "theprimeagen/harpoon" },
    { "mbbill/undotree" },
    { "tpope/vim-fugitive" },

    -- LSP and Autocompletion setup with lsp-zero
    {
        "VonHeikemen/lsp-zero.nvim",
        dependencies = {
            -- LSP Support
            { "neovim/nvim-lspconfig" },
            { "williamboman/mason.nvim" },
            { "williamboman/mason-lspconfig.nvim" },

            -- Autocompletion
            {
                "hrsh7th/nvim-cmp",
                event = "InsertEnter",
                dependencies = {
                    {
                        "L3MON4D3/LuaSnip",
                        version = "v2.*",
                        build = "make install_jsregexp",
                        dependencies = {
                            { "rafamadriz/friendly-snippets" },
                            { "honza/vim-snippets" },
                        },
                        config = function()
                            require("luasnip.loaders.from_vscode").lazy_load()
                            require("luasnip.loaders.from_vscode").lazy_load({
                                paths = {
                                    "~/.local/share/nvim/lazy/vim-snippets",
                                },
                            })
                        end,
                    },
                },
            },
            { "hrsh7th/cmp-buffer" },
            { "hrsh7th/cmp-path" },
            { "saadparwaiz1/cmp_luasnip" },
            { "hrsh7th/cmp-nvim-lsp" },
            { "hrsh7th/cmp-nvim-lua" },
        },
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({
                check_ts = true, -- Enable treesitter integration for smarter pairing
            })

            -- Integrate nvim-autopairs with nvim-cmp
            local cmp = require("cmp")
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")
            cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end,
    },
    {
        "goolord/alpha-nvim",
        config = function()
            local alpha = require("alpha")
            local dashboard = require("alpha.themes.dashboard")

            -- Define the buttons with new keymaps
            dashboard.section.buttons.val = {
                dashboard.button("e", "  New file", "<cmd>ene <CR>"),
                dashboard.button("SPC p v", "󰈞  File explorer", "<cmd>Ex<CR>"),
                dashboard.button(
                    "SPC p f",
                    "󰈞  Find file",
                    "<cmd>lua require('telescope.builtin').find_files()<CR>"
                ),
                dashboard.button(
                    "SPC p s",
                    "󰊄  Find regex string",
                    "<cmd>lua require('telescope.builtin').grep_string({ search = vim.fn.input('Grep > ') })<CR>"
                ),
                dashboard.button("SPC u", "  Open UndoTree", "<cmd>UndotreeToggle<CR>"),
                dashboard.button("SPC p w", "󰈬  Find word", "<cmd>lua require('telescope.builtin').live_grep()<CR>"),
                dashboard.button(
                    "CTRL + e",
                    "  Open Harpoon Menu",
                    "<cmd>lua require'harpoon.ui'.toggle_quick_menu()<CR>"
                ),
                dashboard.button("SPC p m", "  Open last buffer", "<cmd>b#<CR>"),
            }

            -- Update the header, buttons, and footer
            alpha.setup(dashboard.config)
        end,
    },

    {
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
            require("plugins.null-ls")
        end,
    },

    {
        "numToStr/Comment.nvim",
        opts = {
            toggler = {
                line = "<leader>/", -- Toggle comment on the current line
            },
            opleader = {
                block = "<leader>/", -- Toggle comment in visual mode
            },
        },
    },
}
