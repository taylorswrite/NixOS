return {
  {
    "nvim-mini/mini.align",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("mini.align").setup()
    end,
  },
}
