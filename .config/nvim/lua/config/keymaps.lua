-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- FZF shortcuts (preserve from old config)
map("n", "<leader>t", "<cmd>Files<cr>", { desc = "FZF Files" })
map("n", "<leader>e", "<cmd>Ag<cr>", { desc = "FZF Ag" })
map("n", "<leader>b", "<cmd>Buffers<cr>", { desc = "FZF Buffers" })

-- Buffer navigation (preserve from old config)
map("n", "<leader>h", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>f", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<leader>q", "<cmd>bd<cr>", { desc = "Close buffer" })

-- Clipboard copy (preserve from old config)
map({ "n", "v" }, "<leader>c", '"+y', { desc = "Copy to clipboard" })

-- Python debugging (preserve from old config)
map("n", "<leader>d", "oimport pdb<ESC>opdb.set_trace()<ESC>", { desc = "Add pdb breakpoint" })

-- CoC-style LSP keybindings (optional, can use LazyVim defaults instead)
map("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<cr>", { desc = "Rename" })
map("n", "<leader>a", "<cmd>lua vim.lsp.buf.code_action()<cr>", { desc = "Code Action" })
map("n", "[g", "<cmd>lua vim.diagnostic.goto_prev()<cr>", { desc = "Prev Diagnostic" })
map("n", "]g", "<cmd>lua vim.diagnostic.goto_next()<cr>", { desc = "Next Diagnostic" })
