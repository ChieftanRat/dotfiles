return {
    'bettervim/yugen.nvim',
    name = 'yugen',
    priority = 1000,
    lazy = false,
    config = function()
	require('yugen').setup({
	  styles = {
	    transparency = true
	  },
	})
        vim.cmd.colorscheme('yugen')
	vim.cmd([[ hi Normal guibg=NONE ctermbg=NONE ]])
	vim.cmd([[ hi NormalNC guibg=NONE ctermbg=NONE ]])
	vim.cmd([[ hi SignColumn guibg=NONE ctermbg=NONE ]])
	vim.cmd([[ hi VertSplit guibg=NONE ctermbg=NONE ]])
    end,
} 
