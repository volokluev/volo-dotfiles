-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Leader key (LazyVim default is space, we want comma)
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Basic settings
vim.opt.number = true
vim.opt.mouse = "a"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Copilot Node.js path
local node = vim.fn.exepath("node")
if node ~= "" then
  vim.g.copilot_node_command = node
end
