local plenary_path = vim.fn.expand('$HOME/.local/share/nvim/site/pack/vendor/start/plenary.nvim')
local plenary_exists = vim.fn.empty(vim.fn.glob(plenary_path)) == 0

if not plenary_exists then
	vim.fn.system({
		'git',
		'clone',
		'--depth',
		'1',
		'https://github.com/nvim-lua/plenary.nvim',
		plenary_path
	})
end

vim.opt.rtp:append(".")
vim.opt.rtp:append(plenary_path)
