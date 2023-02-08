local _, S = pcall(require, 'ysl.secret') -- Load machine specific secrets.
local U = require('ysl.utils')
-- =============
-- === Basic ===
-- =============
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
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
  pattern = { 'lua', 'json', 'markdown' },
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
vim.opt.timeout = true
vim.opt.timeoutlen = 300
vim.opt.backup = false
vim.opt.writebackup = false

vim.keymap.set('n', '<Space>', '')
vim.g.mapleader = ' '
vim.keymap.set('i', '<C-c>', '<C-[>', { silent = true })
vim.keymap.set('n', '<C-a>', '')
vim.keymap.set('n', '<C-z>', '<C-a>', { silent = true })

function _G.command_wrapper_check_no_name_buffer(cmdstr)
  if vim.fn.empty(vim.fn.bufname(vim.fn.bufnr())) == 1 then
    return
  end
  vim.cmd(cmdstr)
end

vim.keymap.set('n', '<C-w>H', ':lua command_wrapper_check_no_name_buffer("bel vs | silent! b# | winc p")<CR>',
  { silent = true })
vim.keymap.set('n', '<C-w>J', ':lua command_wrapper_check_no_name_buffer("abo sp | silent! b# | winc p")<CR>',
  { silent = true })
vim.keymap.set('n', '<C-w>K', ':lua command_wrapper_check_no_name_buffer("bel sp | silent! b# | winc p")<CR>',
  { silent = true })
vim.keymap.set('n', '<C-w>L', ':lua command_wrapper_check_no_name_buffer("abo vs | silent! b# | winc p")<CR>',
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

local function myload(plugins)
  require('lazy').setup(plugins, {
    -- defaults = { lazy = true }
  })
end

local M = {}

-- ===
-- === Load VSCode
-- ===
vim.list_extend(M, {
  { 'tpope/vim-surround', event = 'VeryLazy' },
  { 'numToStr/Comment.nvim', config = function() require('Comment').setup() end, event = 'VeryLazy' },
  { 'itchyny/vim-cursorword', event = 'VeryLazy' },
  { 'RRethy/vim-illuminate', event = 'VeryLazy' },
  { 'justinmk/vim-sneak', event = 'VeryLazy' }
})

M[#M + 1] = {
  'ysl2/vim-easymotion-for-vscode-neovim',
  event = 'VeryLazy',
  cond = not not vim.g.vscode
}

if vim.g.vscode then
  myload(M)
  return
end

-- ===
-- === Load Secret
-- ===
M[#M + 1] = U.set(U.safeget(S, 'colorscheme'),
  {
    'catppuccin/nvim',
    lazy = false,
    priority = 1000,
    name = 'catppuccin',
    config = function()
      vim.cmd('colorscheme catppuccin-frappe')
    end
  })

local requires = U.set(U.safeget(S, 'requires'), {
  require('ysl.lsp.coc')
})

for _, v in ipairs(requires) do
  vim.list_extend(M, v)
end

vim.list_extend(M, U.set(U.safeget(S, 'plugins'), {}))

-- ===
-- === Load Bulk
-- ===
vim.list_extend(M, {
  { 'Asheq/close-buffers.vim', cmd = 'Bdelete' },
  { 'lukas-reineke/indent-blankline.nvim', event = 'BufReadPost' },
  { 'romainl/vim-cool', event = 'VeryLazy' },
  { 'tpope/vim-fugitive', cmd = 'Git' },
  { 'lewis6991/gitsigns.nvim', config = function() require('gitsigns').setup() end, event = 'BufReadPost' },
  { 'norcalli/nvim-colorizer.lua', config = function() require('colorizer').setup() end, event = 'BufReadPost' },
  { 'folke/todo-comments.nvim', dependencies = 'nvim-lua/plenary.nvim',
    config = function() require('todo-comments').setup {} end, event = 'BufReadPost' },
  { 'ahmedkhalf/project.nvim', config = function() require('project_nvim').setup {} end, lazy = false, },
  { 'ysl2/bufdelete.nvim', cmd = 'Bd' },
  { 'iamcco/markdown-preview.nvim', build = 'cd app && npm install', ft = 'markdown' },
  { 'dhruvasagar/vim-table-mode', ft = 'markdown' },
  { 'mzlogin/vim-markdown-toc', ft = 'markdown' },
  { 'dkarter/bullets.vim', ft = 'markdown',
    init = function() vim.g.bullets_custom_mappings = { { 'inoremap <expr>', '<CR>',
        'coc#pum#visible() ? coc#pum#confirm() : "<Plug>(bullets-newline)"' }, }
    end },
  { 'mg979/vim-visual-multi', event = 'BufReadPost' },
  { 'gcmt/wildfire.vim', event = 'VeryLazy' },
  { 'MattesGroeger/vim-bookmarks', event = 'VeryLazy', }
})

-- ===
-- === Load Single
-- ===
if vim.fn.has('win32') == 0 then
  M[#M + 1] = {
    'wellle/tmux-complete.vim',
    event = 'VeryLazy'
  }
end

if vim.fn.has('win32') == 0 then
  M[#M + 1] = {
    'kevinhwang91/rnvimr',
    keys = { { '<Leader>r', ':RnvimrToggle<CR>', mode = 'n', silent = true } },
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
  }
end

M[#M + 1] = {
  'kdheepak/lazygit.nvim',
  keys = { { '<Leader>g', ':LazyGit<CR>', mode = 'n', silent = true } },
}

M[#M + 1] = {
  'nvim-treesitter/nvim-treesitter',
  event = 'VeryLazy',
  build = function() local ts_update = require('nvim-treesitter.install').update({ with_sync = true }) ts_update() end,
  dependencies = {
    'windwp/nvim-ts-autotag',
    'JoosepAlviste/nvim-ts-context-commentstring',
    'mrjones2014/nvim-ts-rainbow',
    'nvim-treesitter/playground',
  },
  config = function()
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
      ensure_installed = { 'vim', 'query', 'lua', 'markdown' },

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
}

M[#M + 1] = {
  'easymotion/vim-easymotion',
  event = 'VeryLazy',
  config = function()
    vim.g.EasyMotion_smartcase = 1
    vim.g.EasyMotion_keys = 'qwertyuiopasdfghjklzxcvbnm'
  end
}

M[#M + 1] = {
  'nvim-telescope/telescope.nvim', branch = '0.1.x',
  cmd = 'Telescope',
  keys = {
    { '<Leader>f', ':Telescope find_files<CR>', mode = 'n', silent = true },
    { '<Leader>b', ':Telescope buffers<CR>', mode = 'n', silent = true },
    { '<Leader>s', ':Telescope live_grep<CR>', mode = 'n', silent = true },
    { '<Leader>G', ':Telescope git_status<CR>', mode = 'n', silent = true },
    { '<Leader>m', ':Telescope vim_bookmarks current_file<CR>', mode = 'n', silent = true },
    { '<Leader>M', ':Telescope vim_bookmarks all<CR>', mode = 'n', silent = true }
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim',
      build = (vim.fn.has('win32') == 0) and 'make' or
          'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' },
    'xiyaowong/telescope-emoji.nvim',
    'tom-anders/telescope-vim-bookmarks.nvim'
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
      -- extensions = {
      --   -- Your extension configuration goes here:
      -- }
    }
    telescope.load_extension('fzf')
    telescope.load_extension('emoji')
    telescope.load_extension('vim_bookmarks')
  end
}

M[#M + 1] = {
  'mbbill/undotree',
  keys = { { '<Leader>u', ':UndotreeToggle<CR>', mode = 'n', silent = true } },
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
}

M[#M + 1] = {
  'nvim-tree/nvim-tree.lua',
  keys = { { '<Leader>e', ':NvimTreeToggle<CR>', mode = 'n', silent = true } },
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    local api = require('nvim-tree.api')

    local function open_tab_silent(node)
      api.node.open.tab(node)
      vim.cmd.tabprev()
    end

    local swap_then_open_tab = function()
      local node = require 'nvim-tree.lib'.get_node_at_cursor()
      -- vim.cmd('wincmd l')
      vim.cmd('quit')
      api.node.open.tab(node)
    end

    require('nvim-tree').setup({
      view = {
        mappings = {
          list = {
            { key = 'l', action = 'edit' },
            { key = 'h', action = 'close_node' },
            { key = 'H', action = nil },
            { key = 'zh', action = 'toggle_dotfiles' },
            { key = '<C-h>', action = 'collapse_all' },
            { key = 'T', action = 'open_tab_silent', action_cb = open_tab_silent },
            { key = 't', action = 'swap_then_open_tab', action_cb = swap_then_open_tab },
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
      notify = { threshold = vim.log.levels.WARN }
    })
  end
}

M[#M + 1] = {
  's1n7ax/nvim-window-picker',
  keys = {
    { '<leader>w', function()
      local picked_window_id = require('window-picker').pick_window() or vim.api.nvim_get_current_win()
      vim.api.nvim_set_current_win(picked_window_id)
    end, mode = 'n', silent = true, desc = 'Pick a window' }
  },
  version = '1.*',
  config = function()
    require('window-picker').setup()
  end
}

M[#M + 1] = {
  'ysl2/symbols-outline.nvim',
  keys = { { '<Leader>v', ':SymbolsOutline<CR>', mode = 'n', silent = true } },
  config = function()
    require('symbols-outline').setup {}
  end
}

M[#M + 1] = {
  'akinsho/toggleterm.nvim',
  keys = { { [[<C-\>]] }, mode = 'n' },
  config = function()
    if vim.fn.has('win32') == 1 then
      local powershell_options = {
        shell = vim.fn.executable 'pwsh' == 1 and 'pwsh' or 'powershell',
        shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;',
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
    vim.keymap.set('t', '<C-[>', [[<C-\><C-n>]], { silent = true })
  end
}

M[#M + 1] = {
  'csexton/trailertrash.vim',
  event = 'BufWritePre',
  config = function()
    vim.api.nvim_create_autocmd('BufWritePre', {
      command = 'TrailerTrim'
    })
  end
}

M[#M + 1] = {
  'ysl2/distant.nvim',
  branch = 'v0.2',
  keys = {
    { '<Leader>dc', function()
      local hosts = U.safeget(S, { 'config', 'distant' })
      if not hosts then print('Missing host lists.') return end
      local idx = tonumber(vim.fn.input('Enter host idx: '))
      require('distant.command').connect(hosts[idx])
    end, mode = 'n', silent = true },
    { '<Leader>do', function()
      local path = vim.fn.input('Enter path: ')
      require('distant.command').open({ args = { path }, opts = {} })
    end, mode = 'n', silent = true },
    { '<Leader>ds', ':DistantShell<CR>', mode = 'n', silent = true }
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
}

M[#M + 1] = {
  'ysl2/img-paste.vim',
  ft = 'markdown',
  config = function()
    vim.api.nvim_create_autocmd('BufEnter', {
      pattern = '*.md',
      callback = function()
        vim.g.mdip_imgdir = 'assets' .. '/' .. vim.fn.expand('%:t:r') .. '/' .. 'images'
        vim.g.mdip_imgdir_intext = vim.g.mdip_imgdir
        vim.keymap.set('n', '<Leader>p', ':call mdip#MarkdownClipboardImage()<CR><ESC>', { silent = true })
        -- HACK: Download latex template for pandoc and put it into the correct path defined by each platform.
        --
        -- Download template: https://github.com/Wandmalfarbe/pandoc-latex-template
        -- Linux default location: /Users/USERNAME/.pandoc/templates/
        -- Windows default locathon: C:\Users\USERNAME\AppData\Roaming\pandoc\templates\
        -- Also you can specify your own path:
        -- ```
        -- pandoc --pdf-engine=xelatex --template=[path of the template.latex] newfile.md -o newfile.pdf
        -- ```
        local sep = '/'
        local cjk = ''
        if vim.fn.has('win32') == 1 then
          sep = '\\'
          cjk = ' -V CJKmainfont="Microsoft YaHei"'
        end
        local template = vim.fn.stdpath('config') .. sep .. 'pandoc-templates' .. sep .. 'eisvogel.latex'
        local cmd = (':!pandoc %% --pdf-engine=xelatex --template="%s"%s -o %%:r.pdf<CR>'):format(template, cjk)
        vim.keymap.set('n', '<Leader>P', cmd, { silent = true })
      end
    })
  end
}

M[#M + 1] = {
  'Shatur/neovim-session-manager',
  lazy = false,
  cmd = 'SessionManager',
  keys = {
    { '<Leader>o', ':SessionManager load_session<CR>', mode = 'n', silent = true },
    { '<Leader>O', ':SessionManager delete_session<CR>', mode = 'n', silent = true }
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
}

M[#M + 1] = {
  'ysl2/leetcode.vim',
  keys = {
    { '<leader>ll', ':LeetCodeList<cr>', mode = 'n', silent = true },
    { '<leader>lt', ':LeetCodeTest<cr>', mode = 'n', silent = true },
    { '<leader>ls', ':LeetCodeSubmit<cr>', mode = 'n', silent = true },
    { '<leader>li', ':LeetCodeSignIn<cr>', mode = 'n', silent = true }
  },
  config = function()
    vim.g.leetcode_china = 0
    vim.g.leetcode_browser = 'chrome'
    vim.g.leetcode_solution_filetype = 'python'
  end
}

M[#M + 1] = {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  config = function()
    require('which-key').setup({
      plugins = {
        marks = false, -- shows a list of your marks on ' and `
        registers = false, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
      }
    })
  end,
}

M[#M + 1] = {
  'glacambre/firenvim',
  build = function() vim.fn['firenvim#install'](0) end,

  -- Lazy load firenvim
  -- Explanation: https://github.com/folke/lazy.nvim/discussions/463#discussioncomment-4819297
  cond = not not vim.g.started_by_firenvim
}

M[#M + 1] = {
  'ethanholz/nvim-lastplace',
  event = 'BufReadPost',
  config = function()
    require 'nvim-lastplace'.setup {
      lastplace_ignore_buftype = { 'quickfix', 'nofile', 'help' },
      lastplace_ignore_filetype = { 'gitcommit', 'gitrebase', 'svn', 'hgcommit' },
      lastplace_open_folds = true
    }
  end
}

myload(M)
