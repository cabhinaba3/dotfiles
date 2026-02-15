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
map("n", "<C-j>", ":ToggleTerm direction=horizontal size=15<CR>")
map("t", "<C-j>", "<C-\\><C-n>:ToggleTerm<CR>")

-- Command palette
map("n", "<leader><leader>", ":Telescope commands<CR>")
