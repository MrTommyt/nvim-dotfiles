return {
  "ellisonleao/dotenv.nvim",
  lazy = false,
  config = function()
    -- vim.cmd.Dotenv(vim.fn.stdpath("config") .. '.env')
    require("dotenv").setup({
      enable_on_load = true, -- Loads .env file when a buffer is loaded
      verbose = false,      -- Suppresses error notifications if .env is not found
      file_name = ".env" -- Optional: specify a different .env file name
    })
    vim.cmd.Dotenv(vim.fn.stdpath("config") .. "/.env")
  end,
}
