return {
  {
    'akinsho/bufferline.nvim',
    event = 'VeryLazy',
    version = '3.*',
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require('bufferline').setup({
        options = {
          mode = 'tabs',
          diagnostics_update_in_insert = true,
          show_buffer_close_icons = false,
          show_close_icon = false,
          always_show_bufferline = false,
          diagnostics = 'nvim_lsp'
        }
      })
    end
  },
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      local function _my_ft()
        return vim.opt.filetype._value
      end
      require('lualine').setup({
        options = {
          section_separators = { left = '', right = '' },
          component_separators = { left = '', right = '' }
        },
        -- sections = {
        --   lualine_c = { 'g:coc_status' },
        --   lualine_x = { 'encoding', 'fileformat', _my_ft },
        -- },
        -- inactive_sections = {
        --   lualine_c = {},
        -- }
      })
    end
  },
  {
    'simrat39/symbols-outline.nvim',
    keys = { { '<LEADER>v', '<CMD>SymbolsOutline<CR>', mode = 'n', silent = true } },
    config = function()
      require('symbols-outline').setup {}
    end
  },
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    opts = {} -- this is equalent to setup({}) function
  },
}
