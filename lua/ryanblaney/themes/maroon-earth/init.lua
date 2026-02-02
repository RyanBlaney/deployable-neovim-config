-- ~/.config/nvim/lua/ryanblaney/themes/maroon-earth/init.lua
local M = {}

local colors = {
    base      = "#2b1e1e",
    mantle    = "#3c2a2a",
    crust     = "#1f1515",
    text      = "#e0cfcf",
    subtext0  = "#c9b8b8",
    overlay2  = "#a88787",
    overlay1  = "#8a6b6b",
    overlay0  = "#745959",
    surface2  = "#624c4c",
    surface1  = "#463434",
    surface0  = "#5c4545",
    rosewater = "#f2d5cf",
    flamingo  = "#eebebe",
    red       = "#ec7072",
    maroon    = "#9b4c4c",
    peach     = "#d9a38a",
    yellow    = "#e5c890",
    green     = "#a6d189",
    teal      = "#81c8be",
    sky       = "#99d1db",
    blue      = "#8caaee",
    lavender  = "#babbf1",
}

function M.setup()
    -- Clear existing highlights
    vim.cmd('highlight clear')
    if vim.fn.exists('syntax_on') then
        vim.cmd('syntax reset')
    end
    vim.g.colors_name = 'maroon-earth'

    -- Define highlights
    local highlights = {
        -- Editor UI
        Normal = { fg = colors.text, bg = colors.base },
        LineNr = { fg = colors.overlay1, bg = colors.crust },
        CursorLine = { bg = colors.mantle },
        CursorLineNr = { fg = colors.yellow, bg = colors.crust },
        VertSplit = { fg = colors.overlay0, bg = colors.crust },
        StatusLine = { fg = colors.text, bg = colors.surface0 },
        StatusLineNC = { fg = colors.overlay1, bg = colors.surface1 },
        SignColumn = { bg = colors.base },

        -- File explorer (netrw)
        Directory = { fg = colors.yellow, bg = colors.base }, -- Yellow directories
        netrwSymLink = { fg = colors.red, bg = colors.base }, -- Red symlinks
        netrwExe = { fg = colors.green, bg = colors.base },   -- Green executables
        netrwDir = { fg = colors.yellow, bg = colors.base },  -- Yellow directories (alternative)
        netrwFile = { fg = colors.text, bg = colors.base },   -- Normal text color for files

        -- Syntax
        Comment = { fg = colors.overlay1 },
        Constant = { fg = colors.peach },
        String = { fg = colors.green },
        Character = { fg = colors.teal },
        Number = { fg = colors.peach },
        Boolean = { fg = colors.mauve },
        Float = { fg = colors.peach },

        Identifier = { fg = colors.text },
        Function = { fg = colors.blue },
        Statement = { fg = colors.maroon },
        Conditional = { fg = colors.maroon },
        Repeat = { fg = colors.maroon },
        Label = { fg = colors.yellow },
        Operator = { fg = colors.sky },
        Keyword = { fg = colors.maroon },
        Exception = { fg = colors.red },

        PreProc = { fg = colors.flamingo },
        Include = { fg = colors.maroon },
        Define = { fg = colors.maroon },
        Macro = { fg = colors.flamingo },
        PreCondit = { fg = colors.yellow },

        Type = { fg = colors.yellow },
        StorageClass = { fg = colors.yellow },
        Structure = { fg = colors.yellow },
        Typedef = { fg = colors.yellow },

        Special = { fg = colors.pink },
        SpecialChar = { fg = colors.pink },
        Tag = { fg = colors.blue },
        Delimiter = { fg = colors.text },
        SpecialComment = { fg = colors.overlay2 },
        Debug = { fg = colors.red },

        -- UI Elements
        Error = { fg = colors.red, bg = colors.crust },
        Todo = { fg = colors.yellow, bg = colors.base },
        Search = { fg = colors.crust, bg = colors.yellow },
        IncSearch = { fg = colors.crust, bg = colors.peach },
        MatchParen = { bg = colors.surface0 },

        -- Diff
        DiffAdd = { fg = colors.green, bg = colors.base },
        DiffChange = { fg = colors.yellow, bg = colors.base },
        DiffDelete = { fg = colors.red, bg = colors.base },
        DiffText = { fg = colors.blue, bg = colors.base },
    }

    -- Apply highlights
    for group, color in pairs(highlights) do
        local style = color.style and "gui=" .. color.style or "gui=NONE"
        local fg = color.fg and "guifg=" .. color.fg or "guifg=NONE"
        local bg = color.bg and "guibg=" .. color.bg or "guibg=NONE"
        vim.cmd(string.format("highlight %s %s %s %s", group, fg, bg, style))
    end
end

return M
