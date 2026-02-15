-- ~/.config/nvim/lua/plugins/treesitter.lua

return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		opts = {
			ensure_installed = {
				"lua",
				"vim",
				"vimdoc",
				"python",
				"javascript",
				"typescript",
				"html",
				"css",
				"json",
				"yaml",
				"bash",
				"markdown",
			},
			highlight = { enable = true },
			indent = { enable = true },
		},
		--        config = function(_, opts)
		--          require("nvim-treesitter.configs").setup(opts)
		--   end,
	},
}
