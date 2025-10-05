-- Keep only read-only, diagnostic, and navigation tools you actually have:
local NEOVIM_SAFE = {
  -- Neovim/Workspace
  "buffer.read",
  "workspace.read",
  "grep.search",
  "lsp.symbols",
  "lsp.diagnostics",
  -- Filesystem (read-only)
  "filesystem.find_files",
  "filesystem.list_directory",
  "filesystem.read_file",
  -- Git (read-only)
  "git.status",
  "git.log",
  "git.diff",
}

return {
  -- mcphub
  {
    "ravitemer/mcphub.nvim",
    lazy = true,  -- install, but don't force-load
    opts = {},
  },
  -- codecompanion
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "ellisonleao/dotenv.nvim",
    },
    -- auto_approve = function(p)
    --   if p.server_name ~= "neovim" then return false end
    --   local ok = { read_file=true, read_multiple_files=true, find_files=true, list_directory=true, edit_file=true, write_file=true }
    --   return ok[p.tool_name] or false
    -- end,
    auto_approve = true, -- TODO: set up a proper approval function
    config = function()
      require("dotenv").setup({ dotenv_path = ".env" })

      -- Try to load mcphub's integration if it exists
      local tools = {}
      local ok, m = pcall(require, "mcphub.integrations.codecompanion")
      if ok and m and type(m.tools) == "function" then
        tools = m.tools()
      end

      require("codecompanion").setup({
        extensions = {
          mcphub = {
            callback = "mcphub.extensions.codecompanion",
            opts = {
              -- MCP Tools 
              make_tools = true,              -- Make individual tools (@server__tool) and server groups (@server) from MCP servers
              show_server_tools_in_chat = true, -- Show individual tools in chat completion (when make_tools=true)
              add_mcp_prefix_to_tool_names = false, -- Add mcp__ prefix (e.g `@mcp__github`, `@mcp__neovim__list_issues`)
              show_result_in_chat = true,      -- Show tool results directly in chat buffer
              format_tool = nil,               -- function(tool_name:string, tool: CodeCompanion.Agent.Tool) : string Function to format tool names to show in the chat buffer
              -- MCP Resources
              make_vars = true,                -- Convert MCP resources to #variables for prompts
              -- MCP Prompts 
              make_slash_commands = true,      -- Add MCP prompts as /slash commands
            }
          }
        },
        strategies = {
          chat = { adapter = "ollama" },
          inline = { adapter = "ollama" },
          agent = { adapter = "ollama" },
          -- completion = {
          --   adapter = 'ollama'
          --   -- adapter = "qwen3:default",
          --   model = "deepseek-r1"
          -- },
          -- inline = {
          --   -- adapter = "ollama:deepseek-r1",
          --   adapter = "openai:gpt-4o"
          -- },
          -- chat = {
          --   adapter = "ollama:deepseek-r1",
          --   -- adapter = "openai:gpt-4o"
          -- },
        },
        -- tools = tools,
        group_tools = {
          nvim_safe = NEOVIM_SAFE,
        },
        adapters = {
          http = {
            ollama = function()
              return require("codecompanion.adapters").extend("openai_compatible", {
                env = {
                  url = "http://localhost:11434", -- Default Ollama API URL
                },
                schema = {
                  model = {
                    default = "gpt-oss",
                  },
                },
              })
            end,
            openai = {
                -- Prefer env var for safety
                api_key = os.getenv("OPENAI_API_KEY"),
            },
          }
        },
      })

      -- keymaps
      vim.keymap.set("n", "<leader>ah", "<cmd>MCPHub<cr>", { desc = "MCPHub" })
      vim.keymap.set("n", "<leader>ac", "<cmd>CodeCompanionChat<cr>", { desc = "Agent: Toggle Chat" })
      vim.keymap.set("v", "<leader>ae", function() require("codecompanion").ask("Explain this code") end, { desc = "Agent: Explain selection" })
      vim.keymap.set("v", "<leader>ar", function() require("codecompanion").ask("Refactor this code") end, { desc = "Agent: Refactor selection" })
      vim.keymap.set("v", "<leader>af", function() require("codecompanion").ask("Find and fix bugs in this code") end, { desc = "Agent: Fix selection" })
      vim.keymap.set("v", "<leader>at", function() require("codecompanion").ask("Write unit tests for this code") end, { desc = "Agent: Tests for selection" })

      pcall(function()
        require("which-key").add({ { "<leader>a", group = "Agent (CodeCompanion)" } })
      end)
    end,
  },
}

