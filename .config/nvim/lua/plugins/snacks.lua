-- Helper functions for custom pickers (migrated from telescope.lua)
local function get_clipboard_text()
  local clipboard = vim.fn.getreg '+'
  if clipboard == '' then
    clipboard = vim.fn.getreg '"'
  end
  clipboard = vim.fn.trim(clipboard):gsub('\n', ' ')
  if clipboard == '' then
    return nil
  end
  return clipboard
end

local function find_git_root()
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  if current_file == '' then
    current_dir = cwd
  else
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end
  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print 'Not a git repository. Searching on current working directory'
    return cwd
  end
  return git_root
end

local function camel_to_snake(str)
  str = str:gsub('::', '/')
  return str:gsub('(%l)(%u)', '%1_%2'):gsub('(%u+)(%u%l)', '%1_%2'):lower()
end

return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    quickfile = { enabled = true },
    gh = {},
    picker = {
      enabled = true,
      -- Match telescope's vertical layout (preview on top, 90% width/height)
      layout = {
        preset = 'vertical',
      },
      sources = {
        gh_issue = {},
        gh_pr = {},
        gh_diff = {
          layout = {
            layout = {
              box = 'vertical',
              width = 0,
              height = 0,
              border = 'none',
              { win = 'preview', title = '{preview}', border = 'bottom' },
              {
                box = 'vertical',
                height = 0.2,
                { win = 'input', height = 1, border = 'bottom', title = '{title} {live} {flags}' },
                { win = 'list', border = 'none' },
              },
            },
          },
        },
      },
      jump = { reuse_win = true },
    },
  },
  keys = {
    -- GitHub pickers (existing)
    {
      '<leader>gi',
      function()
        Snacks.picker.gh_issue()
      end,
      desc = 'GitHub Issues (open)',
    },
    {
      '<leader>gI',
      function()
        Snacks.picker.gh_issue { state = 'all' }
      end,
      desc = 'GitHub Issues (all)',
    },
    {
      '<leader>gp',
      function()
        Snacks.picker.gh_pr()
      end,
      desc = 'GitHub Pull Requests (open)',
    },
    {
      '<leader>gP',
      function()
        Snacks.picker.gh_pr { state = 'all' }
      end,
      desc = 'GitHub Pull Requests (all)',
    },
    {
      '<leader>gr',
      function()
        Snacks.picker.resume 'gh_pr'
      end,
      desc = 'Resume PR search',
    },

    -- General pickers (migrated from telescope)
    {
      '<leader>?',
      function()
        Snacks.picker.recent()
      end,
      desc = '[?] Find recently opened files',
    },
    {
      '<leader><space>',
      function()
        Snacks.picker.buffers()
      end,
      desc = '[ ] Find existing buffers',
    },
    {
      '<leader>/',
      function()
        Snacks.picker.lines()
      end,
      desc = '[/] Fuzzily search in current buffer',
    },
    {
      '<leader>s/',
      function()
        Snacks.picker.grep_buffers()
      end,
      desc = '[S]earch [/] in Open Files',
    },
    {
      '<leader>ss',
      function()
        Snacks.picker.pickers()
      end,
      desc = '[S]earch [S]elect Picker',
    },
    {
      '<leader>gf',
      function()
        Snacks.picker.git_files()
      end,
      desc = 'Search [G]it [F]iles',
    },
    {
      '<leader>sf',
      function()
        Snacks.picker.files()
      end,
      desc = '[S]earch [F]iles',
    },
    {
      '<leader>sh',
      function()
        Snacks.picker.help()
      end,
      desc = '[S]earch [H]elp',
    },
    {
      '<leader>sw',
      function()
        Snacks.picker.grep_word()
      end,
      desc = '[S]earch current [W]ord',
    },
    {
      '<leader>sg',
      function()
        Snacks.picker.grep()
      end,
      desc = '[S]earch by [G]rep',
    },
    {
      '<leader>sd',
      function()
        Snacks.picker.diagnostics()
      end,
      desc = '[S]earch [D]iagnostics',
    },
    {
      '<leader>sr',
      function()
        Snacks.picker.resume()
      end,
      desc = '[S]earch [R]esume',
    },
    {
      '<leader>gs',
      function()
        Snacks.picker.git_status()
      end,
      desc = 'Git [S]tatus',
    },

    -- Clipboard search
    {
      '<leader>sc',
      function()
        local clipboard = get_clipboard_text()
        if clipboard then
          Snacks.picker.files { pattern = clipboard }
        end
      end,
      desc = '[S]earch [C]lipboard files',
    },
    {
      '<leader>sC',
      function()
        local clipboard = get_clipboard_text()
        if clipboard then
          Snacks.picker.grep { search = clipboard }
        end
      end,
      desc = '[S]earch [C]lipboard grep',
    },

    -- Git root grep
    {
      '<leader>sG',
      function()
        local git_root = find_git_root()
        if git_root then
          Snacks.picker.grep { dirs = { git_root } }
        end
      end,
      desc = '[S]earch by [G]rep on Git Root',
    },

    -- Ruby namespace → file search (CamelCase::Name → camel_case/name)
    {
      '<leader>sn',
      function()
        local word = vim.fn.expand '<cWORD>'
        local namespace = word:match '^[%w:]+'
        if not namespace then
          return
        end
        local snake = camel_to_snake(namespace)
        Snacks.picker.files { pattern = snake }
      end,
      desc = '[S]earch [N]amespace as file',
    },
  },
}
