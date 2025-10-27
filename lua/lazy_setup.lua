require("lazy").setup({
  -- {
  --   'nvimdev/lspsaga.nvim',
  --   config = function()
  --     -- Ensure lspsaga is set up first
  --     require("lspsaga").setup({})
  --
  --     -- Global fallback (works in many fts)
  --     vim.keymap.set("n", "gp", "<cmd>Lspsaga peek_definition<CR>", { noremap = true, silent = true, desc = "Peek Definition" })
  --
  --     -- Force it for Java buffers after jdtls attaches
  --     vim.api.nvim_create_autocmd("LspAttach", {
  --       callback = function(args)
  --         local client = vim.lsp.get_client_by_id(args.data.client_id)
  --         if client or client.name == "jdtls" then
  --           -- buffer-local override so jdtls (or anything else) can’t steal it
  --           vim.keymap.set("n", "gp", "<cmd>Lspsaga peek_definition<CR>", {
  --             buffer = args.buf,
  --             noremap = true,
  --             silent = true,
  --             desc = "Peek Definition (Java)",
  --           })
  --           -- optional: type peek as well
  --           vim.keymap.set("n", "gP", "<cmd>Lspsaga peek_type_definition<CR>", {
  --             buffer = args.buf,
  --             noremap = true,
  --             silent = true,
  --             desc = "Peek Type (Java)",
  --           })
  --         end
  --       end,
  --   })
  --   end,
  --   -- dependencies = {
  --   --     "neovim/nvim-lspconfig",
  --   --     'nvim-treesitter/nvim-treesitter', -- optional
  --   --     'nvim-tree/nvim-web-devicons',     -- optional
  --   -- },
  --   opts = {
  --     ui = { border = "rounded" },
  --   },
  -- },
  {
    "AstroNvim/AstroNvim",
    version = "^5", -- Remove version tracking to elect for nightly AstroNvim
    import = "astronvim.plugins",
    opts = { -- AstroNvim options must be set here with the `import` key
      mapleader = " ", -- This ensures the leader key must be configured before Lazy is set up
      maplocalleader = ",", -- This ensures the localleader key must be configured before Lazy is set up
      icons_enabled = true, -- Set to false to disable icons (if no Nerd Font is available)
      pin_plugins = nil, -- Default will pin plugins when tracking `version` of AstroNvim, set to true/false to override
      update_notifications = true, -- Enable/disable notification about running `:Lazy update` twice to update pinned plugins
    },
  },
  -- {
  --   'Dronakurl/injectme.nvim',
  --   dependencies = {
  --     "nvim-treesitter/nvim-treesitter",
  --     "nvim-lua/plenary.nvim",
  --     "nvim-telescope/telescope.nvim",
  --   },
  --   -- This is for lazy load and more performance on startup only
  --   cmd = { "InjectmeToggle", "InjectmeSave", "InjectmeInfo" , "InjectmeLeave"},
  -- },

  -- {
  --   "dariuscorvus/tree-sitter-language-injection.nvim",
  --   opts = {
  --     java = {
  --       string = {
  --         langs = {
  --           { name = "sql", match = "^(\r\n|\r|\n)*-{2,}( )*{lang}" }
  --         },
  --         query = [[
  --           ; query
  --           ;; string {name} injection
  --           ((string_fragment) @injection.content
  --                           (#match? @injection.content "{match}")
  --                           (#set! injection.language "{name}"))
  --         ]]
  --       },
  --       comment = {
  --         langs = {
  --           { name = "sql", match = "^//+( )*{lang}( )*" }
  --         },
  --         query = [[
  --           ; query
  --           ;; comment {name} injection
  --           ((comment) @comment .
  --             (lexical_declaration
  --               (variable_declarator
  --                 value: [
  --                   (string(string_fragment)@injection.content)
  --                   (template_string(string_fragment)@injection.content)
  --                 ]@injection.content)
  --             )
  --             (#match? @comment "{match}")
  --             (#set! injection.language "{name}")
  --           )
  --         ]]
  --       }
  --     }
  --   }, -- calls setup()
  -- },
  { import = "community" },
  { import = "plugins" },
  { import = "lsp" },
  { import = "custom" },
} --[[@as LazySpec]], {
  -- Configure any other `lazy.nvim` configuration options here
  install = { colorscheme = { "astrotheme", "habamax" } },
  ui = { backdrop = 100 },
  performance = {
    rtp = {
      -- disable some rtp plugins, add more to your liking
      disabled_plugins = {
        "gzip",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "zipPlugin",
      },
    },
  },
} --[[@as LazyConfig]])
