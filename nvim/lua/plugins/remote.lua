-- ~/.config/nvim/lua/plugins/remote.lua

return {
	{
		"inhesrom/remote-ssh.nvim",
		branch = "master",
		dependencies = {
			"inhesrom/telescope-remote-buffer",
			"nvim-telescope/telescope.nvim",
			"nvim-lua/plenary.nvim",
			"neovim/nvim-lspconfig",
			"rcarriga/nvim-notify",
		},
		config = function()
			require("telescope-remote-buffer").setup(
				--fzf="<leader>fz"
			)
			require("remote-ssh").setup({
				on_attach = lsp_config.on_attach,
				capabilities = lsp_config.capabilities,
				filetype_to_server = lsp_config.filetype_to_server,
			})
		end,
	},
}
