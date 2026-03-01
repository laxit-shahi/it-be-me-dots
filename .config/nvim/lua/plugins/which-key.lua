-- Useful plugin to show you pending keybinds.
return {
  'folke/which-key.nvim',
  opts = {},
  config = function()
    local wk = require 'which-key'
    local spec = {
      -- Normal mode key groups
      { "<leader>c", group = "[C]ode" },
      { "<leader>c_", hidden = true },
      { "<leader>d", group = "[D]ocument" },
      { "<leader>d_", hidden = true },
      { "<leader>g", group = "[G]it" },
      { "<leader>g_", hidden = true },
      { "<leader>h", group = "Git [H]unk" },
      { "<leader>h_", hidden = true },
      { "<leader>r", group = "[R]ename" },
      { "<leader>r_", hidden = true },
      { "<leader>s", group = "[S]earch" },
      { "<leader>s_", hidden = true },
      -- { "<leader>t", group = "[T]oggle" },
      -- { "<leader>t_", hidden = true },
      { "<leader>w", group = "[W]orkspace" },
      { "<leader>w_", hidden = true },
      
      -- Visual mode mappings
      { "<leader>", group = "VISUAL <leader>", mode = "v" },
      { "<leader>h", desc = "Git [H]unk", mode = "v" },
    }

    -- which-key v3+ exposes `add`, older versions use `register`.
    if type(wk.add) == 'function' then
      wk.add(spec)
      return
    end

    if type(wk.register) == 'function' then
      wk.register({
        c = { name = "[C]ode" },
        d = { name = "[D]ocument" },
        g = { name = "[G]it" },
        h = { name = "Git [H]unk" },
        r = { name = "[R]ename" },
        s = { name = "[S]earch" },
        w = { name = "[W]orkspace" },
      }, { prefix = "<leader>", mode = "n" })

      wk.register({
        h = { name = "Git [H]unk" },
      }, { prefix = "<leader>", mode = "v" })
    end
  end
}
