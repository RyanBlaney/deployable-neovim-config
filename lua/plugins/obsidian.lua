return {
    "epwalsh/obsidian.nvim",
    version = "3.9.0",
    lazy = true,
    ft = {"markdown"},
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    opts = {
        workspaces = {
            { name = "personal", path = "~/notes/personal" },
            { name = "school", path = "~/notes/school" },
            { name = "work", path = "~/notes/work" },
        },
        daily_notes = {
            folder = "dailies",
            date_format = "%Y-%m-%d",
            alias_format = "%B %-d, %Y",
        },
        completion = {
            nvim_cmp = true,
            min_chars = 2,
        },
        picker = {
            name = "telescope.nvim",
            mappings = {
                new = "<C-x>",
                insert_link = "<C-l>",
            },
        },
        ui = {
            enable = true,
            checkboxes = {
                [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
                ["x"] = { char = "", hl_group = "ObsidianDone" },
            },
        },
    }
}

