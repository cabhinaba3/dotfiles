-- Command line terminal
local map = vim.keymap.set

local state_file = vim.fn.stdpath "data" .. "/last_project_root"
-- Detect project root (git, lap, cmd)
local function get_project_root()
  -- Git root
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if git_root and vim.v.shell_error == 0 then
    return git_root
  end

  -- LSP function
  local clients = vim.lsp.get_active_clients { buffer = 0 }
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
  return vim.fn.expand "~"
end
-- open bottom terminal
map("n", "<C-\\>", function()
  local root = get_last_root()
  vim.cmd "botright split"
  vim.cmd "resize 10"
  vim.cmd "terminal"
  -- change the directory inside terminal
  vim.fn.chansend(vim.b.terminal_job_id, "cd " .. root .. "\n")
  vim.cmd "startinsert"
end, { desc = "Bottom terminal (persistent root)" })
