require('rose-pine').setup({
    variant = 'auto',
    dark_variant = 'moon',
    disable_background = true,
    disable_float_background = false,
})

function ColorMyPencils(color)
	color = color or "rose-pine"
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#11121e" })

end

ColorMyPencils()
