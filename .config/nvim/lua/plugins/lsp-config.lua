-- NOTE: This is where your plugins related to LSP can be installed.
--  The configuration is done below. Search for lspconfig to find it below.
return {
  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- Mason is what installs LSPs
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end,
  },
  {
    -- Bridges gap between mason and nvim-lspconfig
    -- It also allows us to use the ensure_installed function to easily install LSPs
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      -- [[ Configure LSP ]]
      --  This function gets run when an LSP connects to a particular buffer.
      local on_attach = function(_, bufnr)
        -- NOTE: Remember that lua is a real programming language, and as such it is possible
        -- to define small helper and utility functions so you don't have to repeat yourself
        -- many times.
        --
        -- In this case, we create a function that lets us more easily define mappings specific
        -- for LSP related items. It sets the mode, buffer and description for us each time.
        local nmap = function(keys, func, desc)
          if desc then
            desc = 'LSP: ' .. desc
          end

          vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
        end

        nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

        nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
        nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

        -- See `:help K` for why this keymap
        nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
        -- nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
        -- overlaps with movement between panes

        -- Lesser used LSP functionality
        nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
        nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
        nmap('<leader>wl', function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, '[W]orkspace [L]ist Folders')

        -- Create a command `:Format` local to the LSP buffer
        vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
          vim.lsp.buf.format()
        end, { desc = 'Format current buffer with LSP' })
      end

      -- mason-lspconfig requires that these setup functions are called in this order
      -- before setting up the servers.
      require('mason-lspconfig').setup()

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. They will be passed to
      --  the `settings` field of the server config. You must look up that documentation yourself.
      --
      --  If you want to override the default filetypes that your language server will attach to you can
      --  define the property 'filetypes' to the map in question.
      local servers = {
        clangd = {},
        gopls = {},
        pyright = {},
        rust_analyzer = {},
        -- Replaced with typescript tools
        -- ts_ls = {
        --   root_dir = function(fname)
        --     local util = require('lspconfig.util')
        --     return util.root_pattern('package.json', 'tsconfig.json', 'jsconfig.json', '.git')(fname)
        --   end,
        -- },
        html = { filetypes = { 'html', 'twig', 'hbs', 'svelte' } },
        -- ruby_ls = {},
        lua_ls = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            -- NOTE: toggle below to ignore Lua_LS's noisy `missing-fields` warnings
            diagnostics = {
              'vim',
              'require',
              -- disable = { 'missing-fields' },
            },
          },
        },
      }

      -- Setup neovim lua configuration
      require('neodev').setup()

      -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

      -- Ensure the servers above are installed
      local mason_lspconfig = require 'mason-lspconfig'

      mason_lspconfig.setup {
        ensure_installed = vim.tbl_keys(servers),
      }

      -- Setup handlers for mason-lspconfig
      for server_name in pairs(servers) do
        local server_config = servers[server_name] or {}
        vim.lsp.config(server_name, {
          capabilities = capabilities,
          on_attach = on_attach,
          settings = server_config,
          filetypes = server_config.filetypes,
          root_dir = server_config.root_dir,
        })
        vim.lsp.enable(server_name)
      end
    end,
  },

  {
    -- LSP Configuration & Plugins
    -- This HOOKS UP NEOVIM to the LSP
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
    config = function()
      local util = require 'lspconfig.util'
      local ruby_tools = require 'util.ruby_tools'

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

      local function setup_ruby_server(server, builder, opts)
        local defaults = opts or {}
        local root_dir_fn = defaults.root_dir
        local filetypes = defaults.filetypes or { 'ruby' }

        -- Configure the server with the new API
        vim.lsp.config(server, {
          capabilities = capabilities,
          root_dir = root_dir_fn,
          filetypes = filetypes,
        })

        -- Don't enable automatically - we'll start manually based on conditions
        local group = vim.api.nvim_create_augroup('RubyLspAutostart' .. server, { clear = true })
        local filetypes_map = {}
        for _, ft in ipairs(filetypes) do
          filetypes_map[ft] = true
        end

        vim.api.nvim_create_autocmd('BufEnter', {
          group = group,
          callback = function(args)
            local bufnr = args.buf
            if not vim.api.nvim_buf_is_valid(bufnr) then
              return
            end

            local ft = vim.bo[bufnr].filetype
            if not filetypes_map[ft] then
              return
            end

            local bufname = vim.api.nvim_buf_get_name(bufnr)
            if bufname == '' then
              return
            end

            local root_dir = root_dir_fn and root_dir_fn(bufname, bufnr)
            if not root_dir then
              return
            end

            local cmd, env = builder(root_dir)
            if not cmd then
              return
            end

            local existing = vim.lsp.get_clients { bufnr = bufnr, name = server }
            if #existing > 0 then
              return
            end

            -- Manually start the LSP client with dynamic configuration
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
