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
vim.cmd('hi link NormalFloat NONE')
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

vim.keymap.set('n', '<SPACE>', '')
vim.g.mapleader = ' '
vim.keymap.set('i', '<C-c>', '<C-[>', { silent = true })
vim.keymap.set('n', '<C-a>', '')
vim.keymap.set('n', '<C-z>', '<C-a>', { silent = true })
vim.keymap.set('t', '<A-[>', [[<C-\><C-n>]], { silent = true })
vim.keymap.set('t', '<ESC>', '<ESC>', { silent = true })
vim.keymap.set('t', '<C-c>', '<C-c>', { silent = true })
vim.keymap.set('n', '<TAB>', function()
  vim.cmd('ccl')
  vim.cmd('lcl')
  vim.cmd('set cmdheight=1')
end, { silent = true })

function _G._my_wrapper_check_no_name_buffer(cmdstr)
  if vim.fn.empty(vim.fn.bufname(vim.fn.bufnr())) == 1 then
    return
  end
  vim.cmd(cmdstr)
end

vim.keymap.set('n', '<C-w><C-h>', '<CMD>lua _my_wrapper_check_no_name_buffer("bel vs | silent! b# | winc p")<CR>',
  { silent = true })
vim.keymap.set('n', '<C-w><C-j>', '<CMD>lua _my_wrapper_check_no_name_buffer("abo sp | silent! b# | winc p")<CR>',
  { silent = true })
vim.keymap.set('n', '<C-w><C-k>', '<CMD>lua _my_wrapper_check_no_name_buffer("bel sp | silent! b# | winc p")<CR>',
  { silent = true })
vim.keymap.set('n', '<C-w><C-l>', '<CMD>lua _my_wrapper_check_no_name_buffer("abo vs | silent! b# | winc p")<CR>',
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

-- Auto highlight after yank.
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end
})

-- Switch wrap mode.
vim.opt.wrap = false
local function _my_toggle_wrap(opts)
  if #opts.fargs > 1 then
    print('Too many arguments.')
    return
  end
  if #opts.fargs == 1 then
    local m = U.toboolean[opts.fargs[1]]
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
vim.api.nvim_create_user_command('MyWrapToggle', _my_toggle_wrap, {
  nargs = '*',
  complete = function(arglead, cmdline, cursorpos)
    local cmp = {}
    for k, _ in pairs(U.toboolean) do
      if k:sub(1, #arglead) == arglead then
        cmp[#cmp + 1] = k
      end
    end
    return cmp
  end
})


--- ===============
--- === Plugins ===
--- ===============
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

local function my_load(plugins)
  require('lazy').setup(plugins, {
    -- defaults = { lazy = true }
  })
end

local M = {}

-- ===
-- === Load VSCode
-- ===
vim.list_extend(M, {
  { 'tpope/vim-surround',     event = 'VeryLazy' },
  { 'numToStr/Comment.nvim',  config = function() require('Comment').setup() end, event = 'VeryLazy' },
  { 'itchyny/vim-cursorword', event = 'VeryLazy' },
  { 'RRethy/vim-illuminate',  event = 'VeryLazy' },
  {
    'phaazon/hop.nvim',
    event = 'VeryLazy',
    keys = {
      { '<LEADER><LEADER>', '<CMD>HopChar1MW<CR>',   mode = '', silent = true },
      { '<LEADER><TAB>',    '<CMD>HopPatternMW<CR>', mode = '', silent = true }
    },
    config = function()
      require('hop').setup()
    end
  },
  {
    'ggandor/leap.nvim',
    dependencies = 'tpope/vim-repeat',
    event = 'VeryLazy',
    config = function()
      require('leap').add_default_mappings()
      vim.keymap.del({ 'x', 'o' }, 'x')
      vim.keymap.del({ 'x', 'o' }, 'X')
    end
  }
})

if vim.g.vscode then
  my_load(M)
  return
end

-- ===
-- === Load Secret
-- ===
M[#M + 1] = U.set(U.safeget(S, 'colorscheme'),
  {
    'ysl2/nvim-deus',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd('colorscheme deus')
    end
  })

local requires = U.set(U.safeget(S, 'requires'), {
  require('ysl.lsp.coc')
})

for _, v in ipairs(requires) do
  vim.list_extend(M, v)
end

vim.list_extend(M, U.set(U.safeget(S, 'plugins'), {}))

vim.list_extend(M, {
  -- ===
  -- === Load Bulk
  -- ===
  { 'Asheq/close-buffers.vim',             cmd = 'Bdelete' },
  { 'lukas-reineke/indent-blankline.nvim', event = 'BufReadPost' },
  { 'romainl/vim-cool',                    event = 'VeryLazy' },
  { 'tpope/vim-fugitive',                  cmd = 'Git' },
  { 'lewis6991/gitsigns.nvim',             config = function() require('gitsigns').setup() end,  event = 'BufReadPost' },
  { 'norcalli/nvim-colorizer.lua',         config = function() require('colorizer').setup() end, event = 'BufReadPost' },
  {
    'folke/todo-comments.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    config = function() require('todo-comments').setup {} end,
    event = 'BufReadPost'
  },
  { 'ysl2/bufdelete.nvim',        cmd = 'Bd' },
  { 'dhruvasagar/vim-table-mode', ft = { 'markdown' } },
  { 'mzlogin/vim-markdown-toc',   ft = 'markdown' },
  {
    'dkarter/bullets.vim',
    ft = 'markdown',
    init = function()
      vim.g.bullets_custom_mappings = { { 'inoremap <expr>', '<CR>',
        'coc#pum#visible() ? coc#pum#confirm() : "<Plug>(bullets-newline)"' }, }
    end
  },
  { 'mg979/vim-visual-multi', event = 'BufReadPost' },
  { 'gcmt/wildfire.vim',      event = 'VeryLazy' },
  { 'ysl2/vim-bookmarks',     event = 'VeryLazy', },
  { 'itchyny/calendar.vim',   cmd = 'Calendar' },
  { 'kevinhwang91/nvim-bqf',  ft = 'qf',                             dependencies = 'nvim-treesitter/nvim-treesitter' },
  { 'jspringyc/vim-word',     cmd = { 'WordCountLine', 'WordCount' } },

  -- ===
  -- === Load Single
  -- ===
  {
    'wellle/tmux-complete.vim',
    cond = vim.fn.has('win32') == 0,
    event = 'VeryLazy'
  },
  {
    'kevinhwang91/rnvimr',
    cond = vim.fn.has('win32') == 0,
    keys = { { '<LEADER>r', '<CMD>RnvimrToggle<CR>', mode = 'n', silent = true } },
    config = function()
      vim.g.rnvimr_enable_picker = 1
      vim.g.rnvimr_enable_bw = 1
      vim.defer_fn(function()
        vim.cmd('RnvimrStartBackground')
      end, 1000)
      vim.g.rnvimr_action = {
        ['<CR>'] = 'NvimEdit tabedit',
        ['<C-x>'] = 'NvimEdit split',
        ['<C-v>'] = 'NvimEdit vsplit',
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
      'mrjones2014/nvim-ts-rainbow',
      'nvim-treesitter/playground',
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
        ensure_installed = { 'vim', 'query', 'lua' },

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
        context_commentstring = { enable = true },
        rainbow = { enable = true },
        playground = { enable = true }
      }
    end
  },
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    cmd = 'Telescope',
    keys = {
      { '<LEADER>f', '<CMD>Telescope find_files<CR>',                 mode = 'n', silent = true },
      { '<LEADER>b', '<CMD>Telescope buffers<CR>',                    mode = 'n', silent = true },
      { '<LEADER>s', '<CMD>Telescope live_grep<CR>',                  mode = 'n', silent = true },
      { '<LEADER>G', '<CMD>Telescope git_status<CR>',                 mode = 'n', silent = true },
      { '<LEADER>m', '<CMD>Telescope vim_bookmarks current_file<CR>', mode = 'n', silent = true },
      { '<LEADER>M', '<CMD>Telescope vim_bookmarks all<CR>',          mode = 'n', silent = true }
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
              ['<C-b>'] = telescope_actions.delete_buffer
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
          }
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
    lazy = false,
    keys = { { '<LEADER>u', '<CMD>UndotreeToggle<CR>', mode = 'n', silent = true } },
    config = function()
      vim.g.undotree_WindowLayout = 3
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
    'ysl2/nvim-tree.lua',
    name = 'nvim-tree',
    keys = { { '<LEADER>e', '<CMD>NvimTreeToggle<CR>', mode = 'n', silent = true } },
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      local api = require('nvim-tree.api')

      local function open_tab_silent(node)
        api.node.open.tab(node)
        vim.cmd.tabprev()
      end

      local function open_tab_and_close_tree(node)
        vim.cmd('quit')
        api.node.open.tab(node)
      end

      local function open_tab_and_swap_cursor(node)
        vim.cmd('wincmd l')
        api.node.open.tab(node)
      end

      require('nvim-tree').setup({
        view = {
          mappings = {
            list = {
              { key = 'l',     action = 'edit' },
              { key = '<C-l>', action = 'expand_all' },
              { key = 'h',     action = 'close_node' },
              { key = 'H',     action = '' },
              { key = 'g.',    action = 'toggle_dotfiles' },
              { key = '<C-h>', action = 'collapse_all' },
              { key = 'T',     action = 'open_tab_silent',          action_cb = open_tab_silent },
              { key = 't',     action = 'open_tab_and_close_tree',  action_cb = open_tab_and_close_tree },
              { key = '<C-t>', action = 'open_tab_and_swap_cursor', action_cb = open_tab_and_swap_cursor },
              { key = '<C-s>', action = 'split' },
            }
          }
        },
        renderer = {
          indent_markers = {
            enable = true,
          },
        },
        diagnostics = {
          enable = true,
          show_on_dirs = true,
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
        '<leader>w',
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
      require('window-picker').setup()
    end
  },
  {
    'akinsho/toggleterm.nvim',
    event = 'VeryLazy',
    keys = {
      { [[<C-\>]] },
      { '<LEADER>t', '<CMD>lua _G._my_wrapper_run_in_terminal({})<CR>',                  mode = 'n', silent = true },
      { '<LEADER>g', "<CMD>lua _G._my_wrapper_run_in_terminal({ cmd = 'lazygit' })<CR>", mode = 'n', silent = true },
      {
        '<LEADER>R',
        function()
          local ft = vim.opt.filetype._value
          local cmd

          local sep = (vim.fn.has('win32') == 1) and '\\' or '/'
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
            local template = (vim.fn.stdpath('config') .. sep .. 'pandoc-templates' .. sep .. 'eisvogel.latex'):gsub('/',
              sep)
            cmd = ('cd "%s" && pandoc %s --pdf-engine=xelatex --template="%s"%s -o %s.pdf'):format(dir, fileName,
              template,
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
          _G._my_wrapper_run_in_terminal({ cmd = cmd, close_on_exit = false })
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

      function _G._my_wrapper_run_in_terminal(mytable)
        mytable.cmd = mytable.cmd or vim.fn.input('Enter command: ')
        mytable = vim.tbl_deep_extend('force', { hidden = true }, mytable)
        require('toggleterm.terminal').Terminal:new(mytable):toggle()
      end
    end
  },
  {
    'csexton/trailertrash.vim',
    event = 'BufWritePre',
    config = function()
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
      { 'stevearc/dressing.nvim', config = function() require('dressing').setup {} end },
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
      { '<leader>ll', '<CMD>LeetCodeList<CR>',   mode = 'n', silent = true },
      { '<leader>lt', '<CMD>LeetCodeTest<CR>',   mode = 'n', silent = true },
      { '<leader>ls', '<CMD>LeetCodeSubmit<CR>', mode = 'n', silent = true },
      { '<leader>li', '<CMD>LeetCodeSignIn<CR>', mode = 'n', silent = true }
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
    event = 'BufReadPost',
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
      { '<LEADER>c', '<CMD>NextColorScheme<CR>' },
      { '<LEADER>C', '<CMD>PrevColorScheme<CR>' },
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
})

my_load(M)
