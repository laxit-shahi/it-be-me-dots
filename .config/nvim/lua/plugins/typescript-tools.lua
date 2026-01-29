return {
  'pmizio/typescript-tools.nvim',
  dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
  config = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

    require('typescript-tools').setup {
      capabilities = capabilities,
      root_dir = function(fname)
        local util = require 'lspconfig.util'
        return util.root_pattern('tsconfig.json', 'jsconfig.json', 'package.json', '.git')(fname)
      end,
    }
  end,
}
