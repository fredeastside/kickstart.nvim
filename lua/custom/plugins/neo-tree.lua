return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  config = function()
    require('neo-tree').setup {
      filesystem = {
        filtered_items = {
          -- visible = true,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = {
            '.git',
            '.DS_Store',
            '.idea',
          },
          never_show = { '.git' },
        },
      },
    }
  end,
  opts = {
    event_handlers = {
      event = 'neo_tree_buffer_enter',
      handler = function()
        vim.opt_local.relativenumber = true
      end,
    },
  },
}
