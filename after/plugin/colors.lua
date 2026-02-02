function ColorMyPencils(color)
    color = color or "maroon-earth"

    if color == "maroon-earth" then
        require('ryanblaney.themes.maroon-earth').setup()
    else
        vim.cmd.colorscheme(color)
    end

    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

    vim.api.nvim_exec([[
      hi! link CurSearch IncSearch
    ]], false)
end

ColorMyPencils("maroon-earth")
