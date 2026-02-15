-- ~/.config/nvim/lua/config/keymaps.lua
local map = vim.keymap.set

-- Better escape (optional)
-- map("i", "jk", "<Esc>")

-- Save and quit
map("n", "<C-s>", ":w<CR>")
map("n", "<C-q>", ":q<CR>")

-- Cut, copy pase
local opts = { noremap = true, silent = true }
local function is_visual()
	local mode = vim.fn.mode()
	return mode == "v" or mode == "V" or mode == "\22"
end
map("n", "<C-a>", ":ggVg", opts)
map({ "n", "v" }, "<C-c>", function()
	if is_visual() then
		vim.cmd('normal! "+y')
	else
		vim.cmd('normal! ggVG"+y')
	end
end, opts)

map({ "n", "v" }, "<C-x>", function()
	if is_visual() then
		vim.cmd('normal! "+d')
	else
		vim.cmd('normal! ggVG"+d')
	end
end, opts)

map({ "n", "v" }, "<C-d>", function()
	if is_visual() then
		vim.cmd('normal! "_d')
	else
		vim.cmd("normal! ggVG_d")
	end
end, opts)
map({ "n", "v", "i" }, "<C-v>", '"+p', opts)

-- Window navigation
-- map("n", "<C-h>", "<C-w>h")
-- map("n", "<C-j>", "<C-w>j")
-- map("n", "<C-k>", "<C-w>k")
-- map("n", "<C-l>", "<C-w>l")

-- Better indenting
-- map("v", "<", "<gv")
-- map("v", ">", ">gv")

-- Move lines
map("n", "<A-j>", ":m .+1<CR>==")
map("n", "<A-k>", ":m .-2<CR>==")
map("v", "<A-j>", ":m '>+1<CR>gv=gv")
map("v", "<A-k>", ":m '<-2<CR>gv=gv")

-- Clear search
-- map("n", "<Esc>", ":noh<CR>")

-- File explorer
-- map("n", "<leader>e", ":NvimTreeToggle<CR>")

-- Telescope
map("n", "<C-f>", ":Telescope find_files<CR>")
map("n", "<C-l>", ":Telescope live_grep<CR>")
map("n", "<leader>b", ":Telescope buffers<CR>")

-- Terminal
-- map("n", "<C-\\>", ":ToggleTerm<CR>")
-- map("t", "<C-\\>", "<C-\\><C-n>:ToggleTerm<CR>")

-- Jupyter
-- map("n", "<leader>j", ":MoltenInit python3<CR>")
-- map("n", "<CR>", ":MoltenEvaluateOperator<CR>")
-- map("v", "<CR>", ":<C-u>MoltenEvaluateVisual<CR>gv")

-- Command line terminal
-- map("n", "<C-\\>","ToggleTerm direction=horizontal size=15<CR>")
-- map("t", "<C-j>", ":<C-\\><C-n>:ToggleTerm<CR>")
local state_file = vim.fn.stdpath("data") .. "/last_project_root"
-- Detect project root (git > lsp > cwd)
local function get_project_root()
	-- Git root
	local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
	if git_root and vim.v.shell_error == 0 then
		return git_root
	end

	-- LSP function
	local clients = vim.lsp.get_active_clients({ buffer = 0 })
	if #clients > 0 and clients[1].config.root_dir then
		return clients[1].config.root_dir
	end

	-- Fallback to cwd
	return vim.loop.cwd
end
-- Save the root in VimLeave
vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		local root = get_project_root()
		if root then
			vim.fn.writefile({ root }, state_file)
		end
	end,
})
-- Load last root or fallback to home
local function get_last_root()
	if vim.fn.filereadable(state_file) == 1 then
		return vim.fn.readfile(state_file)[1]
	end
	return vim.fn.expand("~")
end
-- open bottom terminal
map("n", "<C-\\>", function()
	local root = get_last_root()
	vim.cmd("botright split")
	vim.cmd("resize 10")
	vim.cmd("terminal")
	-- change the directory inside terminal
	vim.fn.chansend(vim.b.terminal_job_id, "cd " .. root .. "\n")
	vim.cmd("startinsert")
end, { desc = "Bottom terminal (persistent root)" })
-- Command palette
map("n", "<leader><leader>", ":Telescope commands<CR>")
