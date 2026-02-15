return {
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
		-- ========================
		-- Minimal LSP configuration
		-- ========================
		local lsp_config = {
			on_attach = function(client, bufnr)
				if not bufnr then
					return
				end
				local name = vim.api.nvim_buf_get_name(bufnr)
				if name == "" then
					return
				end -- skip unnamed buffers

				local function safe_buf_map(mode, lhs, rhs, opts)
					if not lhs or not rhs then
						return
					end
					opts = opts or { noremap = true, silent = true }
					local ok, err = pcall(vim.api.nvim_buf_set_keymap, bufnr, mode, lhs, rhs, opts)
					if not ok then
						vim.notify("Keymap failed: " .. tostring(err), vim.log.levels.WARN)
					end
				end

				-- Basic LSP mappings
				safe_buf_map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
				safe_buf_map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
				safe_buf_map("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
			end,
			capabilities = vim.lsp.protocol.make_client_capabilities(),
			filetype_to_server = {
				lua = "lua_ls",
				python = "pyright",
				c = "clangd",
				cpp = "clangd",
			},
			-- Async write configuration
			async_write_opts = {
				timeout = 30, -- Timeout in seconds for write operations
				debug = false, -- enable debug logging
				log_level = vim.log.levels.INFO,
				autosave = true,
				save_debounce_ms = 3000,
				logging = {
					max_entries = 1000,
					include_context = true,
					viewer = {
						height = 15,
						auto_scroll = true,
						position = "bottom",
					},
				},
			},

			-- Remote terminal configuration
			remote_terminal_opts = {
				window = {
					height = 0.3, -- 30 % of screen height
				},
				picker = {
					width = 25, -- Fixed width for picker sidebar
				},
				keymaps = {
					-- Terminal mode keybindings
					-- new_terminal = "<C-\\>n",
					-- close_terminal = "<C-\\>x",
					-- toggle_split = "<C-\\><C-\\>",
					-- next_terminal = "<C-\\>]",
					-- prev_terminal = "<C-\\>[",
				},
				-- picker_keymaps = {
				-- Picker sidebar keybindings
				--select = "<CR>",
				--rename
				-- }
				highlights = {
					TerminalPickerSelected = { bg = "#3e4451", bold = true },
					TerminalPickerNormal = { fg = "#abb2bdf" },
					TerminalPickerHeader = { fg = "#61afef", bold = true },
					TerminalPickerId = { fg = "#d19a66" },
				},
			},
		}

		-- ========================
		-- Telescope remote buffer
		-- ========================
		pcall(function()
			require("telescope-remote-buffer").setup({
				-- fzf = "",
				-- match = "",
				-- odlfiles = "",
			})
		end)

		-- ========================
		-- Remote SSH setup (generic)
		-- ========================
		require("remote-ssh").setup({
			on_attach = lsp_config.on_attach,
			capabilities = lsp_config.capabilities,
			filetype_to_server = lsp_config.filetype_to_server,

			aysnc_write_ops = {
				autosave = true, -- Auto-save on text changes
				save_debounce_ms = 3000, -- Wait 3 seconds after editing before saving
			},
		})

		-- ========================
		-- Generic auto-sync
		-- ========================
		local project_local_dir = os.getenv("HOME") .. "/projects/myproject" -- change to your project path

		-- Manual sync command
		vim.api.nvim_create_user_command("SyncProject", function(opts)
			local host = opts.args
			if not host or host == "" then
				print("Usage: :SyncProject <host>")
				return
			end
			local remote_dir = "~/projects/myproject"
			local cmd = string.format([[rsync -avz --delete %s/ %s:%s/]], project_local_dir, host, remote_dir)
			os.execute(cmd)
			print("Project synced to remote server:", host)
		end, { nargs = 1 })

		-- Auto-sync on save (only for remote buffers)
		vim.api.nvim_create_autocmd("BufWritePost", {
			pattern = "*",
			callback = function()
				local bufname = vim.api.nvim_buf_get_name(0)
				if not bufname or bufname == "" then
					return
				end
				local host = bufname:match("^scp://([^/]+)/")
				if host then
					local remote_dir = bufname:match("^scp://[^/]+(/.+)$") or "~/projects/myproject"
					local cmd = string.format([[rsync -avz --delete %s/ %s:%s/]], project_local_dir, host, remote_dir)
					os.execute(cmd)
					print("Auto-synced project to remote server:", host)
				end
			end,
		})
	end,
}
