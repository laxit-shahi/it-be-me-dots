return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local harpoon = require 'harpoon'

    -- REQUIRED: Setup harpoon
    harpoon:setup()

    -- Basic keymaps
    local map = vim.keymap.set

    -- Add current file to harpoon
    map('n', '<leader>a', function()
      harpoon:list():add()
    end, { desc = 'Harpoon: Add file' })

    -- Toggle harpoon menu
    map('n', '<C-e>', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = 'Harpoon: Toggle menu' })

    -- Select specific marks (1-4) 
    --   Note: Hard to use with "hold space" as layer 2 key
    map('n', '<leader>1', function()
      harpoon:list():select(1)
    end, { desc = 'Harpoon: Go to file 1' })

    map('n', '<leader>2', function()
      harpoon:list():select(2)
    end, { desc = 'Harpoon: Go to file 2' })

    map('n', '<leader>3', function()
      harpoon:list():select(3)
    end, { desc = 'Harpoon: Go to file 3' })

    map('n', '<leader>4', function()
      harpoon:list():select(4)
    end, { desc = 'Harpoon: Go to file 4' })

    -- Cycle through harpoon marks
    map('n', '[h', function()
      harpoon:list():prev()
    end, { desc = 'Harpoon: Previous file' })

    map('n', ']h', function()
      harpoon:list():next()
    end, { desc = 'Harpoon: Next file' })

    -- Optional: Add keymaps for opening files in splits/tabs from harpoon menu
    harpoon:extend {
      UI_CREATE = function(cx)
        map('n', '<C-v>', function()
          harpoon.ui:select_menu_item { vsplit = true }
        end, { buffer = cx.bufnr, desc = 'Harpoon: Open in vsplit' })

        map('n', '<C-x>', function()
          harpoon.ui:select_menu_item { split = true }
        end, { buffer = cx.bufnr, desc = 'Harpoon: Open in split' })

        map('n', '<C-t>', function()
          harpoon.ui:select_menu_item { tabedit = true }
        end, { buffer = cx.bufnr, desc = 'Harpoon: Open in tab' })

        -- Cycle through menu items with Tab
        map('n', '<Tab>', function()
          vim.cmd 'normal! j'
        end, { buffer = cx.bufnr, desc = 'Harpoon: Next item' })

        map('n', '<S-Tab>', function()
          vim.cmd 'normal! k'
        end, { buffer = cx.bufnr, desc = 'Harpoon: Previous item' })

        -- Direct number navigation (buffer-local, only in menu)
        map('n', '1', function()
          harpoon:list():select(1)
        end, { buffer = cx.bufnr, desc = 'Harpoon: Select file 1' })

        map('n', '2', function()
          harpoon:list():select(2)
        end, { buffer = cx.bufnr, desc = 'Harpoon: Select file 2' })

        map('n', '3', function()
          harpoon:list():select(3)
        end, { buffer = cx.bufnr, desc = 'Harpoon: Select file 3' })

        map('n', '4', function()
          harpoon:list():select(4)
        end, { buffer = cx.bufnr, desc = 'Harpoon: Select file 4' })
      end,
    }
  end,
}
