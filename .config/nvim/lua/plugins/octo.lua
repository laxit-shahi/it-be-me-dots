return {
  'pwntester/octo.nvim',
  cmd = 'Octo',
  opts = {
    -- or "fzf-lua" or "snacks" or "default"
    picker = 'telescope',
    -- bare Octo command opens picker of commands
    enable_builtin = true,
  },
  config = function(_, opts)
    require('octo').setup(opts)

    local ok_commands, commands = pcall(require, 'octo.commands')
    if not ok_commands or not commands.commands then
      return
    end

    local ok_picker, picker = pcall(require, 'octo.picker')
    if not ok_picker then
      return
    end

    local function wrap_edit(kind, picker_fn)
      -- Avoid invalid octo:// buffers by falling back to pickers when no args are provided.
      local kind_commands = commands.commands[kind]
      if not kind_commands or type(kind_commands.edit) ~= 'function' then
        return
      end
      local original = kind_commands.edit
      kind_commands.edit = function(...)
        if select('#', ...) == 0 then
          picker_fn()
          return
        end
        return original(...)
      end
    end

    wrap_edit('issue', picker.issues)
    wrap_edit('pr', picker.prs)
    wrap_edit('discussion', picker.discussions)
  end,
  keys = {
    {
      '<leader>oi',
      '<CMD>Octo issue list<CR>',
      desc = 'List GitHub Issues',
    },
    {
      '<leader>op',
      '<CMD>Octo pr list<CR>',
      desc = 'List GitHub PullRequests',
    },
    {
      '<leader>od',
      '<CMD>Octo discussion list<CR>',
      desc = 'List GitHub Discussions',
    },
    {
      '<leader>on',
      '<CMD>Octo notification list<CR>',
      desc = 'List GitHub Notifications',
    },
    {
      '<leader>os',
      function()
        require('octo.utils').create_base_search_command { include_current_repo = true }
      end,
      desc = 'Search GitHub',
    },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    -- OR "ibhagwan/fzf-lua",
    -- OR "folke/snacks.nvim",
    'nvim-tree/nvim-web-devicons',
  },
}
