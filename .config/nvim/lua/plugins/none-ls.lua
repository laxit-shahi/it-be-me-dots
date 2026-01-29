return {
  'nvimtools/none-ls.nvim',
  dependencies = {
    'nvimtools/none-ls-extras.nvim',
  },
  config = function()
    local null_ls = require 'null-ls'
    local util = require 'lspconfig.util'
    local ruby_tools = require 'util.ruby_tools'

    local function rubocop_formatter_spec(params)
      local bufname = params.bufname
      if not bufname or bufname == '' then
        return nil
      end

      local root = params.root
      if not root then
        local finder = util.root_pattern('Gemfile', '.rubocop.yml', '.git')
        root = finder(bufname)
      end

      return ruby_tools.rubocop_formatter(root, bufname)
    end

    -- Null/None-ls wraps foramatters with a generalized LSP
    -- This allows these formatters to be called like LSPs
    null_ls.setup {
      sources = {
        -- Lua
        null_ls.builtins.formatting.stylua,

        -- Python
        null_ls.builtins.formatting.isort,
        null_ls.builtins.formatting.black,
        null_ls.builtins.diagnostics.pylint,

        -- JavaScript
        null_ls.builtins.formatting.prettierd,
        require 'none-ls.diagnostics.eslint_d',

        -- go
        null_ls.builtins.formatting.gofmt,
        null_ls.builtins.formatting.goimports,
        null_ls.builtins.formatting.golines,

        -- Ruby
        null_ls.builtins.formatting.rubocop.with {
          runtime_condition = function(params)
            local spec = rubocop_formatter_spec(params)
            if not spec then
              return false
            end
            params._rubocop_formatter = spec
            return true
          end,
          command = function(params)
            return params._rubocop_formatter.command
          end,
          args = function(params)
            return params._rubocop_formatter.args
          end,
          env = function(params)
            return params._rubocop_formatter.env
          end,
          cwd = function(params)
            return params._rubocop_formatter.cwd
          end,
        },
        -- null_ls.builtins.diagnostics.rubocop.with({
        --   command = function(params)
        --     local file_dir = vim.fn.fnamemodify(params.bufname, ':p:h')
        --     return vim.fn.findfile('dev.yml', file_dir .. ';') ~= '' and 'bundle' or 'rubocop'
        --   end,
        --   args = function(params)
        --     local file_dir = vim.fn.fnamemodify(params.bufname, ':p:h')
        --     local is_shopify = vim.fn.findfile('dev.yml', file_dir .. ';') ~= ''
        --     return is_shopify and
        --       { 'exec', 'rubocop', '--disable-pending-cops', '--format', 'json', '--stdin', '$FILENAME' } or
        --       { '--disable-pending-cops', '--format', 'json', '--stdin', '$FILENAME' }
        --   end,
        --   cwd = function(params)
        --     local file_dir = vim.fn.fnamemodify(params.bufname, ':p:h')
        --     local root_dir = vim.fn.findfile('dev.yml', file_dir .. ';')
        --     return root_dir ~= '' and vim.fn.fnamemodify(root_dir, ':p:h') or file_dir
        --   end,
        -- })
      },
    }

    -- Setup format on save
    -- vim.api.nvim_create_autocmd('BufWritePre', {
    --   buffer = buffer,
    --
    --   callback = function()
    --     vim.lsp.buf.format { async = false }
    --   end,
    -- })

    -- Format manually
    vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, { desc = 'Format file' })
  end,
}
