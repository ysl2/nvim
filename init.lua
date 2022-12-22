-- =============
-- === Basic ===
-- =============
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.wrap = false

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.api.nvim_create_autocmd('Filetype', {
  pattern = {
    'lua',
    'json'
  },
  command = 'setlocal tabstop=2 shiftwidth=2',
})

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.termguicolors = true
vim.opt.winblend = 30
vim.cmd('colorscheme evening')

vim.keymap.set('n', '<Space>', '', {})
vim.g.mapleader = ' '
local opts = { silent = true, noremap = true }
vim.keymap.set('i', '<C-c>', '<ESC>', opts)
vim.keymap.set('n', '>>', '>>^', opts)
vim.keymap.set('n', '<<', '<<^', opts)
vim.keymap.set('v', '>', '>^', opts)
vim.keymap.set('v', '<', '<^', opts)

-- Auto delete trailing whitespace.
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  pattern = { '*' },
  command = [[%s/\s\+$//e]],
})


-- ===============
-- === Plugins ===
-- ===============
local ensure_packer = function()
  local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.fn.system({ 'git', 'clone', '--depth', '1', 'git@git.zhlh6.cn:wbthomason/packer.nvim', install_path })
    vim.cmd('packadd packer.nvim')
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

require('packer').startup(
  {
    function(use)
      use 'wbthomason/packer.nvim'
      use { 'neoclide/coc.nvim', branch = 'release' }
      use { 'nvim-treesitter/nvim-treesitter',
        run = function() local ts_update = require('nvim-treesitter.install').update({ with_sync = true }) ts_update() end, }
      use 'easymotion/vim-easymotion'
      use 'tpope/vim-surround'
      use 'tpope/vim-commentary'
      use 'kevinhwang91/rnvimr'
      use 'itchyny/lightline.vim'
      use 'kdheepak/lazygit.nvim'
      use 'Asheq/close-buffers.vim'
      use 'numirias/semshi'
      use 'jbgutierrez/vim-better-comments'
      use 'luochen1990/rainbow'
      use 'nvim-tree/nvim-web-devicons'
      use 'mg979/vim-xtabline'
      use { 'nvim-telescope/telescope.nvim', branch = '0.1.x', requires = { { 'nvim-lua/plenary.nvim' } } }
      use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
      use 'nvim-telescope/telescope-file-browser.nvim'
      use 'gcmt/wildfire.vim'
      use 'honza/vim-snippets'
      use 'itchyny/vim-cursorword'
      use 'wellle/tmux-complete.vim'
      use 'lukas-reineke/indent-blankline.nvim'
      use 'voldikss/vim-floaterm'
      use 'mhinz/vim-startify'
      use 'airblade/vim-rooter'

      -- Automatically set up your configuration after cloning packer.nvim
      -- Put this at the end after all plugins
      if packer_bootstrap then
        require('packer').sync()
      end
    end,
    config = { git = { default_url_format = 'git@git.zhlh6.cn:%s' } }
  }
)

-- ===
-- === nvim-treesitter/nvim-treesitter
-- ===
require('nvim-treesitter.install').prefer_git = true
local parsers = require('nvim-treesitter.parsers').get_parser_configs()
for _, p in pairs(parsers) do
  p.install_info.url = p.install_info.url:gsub(
    'https://github.com/',
    'git@git.zhlh6.cn:'
  )
end

require('nvim-treesitter.configs').setup {
  -- A list of parser names, or "all"
  ensure_installed = { 'lua', 'bash', 'bibtex', 'git_rebase', 'gitattributes', 'gitcommit', 'gitignore', 'diff', 'help',
    'http', 'json', 'jsonc', 'latex', 'lua', 'markdown', 'markdown_inline', 'python', 'regex', 'toml', 'vim', 'yaml' },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = true,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  -- List of parsers to ignore installing (for "all")
  -- ignore_install = { "javascript" },
  ignore_install = {},

  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    -- disable = { "c", "rust" },
    disable = { 'python' },
    -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
    -- disable = function(lang, buf)
    --     local max_filesize = 100 * 1024 -- 100 KB
    --     local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
    --     if ok and stats and stats.size > max_filesize then
    --         return true
    --     end
    -- end,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

-- ===
-- === neoclide/coc.nvim
-- ===
vim.g.coc_global_extensions = {
  'coc-pyright',
  'coc-sh',
  'coc-tabnine',
  'coc-yank',
  'coc-sumneko-lua',
  'coc-marketplace',
  'coc-git',
  'coc-json',
  'coc-snippets',
  'coc-clangd',
  'coc-pairs',
}

-- Some servers have issues with backup files, see #649.
vim.opt.backup = false
vim.opt.writebackup = false

-- Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
-- delays and poor user experience.
vim.opt.updatetime = 300

-- Always show the signcolumn, otherwise it would shift the text each time
-- diagnostics appear/become resolved.
vim.opt.signcolumn = 'yes'

-- Auto complete
function _G.check_back_space()
  local col = vim.fn.col('.') - 1
  return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

-- Use tab for trigger completion with characters ahead and navigate.
-- NOTE: There's always complete item selected by default, you may want to enable
-- no select by `"suggest.noselect": true` in your configuration file.
-- NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
-- other plugin before putting this into your config.
local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }
vim.keymap.set('i', '<TAB>', 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()',
  opts)
vim.keymap.set('i', '<S-TAB>', [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

-- Make <CR> to accept selected completion item or notify coc.nvim to format
-- <C-g>u breaks current undo, please make your own choice.
vim.keymap.set('i', '<cr>', [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

-- Use <c-j> to trigger snippets
-- vim.keymap.set('i', '<c-j>', '<Plug>(coc-snippets-expand-jump)')
-- Use <c-space> to trigger completion.
vim.keymap.set('i', '<c-space>', 'coc#refresh()', { silent = true, expr = true })

-- Use `[g` and `]g` to navigate diagnostics
-- Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
vim.keymap.set('n', '[g', '<Plug>(coc-diagnostic-prev)', { silent = true })
vim.keymap.set('n', ']g', '<Plug>(coc-diagnostic-next)', { silent = true })

-- GoTo code navigation.
vim.keymap.set('n', 'gd', '<Plug>(coc-definition)', { silent = true })
vim.keymap.set('n', '<C-]>', '<Plug>(coc-definition)', { silent = true })
vim.keymap.set('n', 'gy', '<Plug>(coc-type-definition)', { silent = true })
vim.keymap.set('n', 'gi', '<Plug>(coc-implementation)', { silent = true })
vim.keymap.set('n', 'gr', '<Plug>(coc-references)', { silent = true })

-- Use K to show documentation in preview window.
function _G.show_docs()
  local cw = vim.fn.expand('<cword>')
  if vim.fn.index({ 'vim', 'help' }, vim.bo.filetype) >= 0 then
    vim.api.nvim_command('h ' .. cw)
  elseif vim.api.nvim_eval('coc#rpc#ready()') then
    vim.fn.CocActionAsync('doHover')
  else
    vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
  end
end

vim.keymap.set('n', 'gh', '<CMD>lua _G.show_docs()<CR>', { silent = true })

-- Highlight the symbol and its references when holding the cursor.
vim.api.nvim_create_augroup('CocGroup', {})
vim.api.nvim_create_autocmd('CursorHold', {
  group = 'CocGroup',
  command = "silent call CocActionAsync('highlight')",
  desc = 'Highlight symbol under cursor on CursorHold'
})

-- Symbol renaming.
vim.keymap.set('n', '<leader>rn', '<Plug>(coc-rename)', { silent = true })

-- Formatting selected code.
vim.keymap.set('x', '<leader>f', '<Plug>(coc-format-selected)', { silent = true })
vim.keymap.set('n', '<leader>f', '<Plug>(coc-format-selected)', { silent = true })

-- Setup formatexpr specified filetype(s).
vim.api.nvim_create_autocmd('FileType', {
  group = 'CocGroup',
  pattern = 'typescript,json',
  command = "setl formatexpr=CocAction('formatSelected')",
  desc = 'Setup formatexpr specified filetype(s).'
})

-- Update signature help on jump placeholder.
vim.api.nvim_create_autocmd('User', {
  group = 'CocGroup',
  pattern = 'CocJumpPlaceholder',
  command = "call CocActionAsync('showSignatureHelp')",
  desc = 'Update signature help on jump placeholder'
})

-- Applying codeAction to the selected region.
-- Example: `<leader>aap` for current paragraph
local opts = { silent = true, nowait = true }
vim.keymap.set('x', '<leader>a', '<Plug>(coc-codeaction-selected)', opts)
vim.keymap.set('n', '<leader>a', '<Plug>(coc-codeaction-selected)', opts)

-- Remap keys for applying codeAction to the current buffer.
vim.keymap.set('n', '<leader>ac', '<Plug>(coc-codeaction)', opts)

-- Apply AutoFix to problem on the current line.
vim.keymap.set('n', '<leader>qf', '<Plug>(coc-fix-current)', opts)

-- Run the Code Lens action on the current line.
vim.keymap.set('n', '<leader>cl', '<Plug>(coc-codelens-action)', opts)

-- Map function and class text objects
-- NOTE: Requires 'textDocument.documentSymbol' support from the language server.
vim.keymap.set('x', 'if', '<Plug>(coc-funcobj-i)', opts)
vim.keymap.set('o', 'if', '<Plug>(coc-funcobj-i)', opts)
vim.keymap.set('x', 'af', '<Plug>(coc-funcobj-a)', opts)
vim.keymap.set('o', 'af', '<Plug>(coc-funcobj-a)', opts)
vim.keymap.set('x', 'ic', '<Plug>(coc-classobj-i)', opts)
vim.keymap.set('o', 'ic', '<Plug>(coc-classobj-i)', opts)
vim.keymap.set('x', 'ac', '<Plug>(coc-classobj-a)', opts)
vim.keymap.set('o', 'ac', '<Plug>(coc-classobj-a)', opts)

-- Remap <C-f> and <C-b> for scroll float windows/popups.
---@diagnostic disable-next-line: redefined-local
local opts = { silent = true, nowait = true, expr = true }
vim.keymap.set('n', '<C-f>', 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
vim.keymap.set('n', '<C-b>', 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)
vim.keymap.set('i', '<C-f>',
  'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
vim.keymap.set('i', '<C-b>',
  'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
vim.keymap.set('v', '<C-f>', 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
vim.keymap.set('v', '<C-b>', 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)

-- Use CTRL-S for selections ranges.
-- Requires 'textDocument/selectionRange' support of language server.
vim.keymap.set('n', '<C-s>', '<Plug>(coc-range-select)', { silent = true })
vim.keymap.set('x', '<C-s>', '<Plug>(coc-range-select)', { silent = true })

-- Add `:Format` command to format current buffer.
vim.api.nvim_create_user_command('Format', "call CocAction('format')", {})

-- " Add `:Fold` command to fold current buffer.
vim.api.nvim_create_user_command('Fold', "call CocAction('fold', <f-args>)", { nargs = '?' })

-- Add `:OR` command for organize imports of the current buffer.
vim.api.nvim_create_user_command('OR', "call CocActionAsync('runCommand', 'editor.action.organizeImport')", {})

-- Add (Neo)Vim's native statusline support.
-- NOTE: Please see `:h coc-status` for integrations with external plugins that
-- provide custom statusline: lightline.vim, vim-airline.
-- vim.opt.statusline:prepend("%{coc#status()}%{get(b:,'coc_current_function','')}")

-- Mappings for CoCList
-- code actions and coc stuff
---@diagnostic disable-next-line: redefined-local
local opts = { silent = true, nowait = true }
-- Show all diagnostics.
vim.keymap.set('n', '<space>a', ':<C-u>CocList diagnostics<cr>', opts)
-- Manage extensions.
vim.keymap.set('n', '<space>e', ':<C-u>CocList extensions<cr>', opts)
-- Show commands.
vim.keymap.set('n', '<space>c', ':<C-u>CocList commands<cr>', opts)
-- Find symbol of current document.
vim.keymap.set('n', '<space>o', ':<C-u>CocList outline<cr>', opts)
-- Search workspace symbols.
vim.keymap.set('n', '<space>s', ':<C-u>CocList -I symbols<cr>', opts)
-- Do default action for next item.
vim.keymap.set('n', '<space>j', ':<C-u>CocNext<cr>', opts)
-- Do default action for previous item.
vim.keymap.set('n', '<space>k', ':<C-u>CocPrev<cr>', opts)
-- Resume latest coc list.
vim.keymap.set('n', '<space>p', ':<C-u>CocListResume<cr>', opts)

vim.keymap.set('n', [[\v]], ':CocOutline<CR>', { silent = true, noremap = true })

-- ===
-- === easymotion/vim-easymotion
-- ===
vim.g.EasyMotion_smartcase = 1
vim.g.EasyMotion_keys = 'qwertyuiopasdfghjklzxcvbnm'

-- ===
-- === kevinhwang91/rnvimr
-- ===
vim.g.rnvimr_enable_ex = 1
vim.g.rnvimr_enable_picker = 1
vim.g.rnvimr_enable_bw = 1
vim.cmd('hi link NormalFloat NONE')
vim.g.rnvimr_action = {
  ['<CR>'] = 'NvimEdit tabedit',
  ['<C-x>'] = 'NvimEdit split',
  ['<C-v>'] = 'NvimEdit vsplit',
}
vim.keymap.set('n', [[\r]], ':RnvimrToggle<CR>', { silent = true, noremap = true })

-- ===
-- === itchyny/lightline.vim
-- ===
vim.g.lightline = { colorscheme = 'wombat', }

-- ===
-- === kdheepak/lazygit.nvim
-- ===
vim.keymap.set('n', [[\g]], ':LazyGit<CR>', { silent = true, noremap = true })

-- ===
-- === mg979/vim-tabline
-- ===
vim.g.xtabline_settings = {
  enable_mappings = 0,
  tab_number_in_left_corner = 0,
}

-- ===
-- === nvim-telescope/telescope.nvim
-- ===
require('telescope').setup {
  defaults = {
    -- layout_strategy = 'horizontal',
    path_display = { 'smart' },
    -- sorting_strategy = 'ascending',
    mappings = {
      i = {
        ['<C-j>'] = require('telescope.actions').move_selection_next,
        ['<C-k>'] = require('telescope.actions').move_selection_previous,
        ['<C-u>'] = require('telescope.actions').preview_scrolling_up,
        ['<C-d>'] = require('telescope.actions').preview_scrolling_down,
      }
    },
    -- layout_config = {
    --   horizontal = {
    --     preview_cutoff = 100,
    --     preview_width = 0.6,
    --     preview = true
    --   },
    -- },
  },
  -- pickers = {
  --   -- Default configuration for builtin pickers goes here:
  --   -- picker_name = {
  --   --   picker_config_key = value,
  --   --   ...
  --   -- }
  --   -- Now the picker_config_key will be applied every time you call this
  --   -- builtin picker
  -- },
  extensions = {
    -- Your extension configuration goes here:
    file_browser = {
      grouped = true,
    }
  }
}
vim.keymap.set('n', [[\f]], ':Telescope find_files<CR>', { silent = true, noremap = true })
vim.keymap.set('n', [[\b]], ':Telescope buffers<CR>', { silent = true, noremap = true })
vim.keymap.set('n', [[\s]], ':Telescope live_grep<CR>', { silent = true, noremap = true })

-- ===
-- === nvim-telescope/telescope-fzf-native.nvim
-- ===
require('telescope').load_extension('fzf')

-- ===
-- === voldikss/vim-floaterm
-- ===
vim.keymap.set('n', [[<C-\>]], ':FloatermToggle<CR>', { silent = true, noremap = true })
vim.keymap.set('t', [[<C-[>]], [[<C-\><C-n>]], { silent = true, noremap = true })
vim.keymap.set('t', [[<C-\>]], [[<C-\><C-n>:FloatermToggle<CR>]], { silent = true, noremap = true })

-- ===
-- === glepnir/dashboard-nvim
-- ===
-- require('dashboard').custom_header = {
--   ' ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗',
--   ' ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║',
--   ' ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║',
--   ' ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║',
--   ' ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║',
--   ' ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝',
-- }
-- require('dashboard').custom_center = {
--   { icon = '  ',
--     desc = 'New  file                               ',
--     action = 'DashboardNewFile',
--     shortcut = 'SPC f n' },
--   { icon = '  ',
--     desc = 'File Browser                            ',
--     action = 'RnvimrToggle',
--     shortcut = 'SPC f b' },
--   { icon = '  ',
--     desc = 'Find  File                              ',
--     action = 'Telescope find_files find_command=rg,--hidden,--files',
--     shortcut = 'SPC f f' },
--   { icon = '  ',
--     desc = 'Find  word                              ',
--     action = 'Telescope live_grep',
--     shortcut = 'SPC f w' },
--   { icon = '  ',
--     desc = 'Open Personal vimfiles                  ',
--     action = 'e ~/.config/nvim/init.lua',
--     shortcut = 'SPC f d' },
-- }
-- require('dashboard').hide_statusline = false
-- require('dashboard').hide_tabline = false
-- require('dashboard').hide_winbar = false

-- ===
-- === lukas-reineke/indent-blankline.nvim
-- ===
vim.g.indentLine_fileTypeExclude = { 'startify' }

-- ===
-- === nvim-telescope/telescope-file-browser.nvim
-- ===
require('telescope').load_extension('file_browser')
vim.keymap.set('n', [[\e]], [[:Telescope file_browser<CR>]], { silent = true, noremap = true })

