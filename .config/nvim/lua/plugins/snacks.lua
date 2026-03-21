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
  },
}
