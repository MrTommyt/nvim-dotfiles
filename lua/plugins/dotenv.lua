return {
  "ellisonleao/dotenv.nvim",
  config = function()
    require("dotenv").setup({
      enable_on_load = true, -- Loads .env file when a buffer is loaded
      verbose = false,      -- Suppresses error notifications if .env is not found
      -- file_name = 'myenvfile.env' -- Optional: specify a different .env file name
    })
  end,
}
