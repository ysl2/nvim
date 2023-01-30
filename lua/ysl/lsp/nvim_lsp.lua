local M = {}

M.plugins = {
  'williamboman/mason.nvim',
  'williamboman/mason-lspconfig.nvim',
  'neovim/nvim-lspconfig',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-cmdline',
  'hrsh7th/nvim-cmp',
  { 'L3MON4D3/LuaSnip', config = function() require('luasnip.loaders.from_snipmate').load() end },
  'saadparwaiz1/cmp_luasnip',
  'onsails/lspkind.nvim',
  { 'tzachar/cmp-tabnine', build = (vim.fn.has('win32') == 1) and 'powershell ./install.ps1' or './install.sh',
    dependencies = 'hrsh7th/nvim-cmp' },
  'b0o/schemastore.nvim',
  { 'glepnir/lspsaga.nvim', event = 'BufRead' },
  { 'folke/neodev.nvim', config = function() require('neodev').setup {} end },
  { 'kevinhwang91/nvim-bqf', ft = 'qf' }
}

M.configurate = function()
  local callback = {}

  -- ===
  -- === williamboman/mason
  -- ===
  require('mason').setup({
    github = { download_url_template = 'https://ghproxy.com/https://github.com/%s/releases/download/%s/%s', }
  })

  -- ===
  -- === williamboman/mason-lspconfig
  -- ===
  local mason_lspconfig = require('mason-lspconfig')
  mason_lspconfig.setup({
    ensure_installed = { 'pyright', 'sumneko_lua', 'jsonls' },
    automatic_installation = true,
  })

  -- ===
  -- === neovim/nvim-lspconfig
  -- ===
  -- Mappings.
  -- See `:help vim.diagnostic.*` for documentation on any of the below functions
  vim.keymap.set('n', '\\e', vim.diagnostic.open_float, { silent = true })
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { silent = true })
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { silent = true })
  vim.keymap.set('n', '\\q', vim.diagnostic.setloclist, { silent = true })

  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local bufopts = { silent = true, buffer = bufnr }
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
    -- vim.keymap.set('n', '\\ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', '\\f', function() vim.lsp.buf.format { async = true } end, bufopts)

    vim.api.nvim_create_autocmd('CursorHold', {
      buffer = bufnr,
      callback = function()
        local opts = {
          focusable = false,
          close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter', 'FocusLost' },
          source = 'always',
          prefix = ' ',
          scope = 'cursor',
        }
        vim.diagnostic.open_float(nil, opts)
      end
    })

  end

  vim.diagnostic.config({
    virtual_text = {
      source = 'always',
      severity = { min = vim.diagnostic.severity.ERROR },
    },
    float = {
      source = 'always',
    },
    update_in_insert = true,
    severity_sort = true,
  })

  local signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }
  for type, icon in pairs(signs) do
    local hl = 'DiagnosticSign' .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end

  -- ===
  -- === hrsh7th/nvim-cmp
  -- ===
  local function mysplit(inputstr, sep)
    if sep == nil then
      sep = '%s'
    end
    local t = {}
    for str in string.gmatch(inputstr, '([^' .. sep .. ']+)') do
      table.insert(t, str)
    end
    return t
  end

  local has_words_before = function()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
  end

  local cmp = require('cmp')
  local luasnip = require('luasnip')
  cmp.setup({
    completion = { completeopt = 'menu,menuone,noinsert' },
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      -- ['<CR>'] = cmp.mapping(cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace,
      --   select = true, }, { 'i', 'c' }),
      ['<CR>'] = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace,
        select = true, },
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<C-j>'] = cmp.mapping(function(fallback)
        if require('luasnip').expand_or_jumpable() then
          vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-expand-or-jump', true, true, true), "")
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<C-k>'] = cmp.mapping(function(fallback)
        if require('luasnip').jumpable(-1) then
          vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-jump-prev', true, true, true), "")
        else
          fallback()
        end
      end, { 'i', 's' }),
    }),
    sources = cmp.config.sources({
      { name = 'cmp_tabnine' },
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
    }, {
      { name = 'buffer' },
      { name = 'path' },
    }),
    formatting = {
      format = function(entry, vim_item)
        vim_item.kind = require('lspkind').symbolic(vim_item.kind, { mode = 'symbol_text' })
        local splits = mysplit(entry.source.name, '_')
        vim_item.menu = '[' .. string.upper(splits[#splits]) .. ']'
        if entry.source.name == 'cmp_tabnine' then
          local detail = (entry.completion_item.data or {}).detail
          vim_item.kind = ''
          -- if detail and detail:find('.*%%.*') then
          --   vim_item.kind = vim_item.kind .. ' ' .. detail
          -- end
          vim_item.kind = vim_item.kind .. ' Tabnine'

          if (entry.completion_item.data or {}).multiline then
            vim_item.kind = vim_item.kind .. ' ' .. '[ML]'
          end
        end
        local maxwidth = 80
        vim_item.abbr = string.sub(vim_item.abbr, 1, maxwidth)
        return vim_item
      end,
    }
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ '/', '?' }, {
    enabled = false,
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    enabled = false,
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  -- If you want insert `(` after select function or method item
  cmp.event:on(
    'confirm_done',
    require('nvim-autopairs.completion.cmp').on_confirm_done()
  )

  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true
  }

  local lsp_config = {
    capabilities = capabilities,
    on_attach = on_attach,
  }

  local lspconfig = require('lspconfig')
  mason_lspconfig.setup_handlers({
    -- The first entry (without a key) will be the default handler
    -- and will be called for each installed server that doesn't have
    -- a dedicated handler.
    function(server_name) -- default handler (optional)
      lspconfig[server_name].setup(lsp_config)
    end,
    -- Next, you can provide targeted overrides for specific servers.
    ['sumneko_lua'] = function()
      lspconfig.sumneko_lua.setup(vim.tbl_extend('force', lsp_config, {
        settings = {
          Lua = {
            diagnostics = {
              globals = { 'vim' }
            }
          }
        }
      }))
    end,
    ['jsonls'] = function()
      lspconfig.jsonls.setup(vim.tbl_extend('force', lsp_config, {
        settings = {
          json = {
            schemas = require('schemastore').json.schemas(),
            validate = { enable = true },
          },
        },
      }))
    end,
  })

  -- Stop snippets when you leave to normal mode
  vim.api.nvim_create_autocmd('ModeChanged', {
    callback = function()
      if ((vim.v.event.old_mode == 's' and vim.v.event.new_mode == 'n') or vim.v.event.old_mode == 'i')
          and luasnip.session.current_nodes[vim.api.nvim_get_current_buf()]
          and not luasnip.session.jump_active
      then
        luasnip.unlink_current()
      end
    end
  })

  -- ===
  -- === glepnir/lspsaga.nvim
  -- ===
  require('lspsaga').setup({
    lightbulb = {
      virtual_text = false,
    },
    ui = {
      border = 'single',
      colors = {
        --float window normal bakcground color
        normal_bg = '#2e3440',
      }
    }
  })
  -- Lsp finder find the symbol definition implement reference
  -- if there is no implement it will hide
  -- when you use action in finder like open vsplit then you can
  -- use <C-t> to jump back
  vim.keymap.set('n', 'gh', '<cmd>Lspsaga lsp_finder<CR>', { silent = true })

  -- Code action
  vim.keymap.set({ 'n', 'v' }, '\\ca', '<cmd>Lspsaga code_action<CR>', { silent = true })

  -- ===
  -- === folke/trouble.nvim
  -- ===
  vim.keymap.set('n', '<leader>xx', '<cmd>TroubleToggle<cr>', { silent = true })
  vim.keymap.set('n', '<leader>xw', '<cmd>TroubleToggle workspace_diagnostics<cr>', { silent = true })
  vim.keymap.set('n', '<leader>xd', '<cmd>TroubleToggle document_diagnostics<cr>', { silent = true })
  vim.keymap.set('n', '<leader>xl', '<cmd>TroubleToggle loclist<cr>', { silent = true })
  vim.keymap.set('n', '<leader>xq', '<cmd>TroubleToggle quickfix<cr>', { silent = true })
  vim.keymap.set('n', 'gR', '<cmd>TroubleToggle lsp_references<cr>', { silent = true })

  -- ===
  -- === windwp/nvim-autopairs
  -- ==
  require('nvim-autopairs').setup {}

  -- ===
  -- === akinsho/bufferline.nvim
  -- ===
  callback.bufferline = {
    options = {
      diagnostics = 'nvim_lsp',
    }
  }

  return callback
end

return M
