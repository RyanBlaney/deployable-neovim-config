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
        "nvimtools/none-ls.nvim",
        config = function()
            require("plugins.none-ls")
        end,
    },

    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = "cd app && yarn install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
    },

    --[[ {
        "toppair/peek.nvim",
        build = "deno task --quiet build:fast",
        config = function()
            require("peek").setup({
                auto_load = true,
                close_on_bdelete = true,
                syntax = true,
                theme = "dark",
                update_on_change = true,
                app = "webview",
                filetype = { "markdown" },
                throttle_at = 200000,
                throttle_time = "auto",
            })
            vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
            vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
        end,
    }, ]]

    {
        require("plugins/obsidian"),
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

    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("gitsigns").setup({
                signs = {
                    add = { text = "+" },
                    change = { text = "~" },
                    delete = { text = "_" },
                    topdelete = { text = "‾" },
                    changedelete = { text = "~" },
                },
                on_attach = function(bufnr)
                    local gs = package.loaded.gitsigns

                    local function map(mode, l, r, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        vim.keymap.set(mode, l, r, opts)
                    end

                    -- Navigation
                    map("n", "]c", function()
                        if vim.wo.diff then
                            return "]c"
                        end
                        vim.schedule(function()
                            gs.next_hunk()
                        end)
                        return "<Ignore>"
                    end, { expr = true })

                    map("n", "[c", function()
                        if vim.wo.diff then
                            return "[c"
                        end
                        vim.schedule(function()
                            gs.prev_hunk()
                        end)
                        return "<Ignore>"
                    end, { expr = true })

                    -- Actions
                    map("n", "<leader>hs", gs.stage_hunk)
                    map("n", "<leader>hr", gs.reset_hunk)
                    map("v", "<leader>hs", function()
                        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
                    end)
                    map("v", "<leader>hr", function()
                        gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
                    end)
                    map("n", "<leader>hS", gs.stage_buffer)
                    map("n", "<leader>hu", gs.undo_stage_hunk)
                    map("n", "<leader>hR", gs.reset_buffer)
                    map("n", "<leader>hp", gs.preview_hunk)
                    map("n", "<leader>hb", function()
                        gs.blame_line({ full = true })
                    end)
                    map("n", "<leader>tb", gs.toggle_current_line_blame)
                    map("n", "<leader>hd", gs.diffthis)
                    map("n", "<leader>hD", function()
                        gs.diffthis("~")
                    end)
                    map("n", "<leader>td", gs.toggle_deleted)

                    -- Text object
                    map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
                end,
            })
        end,
    },

    {
        "ggandor/leap.nvim",
        dependencies = { "tpope/vim-repeat" },
        enabled = true,
        keys = {
            { "s",  mode = { "n", "x", "o" }, desc = "Leap Forward to" },
            { "S",  mode = { "n", "x", "o" }, desc = "Leap Backward to" },
            { "gs", mode = { "n", "x", "o" }, desc = "Leap from Windows" },
        },
        config = function(_, opts)
            local leap = require("leap")
            for k, v in pairs(opts) do
                leap.opts[k] = v
            end
            leap.add_default_mappings(true)
            vim.keymap.del({ "x", "o" }, "x")
            vim.keymap.del({ "x", "o" }, "X")
        end,
    },

    {
        "MunifTanjim/prettier.nvim",
    },

    {
        "folke/trouble.nvim",
        opts = {}, -- for default options, refer to the configuration section for custom setup.
        cmd = "Trouble",
        keys = {
            {
                "<leader>tx",
                "<cmd>Trouble diagnostics toggle<cr>",
                desc = "Diagnostics (Trouble)",
            },
            {
                "<leader>tX",
                "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                desc = "Buffer Diagnostics (Trouble)",
            },
            {
                "<leader>ts",
                "<cmd>Trouble symbols toggle focus=false<cr>",
                desc = "Symbols (Trouble)",
            },
            {
                "<leader>tl",
                "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
                desc = "LSP Definitions / references / ... (Trouble)",
            },
            {
                "<leader>tL",
                "<cmd>Trouble loclist toggle<cr>",
                desc = "Location List (Trouble)",
            },
            {
                "<leader>tQ",
                "<cmd>Trouble qflist toggle<cr>",
                desc = "Quickfix List (Trouble)",
            },
        },
    },

    {
        "rust-lang/rust.vim",
        ft = "rust",
        init = function()
            vim.g.rustfmt_autosave = 1
        end,
    },
    {
        "mrcjkb/rustaceanvim",
        version = "^5",
        ft = { "rust" },
        lazy = false,
    },

    {
        "saecki/crates.nvim",
        ft = { "rust", "toml" },
        config = function(_, opts)
            local crates = require("crates")
            crates.setup(opts)
            crates.show()
        end,
    },

    {
        "HakonHarnes/img-clip.nvim",
        lazy = true,
        keys = {
            { "<leader>mp", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
        },
    },

    {
        "javiorfo/nvim-soil",

        -- Optional for puml syntax highlighting:
        dependencies = { "javiorfo/nvim-nyctophilia" },

        lazy = true,
        ft = "plantuml",
        opts = {
            -- If you want to change default configurations

            -- This option closes the image viewer and reopen the image generated
            -- When true this offers some kind of online updating (like plantuml web server)
            actions = {
                redraw = false,
            },

            puml_jar = "/usr/share/java/plantuml/plantuml.jar",

            -- If you want to customize the image showed when running this plugin
            image = {
                darkmode = true, -- Enable or disable darkmode
                format = "png",  -- Choose between png or svg

                -- This is a default implementation of using nsxiv to open the resultant image
                -- Edit the string to use your preferred app to open the image (as if it were a command line)
                -- Some examples:
                -- return "feh " .. img
                -- return "xdg-open " .. img
                execute_to_open = function(img)
                    return "nsxiv -b " .. img
                end,
            },
        },
    },

    { "tpope/vim-dadbod" },
    { "kristijanhusak/vim-dadbod-ui" },
}
