local colors = {
    base     = "#2b1e1e",
    mantle   = "#3c2a2a",
    crust    = "#1f1515",
    text     = "#e0cfcf",
    subtext0 = "#c9b8b8",
    overlay2 = "#a88787",
    overlay1 = "#8a6b6b",
    overlay0 = "#745959",
    surface2 = "#624c4c",
    surface1 = "#463434",
    surface0 = "#5c4545",
    yellow   = "#e5c890",
    red      = "#ec7072",
    green    = "#a6d189", -- Good for Insert
    blue     = "#8caaee", -- Good for Command
    maroon   = "#8a6b6b",
}

return {
    normal = {
        a = { bg = colors.maroon, fg = colors.text, gui = 'bold' },
        b = { bg = colors.surface0, fg = colors.text },
        c = { bg = colors.mantle, fg = colors.text },
    },
    insert = {
        a = { bg = colors.green, fg = colors.base, gui = 'bold' }, -- Green on dark base
        b = { bg = colors.surface0, fg = colors.text },
        c = { bg = colors.mantle, fg = colors.text },
    },
    visual = {
        a = { bg = colors.yellow, fg = colors.base, gui = 'bold' }, -- Yellow on dark base
        b = { bg = colors.surface0, fg = colors.text },
        c = { bg = colors.mantle, fg = colors.text },
    },
    replace = {
        a = { bg = colors.red, fg = colors.text, gui = 'bold' },
        b = { bg = colors.surface0, fg = colors.text },
        c = { bg = colors.mantle, fg = colors.text },
    },
    command = {
        a = { bg = colors.blue, fg = colors.base, gui = 'bold' }, -- Blue on dark base
        b = { bg = colors.surface0, fg = colors.text },
        c = { bg = colors.mantle, fg = colors.text },
    },
    inactive = {
        a = { bg = colors.crust, fg = colors.overlay1 },
        b = { bg = colors.crust, fg = colors.overlay1 },
        c = { bg = colors.crust, fg = colors.overlay1 },
    },
}
