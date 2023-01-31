local _, ysl_secret = pcall(require, 'ysl.secret') -- Load machine specific secrets.next(
local ysl_utils = require('ysl.utils')
local ysl_set = ysl_utils.set
local ysl_safeget = ysl_utils.safeget
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
vim.opt.shiftwidth = vim.opt.tabstop._value
vim.opt.expandtab = true
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'lua', 'json', 'markdown' },
  callback = function()
    vim.opt.tabstop = 2
    vim.opt.shiftwidth = vim.opt.tabstop._value
  end
})

vim.keymap.set('n', '<Space>', '')
vim.g.mapleader = ' '
vim.keymap.set('i', '<C-c>', '<C-[>', { silent = true })
vim.keymap.set('n', '<C-z>', '<C-a>', { silent = true })

function _G.command_wrapper_check_no_name_buffer(cmdstr)
  if vim.fn.empty(vim.fn.bufname(vim.fn.bufnr())) == 1 then
    return
  end
  vim.cmd(cmdstr)
end

vim.keymap.set('n', '<C-w>H', ':lua command_wrapper_check_no_name_buffer(":bel vs | silent! b# | winc p")<CR>',
  { silent = true })
vim.keymap.set('n', '<C-w>J', ':lua command_wrapper_check_no_name_buffer(":abo sp | silent! b# | winc p")<CR>',
  { silent = true })
vim.keymap.set('n', '<C-w>K', ':lua command_wrapper_check_no_name_buffer(":bel sp | silent! b# | winc p")<CR>',
  { silent = true })
vim.keymap.set('n', '<C-w>L', ':lua command_wrapper_check_no_name_buffer(":abo vs | silent! b# | winc p")<CR>',
  { silent = true })

-- Auto delete [No Name] buffers.
vim.api.nvim_create_autocmd('BufLeave', {
  callback = function()
    if vim.g.vscode then return end
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

-- Auto highlight after yank.
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end
})


-- ==========================
-- === Plugin Declaration ===
-- ==========================
-- ===
-- === Plugin Manager
-- ===
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

local function load(plugins)
  require('lazy').setup(plugins, {
    defaults = { lazy = true }
  })
end

-- ===
-- === Plugin List
-- ===
local plugins = {}

-- 0. For VSCode
vim.list_extend(plugins, {
  { 'tpope/vim-surround', event = 'CursorHold' },
  { 'numToStr/Comment.nvim', config = function() require('Comment').setup() end, event = 'CursorHold' },
  { 'itchyny/vim-cursorword', event = 'CursorHold' },
  { 'RRethy/vim-illuminate', event = 'CursorHold' },
})
if vim.g.vscode then
  vim.list_extend(plugins, {
    { 'ysl2/vim-easymotion-for-vscode-neovim', event = 'CursorHold' }
  })
  load(plugins)
  return
end

-- 1. Choose files or extentions or other things to load.
local ysl_lsp = ysl_set(ysl_safeget(ysl_secret, 'lsp'), require('ysl.lsp.coc'))
vim.list_extend(plugins, ysl_lsp.plugins)
plugins[#plugins + 1] = ysl_set(ysl_safeget(ysl_secret, 'colorscheme'),
  { 'shaunsingh/nord.nvim', config = function()
    vim.cmd('colorscheme nord')
  end, lazy = false })

-- 2. Extensions declared in the files above.
vim.list_extend(plugins, {
  { 'folke/trouble.nvim', dependencies = 'nvim-tree/nvim-web-devicons',
    config = function() require('trouble').setup {} end },
  'windwp/nvim-autopairs',
  { 'akinsho/bufferline.nvim', version = '3.*', dependencies = 'nvim-tree/nvim-web-devicons' },
})

-- 3. Platform specific.
if vim.fn.has('win32') == 0 then
  -- For Linux/Mac.
  vim.list_extend(plugins, {
    { 'kevinhwang91/rnvimr', event = 'CursorHold' },
    { 'kdheepak/lazygit.nvim', event = 'CursorHold' },
    { 'wellle/tmux-complete.vim', event = 'CursorHold' }
  })
  -- else
  --   -- For Windows.
end

-- 4. Public extentions.
vim.list_extend(plugins, {
  { 'nvim-treesitter/nvim-treesitter',
    build = function() local ts_update = require('nvim-treesitter.install').update({ with_sync = true }) ts_update() end,
    dependencies = {
      'windwp/nvim-ts-autotag',
      'JoosepAlviste/nvim-ts-context-commentstring',
      'mrjones2014/nvim-ts-rainbow',
      'nvim-treesitter/playground',
    }
  },
  { 'easymotion/vim-easymotion', event = 'CursorHold' },
  { 'Asheq/close-buffers.vim', event = 'CursorHold' },
  { 'nvim-telescope/telescope.nvim', branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim',
        build = (vim.fn.has('win32') == 0) and 'make' or
            'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' },
      'xiyaowong/telescope-emoji.nvim'
    }
  },
  'honza/vim-snippets',
  { 'lukas-reineke/indent-blankline.nvim', event = 'BufReadPost' },
  { 'romainl/vim-cool', event = 'CursorHold' },
  { 'nvim-lualine/lualine.nvim', dependencies = 'nvim-tree/nvim-web-devicons', },
  { 'mbbill/undotree', event = 'BufReadPost' },
  { 'folke/which-key.nvim', config = function() require('which-key').setup {} end, event = 'CursorHold' },
  { 'nvim-tree/nvim-tree.lua', dependencies = 'nvim-tree/nvim-web-devicons' },
  { 'tpope/vim-fugitive', event = 'CursorHold' },
  { 'lewis6991/gitsigns.nvim', config = function() require('gitsigns').setup() end, event = 'BufReadPre' },
  { 'norcalli/nvim-colorizer.lua', config = function() require('colorizer').setup() end, event = 'BufReadPost' },
  { 's1n7ax/nvim-window-picker', version = '1.*', config = function() require('window-picker').setup() end, },
  { 'folke/todo-comments.nvim', dependencies = 'nvim-lua/plenary.nvim',
    config = function() require('todo-comments').setup {} end, event = 'BufReadPost' },
  { 'ysl2/symbols-outline.nvim', config = function() require('symbols-outline').setup {} end, event = 'BufReadPost' },
  { 'ahmedkhalf/project.nvim', config = function() require('project_nvim').setup {} end, event = 'CursorHold' },
  'akinsho/toggleterm.nvim',
  { 'csexton/trailertrash.vim', event = 'BufWritePre' },
  { 'ysl2/distant.nvim', branch = 'v0.2',
    config = function() require('distant').setup { ['*'] = require('distant.settings').chip_default() } end },
  { 'ysl2/bufdelete.nvim', event = 'CursorHold' },
  { 'iamcco/markdown-preview.nvim', build = 'cd app && npm install', ft = 'markdown' },
  { 'dhruvasagar/vim-table-mode', ft = 'markdown' },
  { 'mzlogin/vim-markdown-toc', ft = 'markdown' },
  { 'dkarter/bullets.vim', ft = 'markdown',
    init = function() vim.g.bullets_custom_mappings = { { 'inoremap <expr>', '<CR>',
        'coc#pum#visible() ? coc#pum#confirm() : "<Plug>(bullets-newline)"' }, }
    end },
  { 'ysl2/img-paste.vim', ft = 'markdown' },
  { 'Shatur/neovim-session-manager',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'stevearc/dressing.nvim', config = function() require('dressing').setup {} end },
    }
  },
  { 'xiyaowong/nvim-transparent',
    config = function() require('transparent').setup({
        enable = ysl_set(ysl_safeget(ysl_secret, { 'transparent', 'enable' }), false),
        -- extra_groups = { 'NvimTreeNormal', 'NvimTreeEndOfBuffer', 'NvimTreeStatuslineNc', },
      })
    end },
  { 'mg979/vim-visual-multi', event = 'BufReadPost' },
  { 'ysl2/leetcode.vim', event = 'CursorHold' },
  { 'gcmt/wildfire.vim', event = 'CursorHold' },
})

load(plugins)


--- ============================
--- === Plugin Configuration ===
--- ============================
-- ===
-- === require('ysl.lsp.?')
-- ===
local ysl_lsp_callback = ysl_lsp.configurate()

-- ===
-- === akinsho/bufferline.nvim
-- ===
-- HACK: Merge callback values.
local c = ysl_safeget(ysl_lsp_callback, 'bufferline')
require('bufferline').setup(vim.tbl_deep_extend('force', {
  options = {
    mode = 'tabs',
    diagnostics_update_in_insert = true,
    show_buffer_close_icons = false,
    show_close_icon = false,
    always_show_bufferline = false
  },
}, c or {}))

-- ===
-- === kevinhwang91/rnvimr
-- ===
if vim.fn.has('win32') == 0 then
  vim.g.rnvimr_enable_picker = 1
  vim.g.rnvimr_enable_bw = 1
  vim.cmd('hi link NormalFloat NONE')
  vim.defer_fn(function()
    vim.cmd('RnvimrStartBackground')
  end, 1000)
  vim.g.rnvimr_action = {
    ['<CR>'] = 'NvimEdit tabedit',
    ['<C-x>'] = 'NvimEdit split',
    ['<C-v>'] = 'NvimEdit vsplit',
  }
  vim.keymap.set('n', '<Leader>r', ':RnvimrToggle<CR>', { silent = true })
end

-- ===
-- === kdheepak/lazygit.nvim
-- ===
if vim.fn.has('win32') == 0 then
  vim.keymap.set('n', '<Leader>g', ':LazyGit<CR>', { silent = true })
end

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

-- ===
-- === easymotion/vim-easymotion
-- ===
vim.g.EasyMotion_smartcase = 1
vim.g.EasyMotion_keys = 'qwertyuiopasdfghjklzxcvbnm'

-- ===
-- === nvim-telescope/telescope.nvim
-- ===
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
vim.keymap.set('n', '<Leader>f', ':Telescope find_files<CR>', { silent = true })
vim.keymap.set('n', '<Leader>b', ':Telescope buffers<CR>', { silent = true })
vim.keymap.set('n', '<Leader>s', ':Telescope live_grep<CR>', { silent = true })
vim.keymap.set('n', '<Leader>G', ':Telescope git_status<CR>', { silent = true })

-- ===
-- === nvim-telescope/telescope-fzf-native.nvim
-- ===
telescope.load_extension('fzf')

-- ===
-- === xiyaowong/telescope-emoji.nvim
-- ===
require('telescope').load_extension('emoji')

-- ===
-- === nvim-lualine/lualine.nvim
-- ===
-- HACK: Merge callback values.
local c = ysl_safeget(ysl_lsp_callback, 'lualine')
require('lualine').setup(vim.tbl_deep_extend('force', {
  options = {
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' }
  },
}, c or {}))

-- ===
-- === mbbill/undotree
-- ===
vim.g.undotree_WindowLayout = 3
if vim.fn.has('persistent_undo') == 1 then
  local target_path = vim.fn.expand(vim.fn.stdpath('data') .. '/.undodir')
  if vim.fn.isdirectory(target_path) == 0 then
    vim.fn.mkdir(target_path, 'p')
  end
  vim.cmd("let &undodir='" .. target_path .. "'")
  vim.cmd('set undofile')
end
vim.keymap.set('n', '<Leader>u', ':UndotreeToggle<CR>', { silent = true })

-- ===
-- === nvim-tree/nvim-tree.lua
-- ===
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
vim.keymap.set('n', '<Leader>e', ':NvimTreeToggle<CR>', { silent = true })

-- ===
-- === s1n7ax/nvim-window-picker
-- ===
vim.keymap.set('n', '<leader>w', function()
  local picked_window_id = require('window-picker').pick_window() or vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(picked_window_id)
end, { desc = 'Pick a window' })

-- ===
-- === ysl2/symbols-outline.nvim
-- ===
vim.keymap.set('n', '<Leader>v', ':SymbolsOutline<CR>', { silent = true })

-- ===
-- === akinsho/toggleterm.nvim
-- ===
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

-- ===
-- === csexton/trailertrash.vim
-- ===
-- Auto delete trailing whitespace.
vim.api.nvim_create_autocmd('BufWritePre', {
  command = 'TrailerTrim'
})

-- ===
-- === ysl2/distant.nvim
-- ===
-- HACK: If path contains whitespace, you should link .ssh folder to another place.
--
-- ```dos
-- cd C:\Users\Public
-- mklink /D .ssh "C:\Users\fa fa\.ssh"
-- ```
--
-- HACK: Read variables from secret file.
-- ysl_secret.distant is a list type (also can be defined as a table that can give a host alia. By yourself.)
-- e.g,
--
-- ```lua
-- ysl_secret.distant = {
--   {
--     args = { 'ssh://user1@111.222.333.444:22' },
--     opts = {
--       options = {
--         -- ['ssh.backend'] = 'libssh', -- No need to specify this. Just for example.
--         ['ssh.user_known_hosts_files'] = 'C:\\Users\\Public\\.ssh\\known_hosts',
--         ['ssh.identity_files'] = 'C:\\Users\\Public\\.ssh\\id_rsa'
--       }
--     }
--   },
--   {
--     args = { 'ssh://user2@127.0.0.1:2233' },
--     opts = {} -- Or leave it empty on Linux.
--   }
-- }
-- ```
if ysl_safeget(ysl_secret, 'distant') then
  local distant_command = require('distant.command')

  function DistantConnect(idx)
    distant_command.connect(ysl_secret.distant[idx])
  end

  function DistantOpen(path)
    distant_command.open({ args = { path }, opts = {} })
  end

  vim.keymap.set('n', '<Leader>dc', ':lua DistantConnect()<Left>')
  vim.keymap.set('n', '<Leader>do', ":lua DistantOpen('')<Left><Left>")
  vim.keymap.set('n', '<Leader>ds', ':DistantShell<CR>')
end

-- ===
-- === ysl2/img-paste.vim
-- ===
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

-- ===
-- === Shatur/neovim-session-manager
-- ===
require('session_manager').setup({
  autoload_mode = require('session_manager.config').AutoloadMode.CurrentDir
})

vim.api.nvim_create_autocmd({ 'VimEnter' }, {
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

vim.keymap.set('n', '<Leader>o', ':SessionManager load_session<CR>', { silent = true })
vim.keymap.set('n', '<Leader>O', ':SessionManager delete_session<CR>', { silent = true })

-- ===
-- === ysl2/leetcode.vim
-- ===
vim.g.leetcode_china = 1
vim.g.leetcode_browser = 'chrome'
vim.g.leetcode_solution_filetype = 'python'

vim.keymap.set('n', '<leader>ll', ':LeetCodeList<cr>', { silent = true })
vim.keymap.set('n', '<leader>lt', ':LeetCodeTest<cr>', { silent = true })
vim.keymap.set('n', '<leader>ls', ':LeetCodeSubmit<cr>', { silent = true })
vim.keymap.set('n', '<leader>li', ':LeetCodeSignIn<cr>', { silent = true })
