vim.g.mapleader = " "  -- must come before keymaps

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
  {
    "sotte/presenting.nvim",
    opts = {},
    ft = "markdown",
  },
})

local pilot = require("pilot")
pilot.setup()

vim.opt.termguicolors = true
vim.cmd.colorscheme("obsidian")

vim.keymap.set("n", "<leader>?", pilot.lookup)
vim.keymap.set("x", "<leader>?", ":<C-u>lua require('pilot').lookup({ visual = true })<CR>")
vim.keymap.set("n", "<leader>a", pilot.ask)
