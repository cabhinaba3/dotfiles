local opt = vim.opt

-- enabled line numbers
opt.number = true
opt.relativenumber = true

-- Speacial characters
vim.keymap.set("n", "-", vim.cmd.Ex)

require "config.lazy"
require "config.cmd"

require "config.keymaps"
