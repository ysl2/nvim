-- =============
-- === Basic ===
-- =============
vim.g.neovide_cursor_animation_length = 0
vim.opt.wrap = false
vim.opt.scrolloff = 1
vim.opt.maxmempattern = 2000

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.termguicolors = true
vim.opt.winblend = 30

vim.keymap.set('n', '<Space>', '', {})
vim.g.mapleader = ' '
local opts = { silent = true }
vim.keymap.set('i', '<C-c>', '<ESC>', opts)
vim.keymap.set('n', '<C-z>', '<C-a>', opts)

function Command_wrapper_check_no_name_buffer(cmdstr)
  if vim.fn.empty(vim.fn.bufname(vim.fn.bufnr())) == 1 then
    return
  end
  vim.cmd(cmdstr)
end

vim.keymap.set('n', '<C-w>H', ':lua Command_wrapper_check_no_name_buffer(":bel vs | silent! b# | winc p")<CR>', opts)
vim.keymap.set('n', '<C-w>J', ':lua Command_wrapper_check_no_name_buffer(":abo sp | silent! b# | winc p")<CR>', opts)
vim.keymap.set('n', '<C-w>K', ':lua Command_wrapper_check_no_name_buffer(":bel sp | silent! b# | winc p")<CR>', opts)
vim.keymap.set('n', '<C-w>L', ':lua Command_wrapper_check_no_name_buffer(":abo vs | silent! b# | winc p")<CR>', opts)

-- Auto delete trailing whitespace.
vim.api.nvim_create_autocmd('BufWritePre', {
  command = [[%s/\s\+$//e]],
})

-- Auto delete [No Name] buffers.
vim.api.nvim_create_autocmd('BufLeave', {
  callback = function()
    local buffers = vim.fn.filter(vim.fn.range(1, vim.fn.bufnr('$')),
      'buflisted(v:val) && empty(bufname(v:val)) && bufwinnr(v:val) < 0 && (getbufline(v:val, 1, "$") == [""])')
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
      use { 'nvim-treesitter/nvim-treesitter',
        run = function() local ts_update = require('nvim-treesitter.install').update({ with_sync = true }) ts_update() end, }
      use 'easymotion/vim-easymotion'
      use 'tpope/vim-surround'
      use 'tpope/vim-commentary'
      use 'Asheq/close-buffers.vim'
      use 'numirias/semshi'
      use 'jbgutierrez/vim-better-comments'
      use 'luochen1990/rainbow'
      use 'nvim-tree/nvim-web-devicons'
      use 'mg979/vim-xtabline'
      use { 'nvim-telescope/telescope.nvim', branch = '0.1.x', requires = { { 'nvim-lua/plenary.nvim' } } }
      use 'gcmt/wildfire.vim'
      use 'honza/vim-snippets'
      use 'itchyny/vim-cursorword'
      use 'lukas-reineke/indent-blankline.nvim'
      use 'voldikss/vim-floaterm'
      use 'airblade/vim-rooter'
      use 'romainl/vim-cool'
      use 'tpope/vim-obsession'
      use { 'nvim-lualine/lualine.nvim', requires = { 'nvim-tree/nvim-web-devicons', opt = true } }
      use 'mbbill/undotree'
      use 'tpope/vim-sleuth'
      use { 'folke/which-key.nvim', config = function() require('which-key').setup {} end }
      use { 'nvim-tree/nvim-tree.lua', requires = { 'nvim-tree/nvim-web-devicons', }, tag = 'nightly' }
      use 'tpope/vim-fugitive'
      use { 'lewis6991/gitsigns.nvim', config = function() require('gitsigns').setup() end }
      use { 'norcalli/nvim-colorizer.lua', config = function() require('colorizer').setup() end }
      use { 's1n7ax/nvim-window-picker', tag = 'v1.*', config = function() require('window-picker').setup() end }
      use { 'windwp/nvim-autopairs', config = function() require('nvim-autopairs').setup {} end }
      use { 'folke/trouble.nvim', requires = 'nvim-tree/nvim-web-devicons',
        config = function() require('trouble').setup {} end }
      use { 'folke/todo-comments.nvim', requires = 'nvim-lua/plenary.nvim',
        config = function() require('todo-comments').setup {} end }
      use { 'folke/twilight.nvim', config = function() require('twilight').setup {} end }
      use { 'folke/zen-mode.nvim', config = function() require('zen-mode').setup {} end }
      use 'sainnhe/everforest'
      use 'liuchengxu/vista.vim'
      use 'RRethy/vim-illuminate'

      use 'williamboman/mason.nvim'
      use 'williamboman/mason-lspconfig.nvim'
      use 'neovim/nvim-lspconfig'
      use 'hrsh7th/cmp-nvim-lsp'
      use 'hrsh7th/cmp-buffer'
      use 'hrsh7th/cmp-path'
      use 'hrsh7th/cmp-cmdline'
      use 'hrsh7th/nvim-cmp'
      use 'L3MON4D3/LuaSnip'
      use 'saadparwaiz1/cmp_luasnip'
      use 'onsails/lspkind.nvim'

      if not (vim.fn.has('win32') == 1) then
        use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
        use 'kevinhwang91/rnvimr'
        use 'kdheepak/lazygit.nvim'
        use 'wellle/tmux-complete.vim'
      end

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
  ensure_installed = {},

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
-- === easymotion/vim-easymotion
-- ===
vim.g.EasyMotion_smartcase = 1
vim.g.EasyMotion_keys = 'qwertyuiopasdfghjklzxcvbnm'

-- ===
-- === kevinhwang91/rnvimr
-- ===
if not (vim.fn.has('win32') == 1) then
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
if not (vim.fn.has('win32') == 1) then
  vim.keymap.set('n', '<Leader>g', ':LazyGit<CR>', { silent = true })
end

-- ===
-- === mg979/vim-xtabline
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
    layout_strategy = 'vertical',
    path_display = { 'tail' },
    sorting_strategy = 'ascending',
    mappings = {
      i = {
        ['<C-j>'] = require('telescope.actions').move_selection_next,
        ['<C-k>'] = require('telescope.actions').move_selection_previous,
        ['<C-r>'] = require('telescope.actions.layout').toggle_preview,
        ['<C-b>'] = require('telescope.actions').delete_buffer
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
    git_status = {
      preview = {
        hide_on_startup = false -- hide previewer when picker starts
      }
    }
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
if not (vim.fn.has('win32') == 1) then
  require('telescope').load_extension('fzf')
end

-- ===
-- === voldikss/vim-floaterm
-- ===
vim.keymap.set('n', [[<C-\>]], ':FloatermToggle<CR>', { silent = true })
vim.keymap.set('t', '<C-[>', [[<C-\><C-n>]], { silent = true })
vim.keymap.set('t', [[<C-\>]], [[<C-\><C-n>:FloatermToggle<CR>]], { silent = true })

-- ===
-- === tpope/vim-obsession
-- ===
vim.api.nvim_create_autocmd('VimEnter', {
  nested = true,
  callback = function()
    if vim.fn.has('win32') == 1 then
      -- An empty file will be opened if you use right mouse click. So `bw!` to delete it.
      -- Once you delete the empty buffer, netrw won't popup. So you needn't do `vim.cmd('silent! au! FileExplorer *')` to silent netrw.
      vim.cmd(':silent! cd %:p:h')
      -- vim.fn.argc() is 1 (not 0) if you open from right mouse click on windows platform.
      -- So it can't be an instance that can be treated as in a workspace.
      if vim.fn.empty(vim.v.this_session) and vim.fn.filereadable('Session.vim') == 1 then
        vim.cmd(':silent! %bw! | silent! source Session.vim')
      end
      -- Prevent auto creating a [No Name] buffer or a buffer which name is current working directory.
      local cmdstr = ':silent! bw!'
      for _, v in pairs(vim.fn.range(1, vim.fn.bufnr('$'))) do
        if vim.fn.bufname(v) == ''
            or vim.fn.bufname(v):gsub('%/', [[\]]) == vim.fn.getcwd() .. [[\]]
            or vim.fn.bufname(v):gsub('%/', [[\]]) == vim.fn.getcwd()
        then
          cmdstr = cmdstr .. ' ' .. v
        end
      end
      if not (cmdstr:sub(-1) == '!') then
        vim.cmd(cmdstr)
      end
    else
      if vim.fn.argc() == 0 and vim.fn.empty(vim.v.this_session) and vim.fn.filereadable('Session.vim') == 1 then
        vim.cmd(':silent! source Session.vim')
      end
    end
  end
})
vim.keymap.set('n', '<Leader>o', ':silent! source Session.vim<CR>', { silent = true })

-- ===
-- === nvim-lualine/lualine.nvim
-- ===
require('lualine').setup({
  options = {
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' }
  }
})

-- ===
-- === luochen1990/rainbow
-- ===
vim.g.rainbow_active = 1

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
require('nvim-tree').setup({
  view = {
    mappings = {
      list = {
        { key = { 'l', '<CR>', 'o' }, action = 'edit', mode = 'n' },
        { key = 'h', action = 'close_node' },
      }
    }
  }
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
-- === folke/trouble.nvim
-- ===
-- vim.keymap.set('n', '<leader>x',
--   '<cmd>call coc#rpc#request("fillDiagnostics", [bufnr("%")])<CR><cmd>TroubleToggle loclist<CR>', { silent = true })
vim.keymap.set('n', '<leader>x', '<cmd>TroubleToggle loclist<CR>', { silent = true })

-- ===
-- === folke/zen-mode.nvim
-- ===
vim.keymap.set('n', '<leader>z', ':ZenMode<CR>', { silent = true })

-- ===
-- === liuchengxu/vista.vim
-- ===
-- vim.g.vista_default_executive = 'coc'
vim.keymap.set('n', '<Leader>v', ':Vista!!<CR>', { silent = true })

-- ===
-- === williamboman/mason
-- ===
require('mason').setup({
  github = { download_url_template = 'https://ghproxy.com/https://github.com/%s/releases/download/%s/%s', }
})

-- ===
-- === williamboman/mason-lspconfig
-- ===
require('mason-lspconfig').setup({
  ensure_installed = { 'pyright', 'sumneko_lua' },
  automatic_installation = true,
})

-- ===
-- === neovim/nvim-lspconfig
-- ===
-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '\\e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '\\q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '\\wa', vim.lsp.buf.add_workspace_folder, bufopts)
  vim.keymap.set('n', '\\wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  vim.keymap.set('n', '\\wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  vim.keymap.set('n', '\\D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '\\rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '\\ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', '\\f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

-- ===
-- === onsails/lspkind.nvim
-- ===
require('lspkind').init({
  -- DEPRECATED (use mode instead): enables text annotations
  --
  -- default: true
  -- with_text = true,

  -- defines how annotations are shown
  -- default: symbol
  -- options: 'text', 'text_symbol', 'symbol_text', 'symbol'
  mode = 'symbol_text',

  -- default symbol map
  -- can be either 'default' (requires nerd-fonts font) or
  -- 'codicons' for codicon preset (requires vscode-codicons font)
  --
  -- default: 'default'
  preset = 'codicons',

  -- override preset symbols
  --
  -- default: {}
  symbol_map = {
    Text = "",
    Method = "",
    Function = "",
    Constructor = "",
    Field = "ﰠ",
    Variable = "",
    Class = "ﴯ",
    Interface = "",
    Module = "",
    Property = "ﰠ",
    Unit = "塞",
    Value = "",
    Enum = "",
    Keyword = "",
    Snippet = "",
    Color = "",
    File = "",
    Reference = "",
    Folder = "",
    EnumMember = "",
    Constant = "",
    Struct = "פּ",
    Event = "",
    Operator = "",
    TypeParameter = ""
  },
})

-- ===
-- === hrsh7th/nvim-cmp
-- ===
require('cmp').setup({
  completion = { completeopt = 'menu,menuone' },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  mapping = require('cmp').mapping.preset.insert({
    ['<C-b>'] = require('cmp').mapping.scroll_docs(-4),
    ['<C-f>'] = require('cmp').mapping.scroll_docs(4),
    ['<C-Space>'] = require('cmp').mapping.complete(),
    ['<CR>'] = require('cmp').mapping.confirm {
      behavior = require('cmp').ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = require('cmp').mapping(function(fallback)
      if require('cmp').visible() then
        require('cmp').select_next_item()
      elseif require('luasnip').expand_or_jumpable() then
        require('luasnip').expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = require('cmp').mapping(function(fallback)
      if require('cmp').visible() then
        require('cmp').select_prev_item()
      elseif require('luasnip').jumpable(-1) then
        require('luasnip').jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = require('cmp').config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' }, -- For luasnip users.
  }, {
    { name = 'buffer' },
  }),
  formatting = {
    format = require('lspkind').cmp_format({})
  }
})

-- Set configuration for specific filetype.
require('cmp').setup.filetype('gitcommit', {
  sources = require('cmp').config.sources({
    { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
require('cmp').setup.cmdline({ '/', '?' }, {
  mapping = require('cmp').mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
require('cmp').setup.cmdline(':', {
  mapping = require('cmp').mapping.preset.cmdline(),
  sources = require('cmp').config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

local lsp_config = {
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
  on_attach = on_attach,
}
require('mason-lspconfig').setup_handlers({
  -- The first entry (without a key) will be the default handler
  -- and will be called for each installed server that doesn't have
  -- a dedicated handler.
  function(server_name) -- default handler (optional)
    require('lspconfig')[server_name].setup(lsp_config)
  end,
  -- Next, you can provide targeted overrides for specific servers.
  ['sumneko_lua'] = function()
    require('lspconfig').sumneko_lua.setup(vim.tbl_extend('force', lsp_config, {
        settings = {
          Lua = {
            diagnostics = {
              globals = { 'vim' }
            }
          }
        }
      })
    )
  end,
})


-- ====================
-- === Color Scheme ===
-- ====================
vim.cmd('colorscheme everforest')
