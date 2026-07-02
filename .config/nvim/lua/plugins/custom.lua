return {
  -- Colorscheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "codedark",
    },
  },

  -- Add codedark colorscheme
  { "tomasiser/vim-code-dark" },

  -- Keep NERDTree if preferred (LazyVim uses neo-tree by default)
  {
    "preservim/nerdtree",
    keys = {
      { "<C-n>", "<cmd>NERDTreeToggle<cr>", desc = "NERDTree" },
    },
  },

  -- Keep FZF (LazyVim uses Telescope but FZF can coexist)
  {
    "junegunn/fzf",
    build = "./install --bin",
  },
  { "junegunn/fzf.vim" },

  -- Add vimpeccable if still needed for key mappings
  { "svermeulen/vimpeccable" },

  -- opencode.nvim integration
  {
    "NickvanDyke/opencode.nvim",
    dependencies = {
      { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
    },
    opts = {
      provider = "snacks", -- Use snacks provider (works everywhere)
    },
    config = function()
      vim.o.autoread = true

      -- Keymaps
      vim.keymap.set({ "n", "x" }, "<C-a>", function()
        require("opencode").ask("@this: ", { submit = true })
      end, { desc = "Ask opencode" })
      vim.keymap.set({ "n", "x" }, "<C-x>", function()
        require("opencode").select()
      end, { desc = "Execute opencode action…" })
      vim.keymap.set({ "n", "t" }, "<C-.>", function()
        require("opencode").toggle()
      end, { desc = "Toggle opencode" })

      vim.keymap.set({ "n", "x" }, "go", function()
        return require("opencode").operator("@this ")
      end, { expr = true, desc = "Add range to opencode" })
      vim.keymap.set("n", "goo", function()
        return require("opencode").operator("@this ") .. "_"
      end, { expr = true, desc = "Add line to opencode" })

      vim.keymap.set("n", "<S-C-u>", function()
        require("opencode").command("session.half.page.up")
      end, { desc = "opencode half page up" })
      vim.keymap.set("n", "<S-C-d>", function()
        require("opencode").command("session.half.page.down")
      end, { desc = "opencode half page down" })

      -- Remap default increment/decrement since we use Ctrl-a/x for opencode
      vim.keymap.set("n", "+", "<C-a>", { desc = "Increment", noremap = true })
      vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement", noremap = true })
    end,
  },
}
