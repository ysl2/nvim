local U = require('ysl.utils')
return {
  {
    'williamboman/mason.nvim',
    build = ':MasonUpdate',
    cmd = { 'Mason', 'MasonInstall', 'MasonUpdate' },
    config = function()
      require('mason').setup({
        github = { download_url_template = 'https://ghproxy.com/https://github.com/%s/releases/download/%s/%s', }
      })
    end
  },
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      -- Use LspAttach autocommand to only map the following keys
      -- after the language server attaches to the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = U.GROUP_NVIM_LSP,
        callback = function(ev)
          -- Enable completion triggered by <c-x><c-o>
          vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

          local opts = { buffer = ev.buf }

          -- Global mappings.
          -- See `:help vim.diagnostic.*` for documentation on any of the below functions
          vim.keymap.set('n', '\\e', vim.diagnostic.open_float, opts)
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
          vim.keymap.set('n', '\\q', vim.diagnostic.setloclist, opts)

          -- Buffer local mappings.
          -- See `:help vim.lsp.*` for documentation on any of the below functions
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
          vim.keymap.set('n', '\\wa', vim.lsp.buf.add_workspace_folder, opts)
          vim.keymap.set('n', '\\wr', vim.lsp.buf.remove_workspace_folder, opts)
          vim.keymap.set('n', '\\wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts)
          vim.keymap.set('n', '\\D', vim.lsp.buf.type_definition, opts)
          -- vim.keymap.set('n', '\\rn', vim.lsp.buf.rename, opts)
          vim.keymap.set({ 'n', 'v' }, '\\ca', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', '\\f', function()
            vim.lsp.buf.format { async = true }
          end, opts)

          vim.api.nvim_create_autocmd('CursorHold', {
            buffer = ev.buf,
            callback = function()
              vim.diagnostic.open_float(nil, {
                focusable = false,
                close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter', 'FocusLost' },
                source = 'always',
                prefix = ' ',
                scope = 'cursor',
              })
            end
          })
        end,
      })

      vim.diagnostic.config({
        virtual_text = false,
        float = false,
      })

      for type, icon in pairs(U.SIGNS) do
        local hl = 'DiagnosticSign' .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end
    end
  },
  {
    'williamboman/mason-lspconfig.nvim',
    cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = {
      'williamboman/mason.nvim',
      'neovim/nvim-lspconfig',
      'hrsh7th/cmp-nvim-lsp', -- LSP source for nvim-cmp
      'folke/neodev.nvim',
      'b0o/schemastore.nvim',
    },
    config = function()
      -- IMPORTANT: make sure to setup neodev BEFORE lspconfig
      require('neodev').setup({
        -- add any options here, or leave empty to use the default settings
      })

      -- Add additional capabilities supported by nvim-cmp
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true
      }

      local lspconfig = require('lspconfig')
      local default = {
        -- on_attach = my_custom_on_attach,
        capabilities = vim.tbl_deep_extend('force',
          lspconfig.util.default_config.capabilities,
          capabilities
        )
      }
      require('mason-lspconfig').setup {
        ensure_installed = { 'lua_ls', 'jedi_language_server', 'jsonls', 'vimls', 'bashls' },
        automatic_installation = true,
        handlers = {
          -- The first entry (without a key) will be the default handler
          -- and will be called for each installed server that doesn't have
          -- a dedicated handler.
          function (server_name) -- default handler (optional)
              lspconfig[server_name].setup(default)
          end,
          -- Next, you can provide a dedicated handler for specific servers.
          -- For example, a handler override for the `rust_analyzer`:
          ['lua_ls'] = function ()
            lspconfig.lua_ls.setup(vim.tbl_deep_extend('force', default, {
              settings = {
                Lua = {
                  workspace = {
                    checkThirdParty = false,
                  },
                  completion = {
                    callSnippet = 'Replace'
                  },
                  telemetry = { enable = false },
                }
              }
            }))
          end,
          ['jsonls'] = function ()
            lspconfig.jsonls.setup(vim.tbl_deep_extend('force', default, {
              settings = {
                json = {
                  schemas = require('schemastore').json.schemas(),
                  validate = { enable = true },
                },
              }
            }))
          end,
        },
      }
    end
  },
  {
    'L3MON4D3/LuaSnip', -- Snippets plugin
    build = 'make install_jsregexp',
    lazy = true,
    config = function ()
      require('luasnip.loaders.from_vscode').lazy_load()
      local luasnip = require('luasnip')
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
    end
  },
  {
    'yioneko/nvim-cmp', -- Autocompletion plugin
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp', -- LSP source for nvim-cmp
      'hrsh7th/cmp-buffer',
      'FelipeLema/cmp-async-path',
      'L3MON4D3/LuaSnip', -- Snippets plugin
      'saadparwaiz1/cmp_luasnip', -- Snippets source for nvim-cmp
      {
        'tzachar/cmp-tabnine',
        build = (vim.fn.has('win32') == 1) and 'powershell ./install.ps1' or './install.sh',
      },
      'hrsh7th/cmp-nvim-lua',
      'onsails/lspkind.nvim',
      'windwp/nvim-autopairs',
    },
    config = function ()
      -- Set up nvim-cmp.
      local cmp = require'cmp'
      local luasnip = require('luasnip')
      cmp.setup({
        completion = { completeopt = 'menu,menuone,noinsert' },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body) -- For `luasnip` users.
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = true, },
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
            if luasnip.expand_or_jumpable() then
              vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-expand-or-jump', true, true, true), "")
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<C-k>'] = cmp.mapping(function(fallback)
            if luasnip.jumpable(-1) then
              vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-jump-prev', true, true, true), "")
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'cmp_tabnine' },
          { name = 'luasnip' },
          { name = 'nvim_lua' },
          { name = 'nvim_lsp' },
          { name = 'async_path' },
        }, {
          { name = 'buffer' },
        }),
        formatting = {
          fields = {'abbr', 'kind', 'menu'},
          format = require('lspkind').cmp_format({
            mode = 'symbol_text', -- show only symbol annotations
            maxwidth = 50, -- prevent the popup from showing more than provided characters
            ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead
          })
        },
        experimental = {
          ghost_text = true,
        }
      })

      -- If you want insert `(` after select function or method item
      cmp.event:on(
        'confirm_done',
        require('nvim-autopairs.completion.cmp').on_confirm_done()
      )
    end
  },
  {
    'jose-elias-alvarez/null-ls.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
        local null_ls = require('null-ls')
        local cspell = {
          filetypes = { 'markdown', 'plaintext' },
          extra_args = {
            '--config=' .. U.CSPELL_JSON_PATH
          },
        }
        null_ls.setup({
          -- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
          sources = {
            null_ls.builtins.code_actions.gitsigns,
            null_ls.builtins.completion.luasnip,
            null_ls.builtins.completion.spell,
            null_ls.builtins.diagnostics.cspell.with(cspell),
            null_ls.builtins.code_actions.cspell.with(cspell),
            null_ls.builtins.completion.tags,
            null_ls.builtins.diagnostics.flake8.with({ extra_args = {
              '--max-line-length=120',
              '--ignore=ANN101,ANN102,E402,E741,E203'
            }}),
            null_ls.builtins.formatting.black.with({ extra_args = {
              '--line-length=120',
              '--skip-string-normalization'
            }}),
            null_ls.builtins.formatting.stylua,
            null_ls.builtins.code_actions.shellcheck,
            null_ls.builtins.formatting.shfmt,
          }
        })
    end,
  },
  {
      'jay-babu/mason-null-ls.nvim',
      event = { 'BufReadPost', 'BufNewFile' },
      dependencies = {
        'williamboman/mason.nvim',
        'jose-elias-alvarez/null-ls.nvim',
      },
      config = function()
        require('mason-null-ls').setup({
            ensure_installed = nil,
            automatic_installation = true,
        })
      end,
  },
  {
    'smjonas/inc-rename.nvim',
    event = 'VeryLazy',
    config = function()
      require('inc_rename').setup()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = U.GROUP_NVIM_LSP,
        callback = function(ev)
          vim.keymap.set('n', '\\rn', function()
            return ':IncRename ' .. vim.fn.expand('<cword>')
          end, { expr = true })
        end
      })
    end,
  }
}
