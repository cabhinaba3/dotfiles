-- ~/.config/nvim/lua/plugins/ui.lua

return {
	-- Theme
	{
		"EdenEast/nightfox.nvim",
		-- name = "catppuccin",
		priority = 1000,
		config = function()
			require("nightfox").setup({
				palettes = {
					carbonfox = {
						bg1 = "#1e222a", -- main background (slightly lighter)
					},
				},
			})
			vim.cmd.colorscheme("carbonfox")
		end,
	},

	-- File Explorer
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			view = { width = 30 },
		},
	},

	-- Statusline
	{
		"nvim-lualine/lualine.nvim",
		opts = {
			options = {
				theme = "gruvbox",
				component_separators = "",
				section_separators = "",
			},
		},
	},

	-- Buffer tabs
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = "nvim-tree/nvim-web-devicons",
		opts = {
			options = {
				custom_filter = function(buf_number)
					--Hide terminal buffers from tab line
					local buftype = vim.api.nvim_buf_get_option(buf_number, "buftype")
					return buftype ~= "terminal"
				end,
			},
		},
	},

	-- Terminal
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		opts = {
			direction = "float",
			size = 20,
			hide_numbers = false,
			start_in_insert = true,
			close_on_exit = true,
			shell = vim.o.shell,
			-- Make terminal invisible in buffer/tab lists
			on_open = function()
				vim.cmd("setlocal nobuflisted")
			end,
		},
	},

	-- Git signs
	{
		"lewis6991/gitsigns.nvim",
		opts = {},
	},

	-- Auto pairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {},
	},

	-- Comments
	{
		"numToStr/Comment.nvim",
		opts = {},
	},

	-- Indent guides
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {},
	},
}
