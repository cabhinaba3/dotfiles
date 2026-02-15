-- ~/.config/nvim/lua/plugins/telescope.lua

return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		config = function()
			require("telescope").setup({
				defaults = {
					file_ignore_patterns = { "node_modules", ".git/" },
					-- Hide terminal buffers from pickers
					bufnr_ignore = function(bufnr)
						local buftype = vim.api.nvim_buf_get_option(bufnr, "buftype")
						return buftype == "terminal"
					end,
				},
			})
			require("telescope").load_extension("fzf")
		end,
	},
}
