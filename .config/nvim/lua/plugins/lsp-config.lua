-- NOTE: This is where your plugins related to LSP can be installed.
return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'folke/neodev.nvim',
      {
        'pmizio/typescript-tools.nvim',
        dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
      },
    },
    config = function()
      -- Setup neovim lua configuration
      require('neodev').setup()

      -- nvim-cmp supports additional completion capabilities
      local capabilities = nil
      if pcall(require, 'cmp_nvim_lsp') then
        capabilities = require('cmp_nvim_lsp').default_capabilities()
      end

      -- Define servers to install and configure
      local servers = {
        clangd = true,
        gopls = true,
        pyright = true,
        rust_analyzer = true,
        html = { filetypes = { 'html', 'twig', 'hbs', 'svelte' } },
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
              diagnostics = { globals = { 'vim' } },
            },
          },
        },
      }

      -- Setup Mason
      require('mason').setup()
      local servers_to_install = vim.tbl_filter(function(key)
        local t = servers[key]
        if type(t) == 'table' then
          return not t.manual_install
        else
          return t
        end
      end, vim.tbl_keys(servers))

      require('mason-lspconfig').setup {
        ensure_installed = servers_to_install,
        -- Avoid auto-starting `ts_ls` (typescript-language-server) because it
        -- conflicts with `typescript-tools.nvim` for TS/JS buffers.
        automatic_enable = { exclude = { 'ts_ls' } },
      }

      -- Set GLOBAL capabilities for all LSP servers (Neovim 0.11+ way)
      vim.lsp.config('*', {
        capabilities = capabilities,
      })

      -- Configure and enable each LSP server
      for name, config in pairs(servers) do
        if config == true then
          config = {}
        end

        -- Only call vim.lsp.config if there are server-specific settings
        if next(config) ~= nil then
          local lsp_config = vim.tbl_deep_extend('force', {}, config)
          lsp_config.manual_install = nil
          vim.lsp.config(name, lsp_config)
        end

        vim.lsp.enable(name)
      end

      -- Setup typescript-tools
      -- IMPORTANT: `typescript-tools.nvim` replaces `ts_ls` (typescript-language-server).
      -- Ensure `ts_ls` isn't enabled elsewhere (e.g. via Mason auto-enable).
      vim.lsp.enable('ts_ls', false)
      require('typescript-tools').setup {
        -- Disable formatting from tsserver; prefer prettierd/null-ls for JS/TS formatting.
        on_attach = function(client)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end,
        -- Make sure the TS server picks the nearest project tsconfig/jsconfig.
        root_dir = function(bufnr, on_dir)
          local fname = vim.api.nvim_buf_get_name(bufnr)
          if fname == '' then
            return
          end

          local ok, lspconfig_util = pcall(require, 'lspconfig.util')
          if not ok then
            on_dir(vim.fn.getcwd())
            return
          end

          local root = lspconfig_util.root_pattern('tsconfig.json', 'jsconfig.json', 'package.json', '.git')(fname)
            or vim.fn.getcwd()

          local node_modules_index = root:find('node_modules', 1, true)
          if node_modules_index and node_modules_index > 0 then
            root = root:sub(1, node_modules_index - 2)
          end

          on_dir(root)
        end,
        settings = {
          separate_diagnostic_server = true,
          publish_diagnostic_on = 'insert_leave',
          jsx_close_tag = {
            enable = true,
            filetypes = { 'javascriptreact', 'typescriptreact' },
          },
          tsserver_file_preferences = {
            includeInlayParameterNameHints = 'all',
            includeInlayVariableTypeHints = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayEnumMemberValueHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeCompletionsForModuleExports = true,
            includeCompletionsForImportStatements = true,
          },
          complete_function_calls = true,
          include_completions_with_insert_text = true,
        },
      }

      -- LspAttach autocmd - modern way to set keybindings for ALL LSP servers
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local bufnr = args.buf

          local nmap = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
          end

          nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

          nmap('gd', function() Snacks.picker.lsp_definitions() end, '[G]oto [D]efinition')
          nmap('gr', function() Snacks.picker.lsp_references() end, '[G]oto [R]eferences')
          nmap('gI', function() Snacks.picker.lsp_implementations() end, '[G]oto [I]mplementation')
          nmap('<leader>D', function() Snacks.picker.lsp_type_definitions() end, 'Type [D]efinition')
          nmap('<leader>ds', function() Snacks.picker.lsp_symbols() end, '[D]ocument [S]ymbols')
          nmap('<leader>ws', function() Snacks.picker.lsp_workspace_symbols() end, '[W]orkspace [S]ymbols')

          nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
          nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
          nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
          nmap('<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, '[W]orkspace [L]ist Folders')

          vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
            vim.lsp.buf.format()
          end, { desc = 'Format current buffer with LSP' })
        end,
      })

      -- Ruby LSP setup (keeping your existing ruby config)
      local util = require 'lspconfig.util'
      local ruby_tools = require 'util.ruby_tools'

      local function setup_ruby_server(server, builder, opts)
        local defaults = opts or {}
        local root_dir_fn = defaults.root_dir
        local filetypes = defaults.filetypes or { 'ruby' }

        vim.lsp.config(server, {
          capabilities = capabilities,
          root_dir = root_dir_fn,
          filetypes = filetypes,
        })

        local group = vim.api.nvim_create_augroup('RubyLspAutostart' .. server, { clear = true })
        local filetypes_map = {}
        for _, ft in ipairs(filetypes) do
          filetypes_map[ft] = true
        end

        vim.api.nvim_create_autocmd('BufEnter', {
          group = group,
          callback = function(event_args)
            local buf = event_args.buf
            if not vim.api.nvim_buf_is_valid(buf) then
              return
            end

            local ft = vim.bo[buf].filetype
            if not filetypes_map[ft] then
              return
            end

            local bufname = vim.api.nvim_buf_get_name(buf)
            if bufname == '' then
              return
            end

            local root_dir = root_dir_fn and root_dir_fn(bufname, buf)
            if not root_dir then
              return
            end

            local cmd, env = builder(root_dir)
            if not cmd then
              return
            end

            local existing = vim.lsp.get_clients { bufnr = buf, name = server }
            if #existing > 0 then
              return
            end

            vim.lsp.start {
              name = server,
              cmd = cmd,
              cmd_env = env,
              cmd_cwd = root_dir,
              root_dir = root_dir,
              capabilities = capabilities,
              filetypes = filetypes,
            }
          end,
          desc = 'Conditionally start ' .. server .. ' when Bundler deps are ready',
        })
      end

      setup_ruby_server('rubocop', ruby_tools.rubocop, {
        root_dir = util.root_pattern('Gemfile', '.rubocop.yml', '.git'),
      })

      setup_ruby_server('sorbet', ruby_tools.sorbet, {
        filetypes = { 'ruby', 'rbi' },
        root_dir = util.root_pattern('sorbet/config', 'Gemfile', '.git'),
      })
    end,
  },
}
