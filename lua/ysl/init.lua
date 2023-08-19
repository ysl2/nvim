local _, S = pcall(require, 'ysl.secret') -- Load machine specific secrets.
local U = require('ysl.utils')
-- =============
-- === Basic ===
-- =============
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.termguicolors = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.scrolloff = 1
vim.opt.maxmempattern = 2000
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 300
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'lua', 'json', 'markdown', 'sshconfig', 'vim', 'yaml' },
  callback = function()
    vim.opt.tabstop = 2
  end
})
vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    vim.opt.shiftwidth = vim.opt.tabstop._value
  end
})
vim.opt.shm = vim.opt.shm._value .. 'I'
vim.opt.timeoutlen = 300
vim.opt.writebackup = false
-- Use `winblend` to control the transparency, `0` for opaque.
vim.opt.winblend = U.set(U.safeget(S, { 'config', 'vim', 'opt', 'winblend' }), 0)
vim.opt.pumblend = vim.opt.winblend._value
vim.g.neovide_transparency = 1 - vim.opt.winblend._value / 100
vim.g.neovide_cursor_animation_length = 0
vim.api.nvim_create_autocmd('BufWritePre', {
  command = 'set ff=unix'
})
vim.opt.guicursor = ''
vim.opt.smartindent = true
vim.opt.cursorline = true
vim.opt.exrc = true
vim.opt.foldmethod = 'indent'
vim.opt.foldlevel = 99
vim.opt.foldenable = true
vim.opt.foldlevelstart = 99
vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    -- https://neovim.io/doc/user/api.html#nvim_set_hl()
    vim.api.nvim_set_hl(0, 'NormalFloat', { link = 'none' })
    vim.api.nvim_set_hl(0, 'Visual', { reverse = true })
  end
})

vim.keymap.set('n', '<SPACE>', '')
vim.g.mapleader = ' '
vim.keymap.set('i', '<C-c>', '<C-[>', { silent = true })
vim.keymap.set('n', '<C-a>', '')
vim.keymap.set('n', '<C-z>', '<C-a>', { silent = true })
vim.keymap.set('t', '<A-[>', [[<C-\><C-n>]], { silent = true })
vim.keymap.set('t', '<ESC>', '<ESC>', { silent = true })
vim.keymap.set('t', '<C-c>', '<C-c>', { silent = true })
-- For rename variables.
vim.keymap.set('i', '<A-b>', '<Left>', { silent = true })
vim.keymap.set('i', '<A-f>', '<Right>', { silent = true })
-- :h cmdline-editing
-- :h emacs-keys
vim.cmd([[
	" start of line
	:cnoremap <C-A>		<Home>
	" back one character
	:cnoremap <C-B>		<Left>
	" delete character under cursor
	:cnoremap <C-D>		<Del>
	" end of line
	:cnoremap <C-E>		<End>
	" forward one character
	:cnoremap <C-F>		<Right>
	" recall newer command-line
	:cnoremap <C-N>		<Down>
	" recall previous (older) command-line
	:cnoremap <C-P>		<Up>
	" back one word
	:cnoremap <A-b>	<S-Left>
	" forward one word
	:cnoremap <A-f>	<S-Right>
]])

function _G.my_custom_check_no_name_buffer(cmdstr)
  if vim.fn.empty(vim.fn.bufname(vim.fn.bufnr())) == 1 then
    return
  end
  vim.cmd(cmdstr)
end

vim.keymap.set('n', '<C-w><C-h>', '<CMD>lua my_custom_check_no_name_buffer("bel vs | silent! b# | winc p")<CR>',
  { silent = true })
vim.keymap.set('n', '<C-w><C-j>', '<CMD>lua my_custom_check_no_name_buffer("abo sp | silent! b# | winc p")<CR>',
  { silent = true })
vim.keymap.set('n', '<C-w><C-k>', '<CMD>lua my_custom_check_no_name_buffer("bel sp | silent! b# | winc p")<CR>',
  { silent = true })
vim.keymap.set('n', '<C-w><C-l>', '<CMD>lua my_custom_check_no_name_buffer("abo vs | silent! b# | winc p")<CR>',
  { silent = true })

-- Auto delete [No Name] buffers.
if not vim.g.vscode then
  vim.api.nvim_create_autocmd('BufLeave', {
    callback = function()
      local buffers = vim.fn.filter(vim.fn.range(1, vim.fn.bufnr('$')),
        'buflisted(v:val) && empty(bufname(v:val)) && bufwinnr(v:val) < 0 && (getbufline(v:val, 1, "$") == [""])')
      local next = next
      if next(buffers) == nil then
        return
      end
      local cmdstr = ':silent! bw!'
      for _, v in pairs(buffers) do
        cmdstr = cmdstr .. ' ' .. v
      end
      vim.cmd(cmdstr)
    end
  })
end

-- Switch wrap mode.
vim.opt.wrap = false
local function _my_custom_toggle_wrap(opts)
  if #opts.fargs > 1 then
    print('Too many arguments.')
    return
  end
  if #opts.fargs == 1 then
    local m = U.TOBOOLEAN[opts.fargs[1]]
    if m == nil then
      print('Bad argument.')
      return
    else
      vim.opt.wrap = m
    end
  else
    vim.opt.wrap = not vim.opt.wrap._value
  end
  if vim.opt.wrap._value then
    vim.keymap.set({'n', 'v'}, 'j', 'gj', { silent = true })
    vim.keymap.set({'n', 'v'}, 'k', 'gk', { silent = true })
  else
    vim.keymap.del({'n', 'v'}, 'j')
    vim.keymap.del({'n', 'v'}, 'k')
  end
  print('vim.opt.wrap = ' .. tostring(vim.opt.wrap._value))
end
vim.api.nvim_create_user_command('MyWrapToggle', _my_custom_toggle_wrap, {
  nargs = '*',
  complete = function(arglead, cmdline, cursorpos)
    local cmp = {}
    for k, _ in pairs(U.TOBOOLEAN) do
      if k:sub(1, #arglead) == arglead then
        cmp[#cmp + 1] = k
      end
    end
    return cmp
  end
})


-- ===============
-- === Plugins ===
-- ===============
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'git@git.zhlh6.cn:ysl2/lazy.nvim.git',
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

local function _my_custom_load(plugins)
  require('lazy').setup(plugins, {
    -- defaults = { lazy = true }
    performance = {
      rtp = {
        disabled_plugins = {
          'editorconfig',
          'gzip',
          'man',
          'matchit',
          'matchparen',
          'netrwPlugin',
          'nvim',
          'rplugin',
          'shada',
          'spellfile',
          'tarPlugin',
          'tohtml',
          'tutor',
          'zipPlugin',
        }
      }
    }
  })
end

local M = {}

-- ===
-- === Load VSCode
-- ===
vim.list_extend(M, {
  {
    'kylechui/nvim-surround',
    version = '*', -- Use for stability; omit to use `main` branch for the latest features
    event = 'VeryLazy',
    config = function()
      require('nvim-surround').setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  },
  {
    'numToStr/Comment.nvim',
    event = 'VeryLazy',
    dependencies = {
      'JoosepAlviste/nvim-ts-context-commentstring',
    },
    config = function()
      require('Comment').setup({
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
      })
    end,
  },
  {
    'RRethy/vim-illuminate',
    event = 'VeryLazy',
    config = function()
      require('illuminate').configure({
        providers = {
          'regex',
        },
      })
    end
  },
  {
    'phaazon/hop.nvim',
    event = 'VeryLazy',
    keys = {
      { '<Leader><Leader>', '<CMD>silent! HopChar1MW<CR>',   mode = '', silent = true },
      { '<Leader><TAB>',    '<CMD>silent! HopPatternMW<CR>', mode = '', silent = true }
    },
    config = function()
      require('hop').setup()
    end
  },
})

if vim.g.vscode then
  _my_custom_load(M)
  return
end

-- ===
-- === Load Secret
-- ===
M[#M + 1] = U.set(U.safeget(S, 'colorscheme'),
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('tokyonight').setup({
        lualine_bold = true
      })
      vim.cmd.colorscheme('tokyonight')
    end
  })

local requires = U.set(U.safeget(S, 'requires'), {
  'ysl.lsp.nvim_lsp'
})
local lsp = U.greplist(requires, 'ysl%.lsp.*')

for _, v in ipairs(requires) do
  vim.list_extend(M, require(v))
end

vim.list_extend(M, U.set(U.safeget(S, 'plugins'), {}))

-- ===
-- === Load Others
-- ===
vim.list_extend(M, {
  { 'Asheq/close-buffers.vim',             cmd = 'Bdelete' },
  { 'romainl/vim-cool',                    event = 'VeryLazy' },
  { 'tpope/vim-fugitive',                  cmd = 'Git' },
  {
    'lewis6991/gitsigns.nvim',
    event = 'VeryLazy',
    config = function()
      require('gitsigns').setup()
    end,
  },
  { 'NvChad/nvim-colorizer.lua',         config = function() require('colorizer').setup() end, event = 'VeryLazy' },
  {
    'folke/todo-comments.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-lua/plenary.nvim', lazy = true },
    config = function() require('todo-comments').setup {} end,
  },
  { 'ysl2/bufdelete.nvim',        cmd = 'Bd' },
  { 'dhruvasagar/vim-table-mode', ft = { 'markdown' } },
  { 'mzlogin/vim-markdown-toc',   ft = 'markdown' },
  { 'mg979/vim-visual-multi', event = 'VeryLazy' },
  { 'ysl2/vim-bookmarks',
    event = 'VeryLazy',
    keys = {
      { 'mm', '<CMD>BookmarkToggle<CR>', mode = 'n', silent = true },
      { 'mi', '<CMD>BookmarkAnnotate<CR>', mode = 'n', silent = true },
      { 'mA', '<CMD>BookmarkShowAll<CR>', mode = 'n', silent = true },
      { 'gM', '<CMD>BookmarkPrev<CR>', mode = 'n', silent = true },
      { 'gm', '<CMD>BookmarkNext<CR>', mode = 'n', silent = true },
    }
  },
  { 'itchyny/calendar.vim',   cmd = 'Calendar' },
  { 'kevinhwang91/nvim-bqf',  ft = 'qf',                             dependencies = 'nvim-treesitter/nvim-treesitter' },
  { 'jspringyc/vim-word',     cmd = { 'WordCountLine', 'WordCount' } },
  { 'rafamadriz/friendly-snippets', event = 'VeryLazy' },
  {
    'is0n/fm-nvim',
    keys = {
       { '<Leader>l', '<CMD>Lf<CR>', mode = 'n', silent = true },
    },
    config = function()
      require('fm-nvim').setup{
        -- UI Options
        ui = {
          float = {
            -- Floating window border (see ':h nvim_open_win')
            border    = 'single',
            -- Highlight group for floating window/border (see ':h winhl')
            float_hl  = 'NormalFloat',
            -- Floating Window Transparency (see ':h winblend')
            blend     = vim.opt.winblend._value,
          },
        },
        -- Mappings used with the plugin
        mappings = {
          horz_split = '<C-s>',
        },
        -- Path to broot config
        broot_conf = vim.fn.stdpath('data') .. '/lazy/fm-nvim/assets/broot_conf.json'
      }
    end
  },
  {
    'nvim-treesitter/nvim-treesitter',
    event = 'VeryLazy',
    build = function()
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end,
    dependencies = {
      'windwp/nvim-ts-autotag',
      'JoosepAlviste/nvim-ts-context-commentstring',
      'nvim-treesitter/playground',
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    config = function()
      local nvim_treesitter_install = require('nvim-treesitter.install')
      nvim_treesitter_install.prefer_git = true
      nvim_treesitter_install.compilers = { 'clang', 'gcc' }
      local parsers = require('nvim-treesitter.parsers').get_parser_configs()
      for _, p in pairs(parsers) do
        p.install_info.url = p.install_info.url:gsub(
          'https://github.com/',
          'git@git.zhlh6.cn:'
        )
      end

      require('nvim-treesitter.configs').setup {
        -- A list of parser names, or "all"
        ensure_installed = { 'vim', 'query', 'lua', 'python' },

        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,

        -- Automatically install missing parsers when entering buffer
        -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
        auto_install = false,

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
          disable = {},
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
        autotag = { enable = true },
        context_commentstring = {
          enable = true,
          enable_autocmd = false,
        },
        playground = { enable = true },
        textobjects = {
          select = {
            enable = true,

            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,

            keymaps = {
              -- You can use the capture groups defined in textobjects.scm
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              -- You can optionally set descriptions to the mappings (used in the desc parameter of
              -- nvim_buf_set_keymap) which plugins like which-key display
              ['ic'] = { query = '@class.inner', desc = 'Select inner part of a class region' },
              -- You can also use captures from other query groups like `locals.scm`
              ['as'] = { query = '@scope', query_group = 'locals', desc = 'Select language scope' },
            },
            -- You can choose the select mode (default is charwise 'v')
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * method: eg 'v' or 'o'
            -- and should return the mode ('v', 'V', or '<c-v>') or a table
            -- mapping query_strings to modes.
            selection_modes = {
              ['@parameter.outer'] = 'v', -- charwise
              ['@function.outer'] = 'V', -- linewise
              ['@class.outer'] = '<c-v>', -- blockwise
            },
            -- If you set this to `true` (default is `false`) then any textobject is
            -- extended to include preceding or succeeding whitespace. Succeeding
            -- whitespace has priority in order to act similarly to eg the built-in
            -- `ap`.
            --
            -- Can also be a function which gets passed a table with the keys
            -- * query_string: eg '@function.inner'
            -- * selection_mode: eg 'v'
            -- and should return true of false
            include_surrounding_whitespace = false,
          }
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<CR>', -- set to `false` to disable one of the mappings
            node_incremental = '<CR>',
            scope_incremental = '<C-CR>',
            node_decremental = '<A-CR>',
          },
        },
      }
    end
  },
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    cmd = 'Telescope',
    keys = {
      { '<LEADER>f', '<CMD>Telescope find_files<CR>',                 mode = 'n', silent = true },
      { '<LEADER>F', "<CMD>lua require('telescope.builtin').find_files({ find_command = {'rg', '--files', '--hidden', '--no-ignore', '-g', '!.git' }})<CR>",     mode = 'n', silent = true },
      { '<LEADER>b', '<CMD>Telescope buffers<CR>',                    mode = 'n', silent = true },
      { '<LEADER>s', '<CMD>Telescope live_grep<CR>',                  mode = 'n', silent = true },
      { '<LEADER>G', '<CMD>Telescope git_status<CR>',                 mode = 'n', silent = true },
      { '<LEADER>m', '<CMD>Telescope vim_bookmarks current_file<CR>', mode = 'n', silent = true },
      { '<LEADER>M', '<CMD>Telescope vim_bookmarks all<CR>',          mode = 'n', silent = true },
      {
        '<Leader>/', function()
          require('telescope.builtin').current_buffer_fuzzy_find()
        end, mode = 'n', silent = true
      }
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = (vim.fn.has('win32') == 0) and 'make' or
            'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
      },
      'xiyaowong/telescope-emoji.nvim',
      'ysl2/telescope-vim-bookmarks.nvim'
    },
    config = function()
      local telescope = require('telescope')
      local telescope_actions = require('telescope.actions')
      telescope.setup {
        defaults = {
          layout_strategy = 'vertical',
          path_display = { 'tail' },
          sorting_strategy = 'ascending',
          mappings = {
            i = {
              ['<C-j>'] = telescope_actions.move_selection_next,
              ['<C-k>'] = telescope_actions.move_selection_previous,
              ['<C-r>'] = require('telescope.actions.layout').toggle_preview,
              ['<C-x>'] = telescope_actions.delete_buffer
            }
          },
          layout_config = {
            vertical = {
              preview_cutoff = 0,
              prompt_position = 'top',
              mirror = true,
            },
          },
          preview = {
            hide_on_startup = true -- hide previewer when picker starts
          },
          dynamic_preview_title = true
        },
        pickers = {
          -- Default configuration for builtin pickers goes here:
          git_status = { preview = { hide_on_startup = false } },
          live_grep = { preview = { hide_on_startup = false } },
          -- Now the picker_config_key will be applied every time you call this
          -- builtin picker
        },
        extensions = {
          -- Your extension configuration goes here:
          coc = {
            prefer_locations = true, -- always use Telescope locations to preview definitions/declarations/implementations etc
          }
        }
      }
      telescope.load_extension('fzf')
      telescope.load_extension('emoji')
      telescope.load_extension('vim_bookmarks')

      vim.api.nvim_create_autocmd('User', {
        pattern = 'TelescopePreviewerLoaded',
        callback = function()
          vim.cmd('setlocal number')
        end
      })
    end
  },
  {
    'mbbill/undotree',
    event = { 'BufReadPost', 'BufNewFile' },
    keys = { { '<LEADER>u', '<CMD>UndotreeToggle<CR>', mode = 'n', silent = true } },
    config = function()
      vim.g.undotree_WindowLayout = 3
      vim.g.undotree_SetFocusWhenToggle = 1
      if vim.fn.has('persistent_undo') == 1 then
        local target_path = vim.fn.expand(vim.fn.stdpath('data') .. '/.undodir')
        if vim.fn.isdirectory(target_path) == 0 then
          vim.fn.mkdir(target_path, 'p')
        end
        vim.cmd("let &undodir='" .. target_path .. "'")
        vim.cmd('set undofile')
      end
    end
  },
  {
    (function() return vim.fn.has('win32') == 1 and 'ysl2' or 'nvim-tree' end)() .. '/nvim-tree.lua',
    keys = {
      { '<LEADER>e', '<CMD>NvimTreeToggle<CR>', mode = 'n', silent = true },
    },
    dependencies = { 'nvim-tree/nvim-web-devicons', lazy = true },
    config = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1

      local function on_attach(bufnr)
        local api = require('nvim-tree.api')

        local function opts(desc)
          return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        api.config.mappings.default_on_attach(bufnr)

        vim.keymap.set('n', 'H', '', { buffer = bufnr })
        vim.keymap.del('n', 'H', { buffer = bufnr })

        vim.keymap.set('n', 'l', api.node.open.edit, opts('Open'))
        vim.keymap.set('n', '<C-l>', api.tree.expand_all, opts('Expand All'))
        vim.keymap.set('n', 'h', api.node.navigate.parent_close, opts('Close Directory'))
        vim.keymap.set('n', 'g.', api.tree.toggle_hidden_filter, opts('Toggle Dotfiles'))
        vim.keymap.set('n', '<C-h>', api.tree.collapse_all, opts('Collapse'))
        vim.keymap.set('n', 'T', function()
          local node = api.tree.get_node_under_cursor()
          api.node.open.tab(node)
          vim.cmd.tabprev()
        end, opts('open_tab_silent'))

        vim.keymap.set('n', 't', function()
          local node = api.tree.get_node_under_cursor()
          vim.cmd('quit')
          api.node.open.tab(node)
        end, opts('open_tab_and_close_tree'))

        vim.keymap.set('n', '<C-t>', function()
          local node = api.tree.get_node_under_cursor()
          vim.cmd('wincmd l')
          api.node.open.tab(node)
        end, opts('open_tab_and_swap_cursor'))

        vim.keymap.set('n', '<C-s>', api.node.open.horizontal, opts('Open: Horizontal Split'))

      end

      require('nvim-tree').setup({
        on_attach = on_attach,
        renderer = {
          indent_markers = {
            enable = true,
          },
        },
        diagnostics = {
          enable = true,
          show_on_dirs = true,
          icons = {
            hint = U.SIGNS.Hint,
            info = U.SIGNS.Info,
            warning = U.SIGNS.Warn,
            error = U.SIGNS.Error,
          },
        },
        modified = {
          enable = true,
        },
        sync_root_with_cwd = true,
        respect_buf_cwd = true,
        update_focused_file = {
          enable = true,
          update_root = true
        },
        notify = { threshold = vim.log.levels.WARN },
        filters = { custom = { "^.git$" } }
      })
    end
  },
  {
    's1n7ax/nvim-window-picker',
    keys = {
      {
        '<C-w><C-w>',
        function()
          local picked_window_id = require('window-picker').pick_window() or vim.api.nvim_get_current_win()
          vim.api.nvim_set_current_win(picked_window_id)
        end,
        mode = 'n',
        silent = true,
        desc = 'Pick a window'
      }
    },
    version = '1.*',
    config = function()
      require('window-picker').setup({
        show_prompt = false,
        filter_rules = {
          bo = {
            filetype = { 'notify' }
          }
        }
      })
    end
  },
  {
    'akinsho/toggleterm.nvim',
    event = 'VeryLazy',
    keys = {
      { [[<C-\>]] },
      { '<LEADER>T', '<CMD>lua _G.my_plugin_toggleterm({})<CR>',                  mode = 'n', silent = true },
      { '<LEADER>g', "<CMD>lua _G.my_plugin_toggleterm({ cmd = 'lazygit' })<CR>", mode = 'n', silent = true },
      {
        '<LEADER>r',
        function()
          local ft = vim.opt.filetype._value
          local cmd

          local sep = U.SEP
          local dir = vim.fn.expand('%:p:h')
          local fileName = vim.fn.expand('%:t')
          local fileNameWithoutExt = vim.fn.expand('%:t:r')

          if ft == 'c' then
            local outfile = fileNameWithoutExt
            if vim.fn.has('win32') == 1 then
              outfile = outfile .. '.exe'
            end
            cmd = ('cd "%s" && clang %s -o %s && .%s%s'):format(dir, fileName, outfile, sep, outfile)
          elseif ft == 'markdown' then
            -- HACK: Download latex template for pandoc and put it into the correct path defined by each platform.
            --
            -- Download template: https://github.com/Wandmalfarbe/pandoc-latex-template
            -- Linux default location: /Users/USERNAME/.pandoc/templates/
            -- Windows default locathon: C:\Users\USERNAME\AppData\Roaming\pandoc\templates\
            -- Also you can specify your own path:
            -- ```
            -- pandoc --pdf-engine=xelatex --template=[path of the template.latex] newfile.md -o newfile.pdf
            -- ```
            local cjk = ''
            if vim.fn.has('win32') == 1 then
              cjk = ' -V CJKmainfont="Microsoft YaHei"'
            else
              -- sudo apt install texlive-full texlive-lang-chinese fonts-wqy-microhei
              cjk = ' -V CJKmainfont="WenQuanYi Micro Hei"'
            end
            local latex_template = (vim.fn.stdpath('config') .. sep .. 'templates' .. sep .. 'eisvogel.latex'):gsub('/',
              sep)
            cmd = ('cd "%s" && pandoc %s --pdf-engine=xelatex --template="%s"%s -o %s.pdf'):format(dir, fileName,
              latex_template,
              cjk, fileNameWithoutExt)
          elseif ft == 'python' then
            cmd = ('cd "%s" && python %s'):format(dir, fileName)
          elseif ft == 'java' then
            cmd = ('cd "%s" && javac %s && java %s'):format(dir, fileName, fileNameWithoutExt)
          elseif ft == 'sh' then
            cmd = ('cd "%s" && bash %s'):format(dir, fileName)
          end
          if cmd == nil then return end
          cmd = cmd:gsub('/', sep)
          _G.my_plugin_toggleterm({ cmd = cmd, close_on_exit = false })
        end,
        mode = 'n',
        silent = true
      },
    },
    config = function()
      if vim.fn.has('win32') == 1 then
        local powershell_options = {
          shell = (vim.fn.executable 'pwsh' == 1 and 'pwsh' or 'powershell') .. ' -NoLogo -ExecutionPolicy RemoteSigned',
          shellcmdflag = '-Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;',
          shellredir = '-RedirectStandardOutput %s -NoNewWindow -Wait',
          shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode',
          shellquote = '',
          shellxquote = '',
        }
        for option, value in pairs(powershell_options) do
          vim.opt[option] = value
        end
      end
      require('toggleterm').setup({
        open_mapping = [[<c-\>]],
        direction = 'float',
      })

      function _G.my_plugin_toggleterm(mytable)
        mytable.cmd = mytable.cmd or vim.fn.input('Enter command: ')
        mytable = vim.tbl_deep_extend('force', { hidden = true }, mytable)
        require('toggleterm.terminal').Terminal:new(mytable):toggle()
      end
    end
  },
  {
    'csexton/trailertrash.vim',
    event = 'VeryLazy',
    config = function()
      vim.cmd('hi link UnwantedTrailerTrash NONE')
      vim.api.nvim_create_autocmd('BufWritePre', {
        command = 'TrailerTrim'
      })
    end
  },
  {
    'ysl2/distant.nvim',
    branch = 'v0.2',
    keys = {
      {
        '<LEADER>dc',
        function()
          local hosts = U.safeget(S, { 'config', 'distant' })
          if not hosts then
            print('Missing host lists.')
            return
          end
          local idx = tonumber(vim.fn.input('Enter host idx: '))
          require('distant.command').connect(hosts[idx])
        end,
        mode = 'n',
        silent = true
      },
      {
        '<LEADER>do',
        function()
          local path = vim.fn.input('Enter path: ')
          require('distant.command').open({ args = { path }, opts = {} })
        end,
        mode = 'n',
        silent = true
      },
      { '<LEADER>ds', '<CMD>DistantShell<CR>', mode = 'n', silent = true }
    },
    config = function()
      require('distant').setup { ['*'] = require('distant.settings').chip_default() }
      -- HACK: If path contains whitespace, you should link .ssh folder to another place.
      --
      -- ```dos
      -- cd C:\Users\Public
      -- mklink /D .ssh "C:\Users\fa fa\.ssh"
      -- ```
      --
      -- HACK: Read variables from secret file.
      -- S.config.distant is a list type (also can be defined as a table that can give a host alia. By yourself.)
      -- e.g,
      --
      -- ```lua
      -- S.config = {
      --   distant = {
      --     {
      --       args = { 'ssh://user1@111.222.333.444:22' },
      --       opts = {
      --         options = {
      --           -- ['ssh.backend'] = 'libssh', -- No need to specify this. Just for example.
      --           ['ssh.user_known_hosts_files'] = 'C:\\Users\\Public\\.ssh\\known_hosts',
      --           ['ssh.identity_files'] = 'C:\\Users\\Public\\.ssh\\id_rsa'
      --         }
      --       }
      --     },
      --     {
      --       args = { 'ssh://user2@127.0.0.1:2233' },
      --       opts = {} -- Or leave it empty on Linux.
      --     }
      --   }
      -- }
      -- ```
    end
  },
  {
    'ysl2/img-paste.vim',
    ft = 'markdown',
    keys = {
      { '<LEADER>p', '<CMD>call mdip#MarkdownClipboardImage()<CR><ESC>', mode = 'n', silent = true },
    },
    config = function()
      vim.api.nvim_create_autocmd('BufEnter', {
        pattern = '*.md',
        callback = function()
          vim.g.mdip_imgdir = 'assets' .. '/' .. vim.fn.expand('%:t:r') .. '/' .. 'images'
          vim.g.mdip_imgdir_intext = vim.g.mdip_imgdir
        end
      })
    end
  },
  {
    'ysl2/neovim-session-manager',
    lazy = false,
    cmd = 'SessionManager',
    keys = {
      { '<LEADER>o', '<CMD>SessionManager load_session<CR>',   mode = 'n', silent = true },
      { '<LEADER>O', '<CMD>SessionManager delete_session<CR>', mode = 'n', silent = true }
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'stevearc/dressing.nvim', lazy = true, config = function() require('dressing').setup {} end },
    },
    config = function()
      require('session_manager').setup({
        autoload_mode = require('session_manager.config').AutoloadMode.CurrentDir
      })

      vim.api.nvim_create_autocmd('VimEnter', {
        callback = function()
          if vim.fn.has('win32') == 1 then
            vim.cmd('silent! cd %:p:h')
            -- An empty file will be opened if you use right mouse click. So `bw!` to delete it.
            -- Once you delete the empty buffer, netrw won't popup. So you needn't do `vim.cmd('silent! au! FileExplorer *')` to silent netrw.
            vim.cmd('silent! bw!')
          end
          -- vim.fn.argc() is 1 (not 0) if you open from right mouse click on windows platform.
          -- So it can't be an instance that can be treated as in a workspace.
          if vim.fn.has('win32') == 1 or vim.fn.argc() == 0 then
            vim.cmd('silent! SessionManager load_current_dir_session')
          end
        end
      })
    end
  },
  {
    'ysl2/leetcode.vim',
    keys = {
      { '<leader>Ll', '<CMD>LeetCodeList<CR>',   mode = 'n', silent = true },
      { '<leader>Lt', '<CMD>LeetCodeTest<CR>',   mode = 'n', silent = true },
      { '<leader>Ls', '<CMD>LeetCodeSubmit<CR>', mode = 'n', silent = true },
      { '<leader>Li', '<CMD>LeetCodeSignIn<CR>', mode = 'n', silent = true }
    },
    config = function()
      vim.g.leetcode_china = 0
      vim.g.leetcode_browser = 'chrome'
      vim.g.leetcode_solution_filetype = 'python'
    end
  },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function()
      require('which-key').setup({
        plugins = {
          marks = false,     -- shows a list of your marks on ' and `
          registers = false, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
          presets = {
            operators = false
          }
        }
      })
    end,
  },
  {
    'glacambre/firenvim',
    build = function() vim.fn['firenvim#install'](0) end,
    -- Lazy load firenvim
    -- Explanation: https://github.com/folke/lazy.nvim/discussions/463#discussioncomment-4819297
    cond = not not vim.g.started_by_firenvim,
    config = function()
      vim.cmd('set guifont=consolas:h20')
      vim.cmd('set laststatus=0')
      vim.api.nvim_create_autocmd('BufEnter', {
        pattern = { 'github.com_*.txt', 'gitee.com_*.txt' },
        command = 'set filetype=markdown'
      })
      vim.api.nvim_create_autocmd('BufEnter', {
        pattern = { 'leetcode.com_*.txt', 'leetcode.cn_*.txt' },
        command = 'set filetype=python'
      })
      vim.g.firenvim_config = {
        localSettings = {
          -- ['https?://[^/]+\\.zhihu\\.com/*'] = { priority = 1, takeover = 'never' },
          -- ['https?://www\\.notion\\.so/*'] = { priority = 1, takeover = 'never' },
          -- ['https?://leetcode\\.com.*playground.*shared'] = { priority = 1, takeover = 'never' },
          -- ['https?://github1s\\.com/*'] = { priority = 1, takeover = 'never' },
          -- ['https?://docs\\.qq\\.com/*'] = { priority = 1, takeover = 'never' },
          -- ['.*'] = { priority = 0 },
          ['.*'] = { priority = 1, takeover = 'never' },
        }
      }
    end
  },
  {
    'ethanholz/nvim-lastplace',
    event = 'VeryLazy',
    config = function()
      require 'nvim-lastplace'.setup {
        lastplace_ignore_buftype = { 'quickfix', 'nofile', 'help' },
        lastplace_ignore_filetype = { 'gitcommit', 'gitrebase', 'svn', 'hgcommit' },
        lastplace_open_folds = true
      }
    end
  },
  {
    'chrisbra/csv.vim',
    ft = 'csv',
    config = function()
      vim.g.csv_arrange_align = 'l*'
    end
  },
  {
    'ahmedkhalf/project.nvim',
    lazy = false,
    config = function()
      require('project_nvim').setup({
        detection_methods = { 'pattern' },
        patterns = { '.git', '.root' },
      })
    end,
  },
  {
    'xiyaowong/nvim-transparent',
    cond = (not (vim.opt.winblend._value == 0)) and (not vim.g.started_by_firenvim),
    lazy = false,
    config = function()
      require('transparent').setup({
        extra_groups = { -- table/string: additional groups that should be cleared
          -- In particular, when you set it to 'all', that means all available groups
          'lualine_a_inactive',
          'lualine_b_visual',
          'lualine_b_replace',
          'lualine_b_insert',
          'lualine_b_command',
          'lualine_b_terminal',
          'lualine_b_inactive',
          'lualine_b_normal',
          'lualine_c_visual',
          'lualine_c_replace',
          'lualine_c_insert',
          'lualine_c_command',
          'lualine_c_terminal',
          'lualine_c_inactive',
          'lualine_c_normal',
          'lualine_b_diff_added_normal',
          'lualine_b_diff_added_insert',
          'lualine_b_diff_added_visual',
          'lualine_b_diff_added_replace',
          'lualine_b_diff_added_command',
          'lualine_b_diff_added_terminal',
          'lualine_b_diff_added_inactive',
          'lualine_b_diff_modified_normal',
          'lualine_b_diff_modified_insert',
          'lualine_b_diff_modified_visual',
          'lualine_b_diff_modified_replace',
          'lualine_b_diff_modified_command',
          'lualine_b_diff_modified_terminal',
          'lualine_b_diff_modified_inactive',
          'lualine_b_diff_removed_normal',
          'lualine_b_diff_removed_insert',
          'lualine_b_diff_removed_visual',
          'lualine_b_diff_removed_replace',
          'lualine_b_diff_removed_command',
          'lualine_b_diff_removed_terminal',
          'lualine_b_diff_removed_inactive',
          'lualine_b_diagnostics_error_normal',
          'lualine_b_diagnostics_error_insert',
          'lualine_b_diagnostics_error_visual',
          'lualine_b_diagnostics_error_replace',
          'lualine_b_diagnostics_error_command',
          'lualine_b_diagnostics_error_terminal',
          'lualine_b_diagnostics_error_inactive',
          'lualine_b_diagnostics_warn_normal',
          'lualine_b_diagnostics_warn_insert',
          'lualine_b_diagnostics_warn_visual',
          'lualine_b_diagnostics_warn_replace',
          'lualine_b_diagnostics_warn_command',
          'lualine_b_diagnostics_warn_terminal',
          'lualine_b_diagnostics_warn_inactive',
          'lualine_b_diagnostics_info_normal',
          'lualine_b_diagnostics_info_insert',
          'lualine_b_diagnostics_info_visual',
          'lualine_b_diagnostics_info_replace',
          'lualine_b_diagnostics_info_command',
          'lualine_b_diagnostics_info_terminal',
          'lualine_b_diagnostics_info_inactive',
          'lualine_b_diagnostics_hint_normal',
          'lualine_b_diagnostics_hint_insert',
          'lualine_b_diagnostics_hint_visual',
          'lualine_b_diagnostics_hint_replace',
          'lualine_b_diagnostics_hint_command',
          'lualine_b_diagnostics_hint_terminal',
          'lualine_b_diagnostics_hint_inactive',
          'NvimTreeNormal',
          'NvimTreeStatuslineNc',
          'NvimTreeWinSeparator',
          'NormalFloat',
          'Pmenu',
          'VertSplit',
        },
        exclude_groups = {}, -- table: groups you don't want to clear
        -- ignore_linked_group = true, -- boolean: don't clear a group that links to another group
      })
    end
  },
  {
    'ysl2/vim-colorscheme-switcher',
    dependencies = 'xolox/vim-misc',
    keys = {
      { '<A-_>', '<CMD>PrevColorScheme<CR>' },
      { '<A-+>', '<CMD>NextColorScheme<CR>' },
    },
    config = function()
      vim.g.colorscheme_switcher_define_mappings = 0
    end
  },
  {
    'iamcco/markdown-preview.nvim',
    build = 'cd app && yarn install',
    ft = 'markdown',
    config = function()
      -- vim.g.mkdp_port = '8080'
      vim.g.mkdp_open_to_the_world = 1
      vim.g.mkdp_echo_preview_url = 1
      vim.g.mkdp_open_ip = '127.0.0.1'
      vim.g.mkdp_theme = 'light'
    end
  },
  {
    'kevinhwang91/nvim-hlslens',
    dependencies = {
      'petertriho/nvim-scrollbar',
    },
    keys = {
      { '/' },
      { '?' },
      { 'n', function ()
        vim.cmd('normal! ' .. vim.v.count1 .. 'n')
        require('hlslens').start()
      end, mode = { 'n', 'v' }, silent = true },
      { 'N', function ()
        vim.cmd('normal! ' .. vim.v.count1 .. 'N')
        require('hlslens').start()
      end, mode = { 'n', 'v' }, silent = true },
      { '*', [[*<CMD>lua require('hlslens').start()<CR>]], mode = { 'n', 'v' }, silent = true },
      { '#', [[#<CMD>lua require('hlslens').start()<CR>]], mode = { 'n', 'v' }, silent = true },
      { 'g*', [[g*<CMD>lua require('hlslens').start()<CR>]], mode = { 'n', 'v' }, silent = true },
      { 'g#', [[g#<CMD>lua require('hlslens').start()<CR>]], mode = { 'n', 'v' }, silent = true },
    },
    config = function()
      -- require('hlslens').setup()
      require('scrollbar.handlers.search').setup({
          -- hlslens config overrides
      })
    end
  },
  {
    'nvim-pack/nvim-spectre',
    cmd = 'Spectre',
    opts = { open_cmd = 'noswapfile vnew' },
    dependencies = 'nvim-lua/plenary.nvim',
  },
  {
    'Bekaboo/dropbar.nvim',
    event = 'VeryLazy',
    config = function()
      require('dropbar').setup()
    end
  },
  {
    'shellRaining/hlchunk.nvim',
    event = 'VeryLazy',
    config = function ()
      local fg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID('CursorLineNr')), 'fg', 'gui')
      require('hlchunk').setup({
        chunk = {
          chars = {
              horizontal_line = "─",
              vertical_line = "│",
              left_top = "┌",
              left_bottom = "└",
              right_arrow = "─",
          },
          style = {
              { fg = fg }
          },
          notify = false
        },
        line_num = {
          use_treesitter = true,
          style = {
              { fg = fg }
          },
        },
        blank = {
          enable = false,
        },
      })
    end
  },
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'folke/noice.nvim',
    },
    config = function()

      local noice = require('noice')
      local function lualine_c()
        local result = { 'filename' }
        if lsp == 'ysl.lsp.coc' then
          result[#result+1] = 'g:coc_status'
        elseif lsp == 'ysl.lsp.nvim_lsp' then
          result[#result+1] = {
            function()
              return noice.api.status.lsp_progress.get_hl()
            end,
            cond = function()
              return noice.api.status.lsp_progress.has()
            end,
          }
        end
        return result
      end

      local lualine = require('lualine')

      lualine.setup({
        options = {
          section_separators = { left = '', right = '' },
          component_separators = { left = '', right = '' }
        },
        sections = {
          lualine_c = lualine_c(),
          lualine_x = {
            {
              'macro-recording',
              fmt = function()
                local temp = vim.fn.reg_recording()
                return temp == '' and '' or 'recording @' .. temp
              end,
            },
            'filesize', 'encoding', 'fileformat', 'filetype'
          },
        },
      })

      local function _my_plugin_lualine()
        lualine.refresh({ place = { 'statusline' }, })
      end

      vim.api.nvim_create_autocmd('RecordingEnter', {
        callback = _my_plugin_lualine,
      })

      vim.api.nvim_create_autocmd('RecordingLeave', {
        callback = function()
          -- This is going to seem really weird!
          -- Instead of just calling refresh we need to wait a moment because of the nature of
          -- `vim.fn.reg_recording`. If we tell lualine to refresh right now it actually will
          -- still show a recording occuring because `vim.fn.reg_recording` hasn't emptied yet.
          -- So what we need to do is wait a tiny amount of time (in this instance 50 ms) to
          -- ensure `vim.fn.reg_recording` is purged before asking lualine to refresh.
          local timer = vim.loop.new_timer()
          timer:start(50, 0,
            vim.schedule_wrap(_my_plugin_lualine)
          )
        end,
      })
    end
  },
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
          diagnostics = (function () return lsp == 'ysl.lsp.coc' and 'coc' or 'nvim_lsp' end)()
        }
      })
    end
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      local nvim_autopairs = require('nvim-autopairs')
      if lsp ~= 'ysl.lsp.coc' then
        nvim_autopairs.setup()
        return
      end
      nvim_autopairs.setup({ map_cr = false })
      _G.MUtils = {}
      MUtils.completion_confirm = function()
        if vim.fn['coc#pum#visible']() ~= 0 then
          return vim.fn['coc#pum#confirm']()
        else
          return nvim_autopairs.autopairs_cr()
        end
      end
      vim.keymap.set('i', '<CR>', 'v:lua.MUtils.completion_confirm()', { silent = true, expr = true })
    end
  },
  {
    (function() if lsp == 'ysl.lsp.coc' then return 'ysl2' else return 'simrat39' end end)() .. '/symbols-outline.nvim',
    keys = { { '<LEADER>v', '<CMD>SymbolsOutline<CR>', mode = 'n', silent = true } },
    config = function()
      require('symbols-outline').setup {}
    end
  },
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    keys = {
      { '<Leader>:', '<CMD>NoiceDismiss<CR>', mode = 'n', silent = true }
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      'MunifTanjim/nui.nvim',
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      'rcarriga/nvim-notify',
    },
    config = function()
      local format = {
        { '{data.progress.client} ', hl_group = 'CursorLineNr' },
        '({data.progress.percentage}%) ',
        { '{data.progress.title} ', hl_group = 'LineNr' },
      }
      require('noice').setup({
        lsp = {
          progress = {
            enabled = true,
            format = vim.list_extend({
              { '{spinner} ', hl_group = 'NoiceLspProgressSpinner' },
            }, format),
            format_done = vim.list_extend({
              { '✔ ', hl_group = 'NoiceLspProgressSpinner' },
            }, format),
          },
          -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
          override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
            ['cmp.entry.get_documentation'] = true,
          },
        },
        -- you can enable a preset for easier configuration
        presets = {
          command_palette = true, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
        },
        status = {
          lsp_progress = { event = 'lsp', kind = 'progress' }
        },
        routes = {
          {
            filter = {
              event = 'lsp',
              kind = 'progress'
            },
            opts = {
              skip = true
            }
          }
        },
      })

      vim.api.nvim_create_autocmd('LspProgress', {
        pattern = '*',
        command = 'redrawstatus'
      })

      vim.api.nvim_create_autocmd('LspAttach', {
        group = U.GROUP_NVIM_LSP,
        callback = function(ev)
          local noice_lsp = require('noice.lsp')
          vim.keymap.set({'n', 'i', 's'}, '<c-f>', function()
            if not noice_lsp.scroll(4) then
              return '<c-f>'
            end
          end, { silent = true, expr = true })

          vim.keymap.set({'n', 'i', 's'}, '<c-b>', function()
            if not noice_lsp.scroll(-4) then
              return '<c-b>'
            end
          end, { silent = true, expr = true })
        end
      })
    end
  },
  {
    'petertriho/nvim-scrollbar',
    event = 'VeryLazy',
    dependencies = {
      'lewis6991/gitsigns.nvim'
    },
    config = function()
      require('scrollbar').setup({
        handle = {
          color = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID('CursorLineNr')), 'fg', 'gui'),
        },
        marks = {
          Search = { color = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID('IncSearch')), 'bg', 'gui') },
        },
        handlers = {
          cursor = false,
        },
      })

      require('scrollbar.handlers.gitsigns').setup()
    end
  },
  {
    'gbprod/yanky.nvim',
    event = 'VeryLazy',
    keys = {
      { '<LEADER>y', '<CMD>Telescope yank_history<CR>', mode = 'n', silent = true },
      { 'p', '<Plug>(YankyPutAfter)', mode = { 'n', 'x' }, silent = true },
      { 'P', '<Plug>(YankyPutBefore)', mode = { 'n', 'x' }, silent = true },
      { 'gp', '<Plug>(YankyGPutAfter)', mode = { 'n', 'x' }, silent = true },
      { 'gP', '<Plug>(YankyGPutBefore)', mode = { 'n', 'x' }, silent = true },
      { '<A-n>', '<Plug>(YankyCycleForward)', mode = 'n', silent = true },
      { '<A-p>', '<Plug>(YankyCycleBackward)', mode = 'n', silent = true },
    },
    dependencies = {
      'kkharji/sqlite.lua',
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      require('telescope').load_extension('yank_history')

      local mapping = require('yanky.telescope.mapping')

      require('yanky').setup({
        ring = {
          history_length = vim.opt.maxmempattern._value,
          storage = 'sqlite',
        },
        picker = {
          telescope = {
            use_default_mappings = false,
            mappings = {
              i = {
                ['<CR>'] = mapping.put('p'),
                ['<A-p>'] = mapping.put('p'),
                ['<A-k>'] = mapping.put('P'),
                ['<C-x>'] = mapping.delete(),
                ['<A-r>'] = mapping.set_register(require('yanky.utils').get_default_register()),
              },
            },        -- nil to use default mappings or no mappings (see `use_default_mappings`)
          },
        },
        system_clipboard = {
          sync_with_ring = false,
        },
        highlight = {
          on_put = false,
          timer = vim.highlight.priorities.user,
        },
        preserve_cursor_position = {
          enabled = false,
        },
      })
    end
  },
  {
    'folke/zen-mode.nvim',
    keys = {
      { '<C-w>z', '<CMD>ZenMode<CR>', mode = 'n', silent = true },
    },
    cmd = 'ZenMode',
    config = function()
      require('zen-mode').setup({
        window = {
          width = 1,
        },
      })
    end
  },
  {
    'ysl2/vim-plugin-AnsiEsc',
    cmd = 'AnsiEsc',
    keys = {
      {
        '<Leader>A', function()
          local pos = vim.fn.getpos('.')
          local colors_name = vim.g.colors_name
          vim.cmd('silent! AnsiEsc')
          vim.fn.setpos('.', pos)
          vim.g.colors_name = colors_name
        end, mode = 'n', silent = true
      }
    },
  },
  {
    'folke/trouble.nvim',
    dependencies = 'nvim-tree/nvim-web-devicons',
    keys = {
      {
        '<Leader>x', function()
          local cmd = 'TroubleToggle'
          if lsp == 'ysl.lsp.coc' then
            cmd = [[
              call coc#rpc#request('fillDiagnostics', [bufnr('%')])
              TroubleToggle loclist
            ]]
          end
          vim.cmd(cmd)
        end, mode = 'n', silent = true
      }
    },
    config = function()
      if lsp == 'ysl.lsp.coc' then
        require("trouble").setup {
          position = "bottom", -- position of the list can be: bottom, top, left, right
          height = 8, -- height of the trouble list when position is top or bottom
          icons = true, -- use devicons for filenames
          auto_open = true, -- automatically open the list when you have diagnostics
          auto_close = true, -- automatically close the list when you have no diagnostics
          mode = "loclist"
        }
        return
      end
      require('trouble').setup()
    end
  }
})

_my_custom_load(M)
