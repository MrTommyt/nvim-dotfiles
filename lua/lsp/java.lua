-- Java / jdtls setup for AstroNvim v5 + lspsaga
-- Replaces your current file

return {
  -- LSPSaga (UI)
  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-tree/nvim-web-devicons",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      ui = { border = "rounded" },
      lightbulb = { enable = false },
      symbol_in_winbar = { enable = false },
    },
    config = function(_, opts)
      require("lspsaga").setup(opts)
      -- generic gp fallback if you want (Java will override below)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("SagaKeysGeneric", { clear = true }),
        callback = function(args)
          local opts = { noremap = true, silent = true }
          -- Finder (definitions + references + implementations)
          vim.keymap.set("n", "gf", "<cmd>Lspsaga finder<CR>", opts)
          -- Diagnostics
          vim.keymap.set("n", "gcd", "<cmd>Lspsaga show_line_diagnostics<CR>", opts)
          -- set only if not Java; Java gets its own mapping later
          if vim.bo[args.buf].filetype ~= "java" then
            pcall(vim.keymap.del, "n", "gp", { buffer = args.buf })
            vim.keymap.set("n", "gp", "<cmd>Lspsaga peek_definition<CR>", {
              buffer = args.buf, silent = true, desc = "Peek Definition (Saga)",
            })
          end

          -- Visual selection → extract variable / method
          vim.keymap.set("v","<leader>jv", function() require("jdtls").extract_variable(true) end, {desc="JDT: Extract Var"})
          vim.keymap.set("v","<leader>jm", function() require("jdtls").extract_method(true) end,   {desc="JDT: Extract Method"})
          -- Current cursor → extract variable
          vim.keymap.set("n","<leader>jv", function() require("jdtls").extract_variable() end, {desc="JDT: Extract Var"})
          -- Organize imports / generate code
          vim.keymap.set("n","<leader>ji", function() require("jdtls").organize_imports() end, {desc="JDT: Organize Imports"})
          vim.keymap.set("n","<leader>jc", function() require("jdtls").code_action() end, {desc="JDT: Generate…"})
        end,
      })
    end,
  },

  -- Make sure mason-lspconfig/lspconfig do NOT start a second jdtls
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.handlers = opts.handlers or {}
      opts.handlers.jdtls = function() end
      return opts
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts = opts or {}
      if opts.servers then opts.servers.jdtls = nil end
      return opts
    end,
  },

  -- nvim-jdtls: start/attach per buffer/project
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    init = function()
      -- ensure plugin is available for jdt:// buffers too (from peeks etc.)
      vim.api.nvim_create_autocmd("BufReadCmd", {
        pattern = "jdt://*",
        callback = function()
          require("lazy").load({ plugins = { "nvim-jdtls" } })
        end,
      })
    end,
    config = function()
      local function jdtls_config_for_buf(bufnr)
        -- detect project root for THIS buffer
        local root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" })
        if not root_dir then return nil end

        -- mason paths
        local data = vim.fn.stdpath("data")
        local jdtls_base = data .. "/mason/packages/jdtls"
        local launcher = vim.fn.glob(jdtls_base .. "/plugins/org.eclipse.equinox.launcher_*.jar")
        if launcher == "" then
          vim.notify("jdtls (Mason) not installed. Open :Mason and install 'jdtls'.", vim.log.levels.ERROR)
          return nil
        end

        -- OS-specific config dir
        local sys = (vim.uv or vim.loop).os_uname().sysname
        local os_cfg =
          (sys == "Darwin" and "config_mac")
          or (vim.fn.has("win32") == 1 and "config_win")
          or "config_linux"

        -- optional Lombok
        local home = (vim.uv or vim.loop).os_homedir()
        local lombok = home .. "/.local/share/lombok/lombok.jar"
        local has_lombok = vim.fn.filereadable(lombok) == 1

        -- workspace per project name
        local workspace = data .. "/jdtls-workspace/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")

        local cmd = {
          "java",
          "-Declipse.application=org.eclipse.jdt.ls.core.id1",
          "-Dosgi.bundles.defaultStartLevel=4",
          "-Declipse.product=org.eclipse.jdt.ls.core.product",
          "-Dlog.level=ERROR",
          "-Xmx1g",
          "-jar", launcher,
          "-configuration", jdtls_base .. "/" .. os_cfg,
          "-data", workspace,
        }
        if has_lombok then
          table.insert(cmd, 6, "-javaagent:" .. lombok) -- insert before -jar
        end

        return {
          cmd = cmd,
          root_dir = root_dir,
          settings = {
            java = {
              maven  = { downloadSources = true },
              import = { gradle = { enabled = true, downloadSources = true } },
              contentProvider = { preferred = "fernflower" },
            },
          },
          -- recommended on_attach (keymaps, etc.) can go here if desired
        }
      end

      -- Start/attach whenever a Java buffer appears (per-project)
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("JdtlsPerProject", { clear = true }),
        pattern = "java",
        callback = function(args)
          local cfg = jdtls_config_for_buf(args.buf)
          if not cfg then return end
          require("jdtls").start_or_attach(cfg)
        end,
      })

      -- Java-only gp mapping (buffer-local), works with jdt:// (your float/peek choice)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("JavaGpKey", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client or client.name ~= "jdtls" then return end

          -- delete any existing gp for this buffer
          pcall(vim.keymap.del, "n", "gp", { buffer = args.buf })

          -- simplest: use Saga for project files; you can keep your advanced jdt:// float if you like
          vim.keymap.set("n", "gp", "<cmd>Lspsaga peek_definition<CR>", {
            buffer = args.buf,
            silent = true,
            desc = "Peek Definition (Java/Saga)",
          })
        end,
      })
    end,
  },
}
