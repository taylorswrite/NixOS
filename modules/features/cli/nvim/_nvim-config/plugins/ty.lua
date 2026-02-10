-- In your plugins/ty.lua or a similar configuration file
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = { enabled = false }, -- This stops LazyVim from starting Pyright
        ty = {},                       -- This enables ty
      },
    },
  },
}
