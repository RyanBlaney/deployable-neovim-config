function ColorMyPencils(color)
    color = color or "kanagawa-paper"
    vim.cmd.colorscheme(color)

    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

    vim.api.nvim_exec(
        [[
      hi! link CurSearch IncSearch
    ]],
        false
    )
end

ColorMyPencils()
