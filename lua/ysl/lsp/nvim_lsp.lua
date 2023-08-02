
local U = require('ysl.utils')
local augroup = vim.api.nvim_create_augroup('UserLspConfig', {})
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
      require('lualine').setup({
        options = {
          section_separators = { left = '', right = '' },
          component_separators = { left = '', right = '' }
        },
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
    'williamboman/mason.nvim',
    cmd = 'Mason',
    config = function()
      require('mason').setup({
        github = { download_url_template = 'https://ghproxy.com/https://github.com/%s/releases/download/%s/%s', }
      })
    end
  },
  {
    'williamboman/mason-lspconfig.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      {
        'hrsh7th/nvim-cmp', -- Autocompletion plugin
        event = 'InsertEnter',
        dependencies = {
          {
            'SmiteshP/nvim-navic',
            dependencies = {
              {
                'neovim/nvim-lspconfig',
                event = { 'BufReadPre', 'BufNewFile' },
                config = function()
                  -- Global mappings.
                  -- See `:help vim.diagnostic.*` for documentation on any of the below functions
                  vim.keymap.set('n', '\\e', vim.diagnostic.open_float)
                  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
                  vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
                  vim.keymap.set('n', '\\q', vim.diagnostic.setloclist)

                  -- Use LspAttach autocommand to only map the following keys
                  -- after the language server attaches to the current buffer
                  vim.api.nvim_create_autocmd('LspAttach', {
                    group = augroup,
                    callback = function(ev)
                      -- Enable completion triggered by <c-x><c-o>
                      vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

                      -- Buffer local mappings.
                      -- See `:help vim.lsp.*` for documentation on any of the below functions
                      local opts = { buffer = ev.buf }
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
                      vim.keymap.set('n', '\\rn', vim.lsp.buf.rename, opts)
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

                  local signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }
                  for type, icon in pairs(signs) do
                    local hl = 'DiagnosticSign' .. type
                    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
                  end
                end
              },
            },
            config = function()
               vim.api.nvim_create_autocmd('LspAttach', {
               group = augroup,
               callback = function(ev)
                 local client = vim.lsp.get_client_by_id(ev.data.client_id)
                 if client.server_capabilities['documentSymbolProvider'] then
                   require('nvim-navic').attach(client, ev.buf)
                 end
               end,
             })
            end
          },
          'hrsh7th/cmp-nvim-lsp', -- LSP source for nvim-cmp
          'hrsh7th/cmp-buffer',
          'hrsh7th/cmp-path',
          'hrsh7th/cmp-cmdline',
          {
            'L3MON4D3/LuaSnip', -- Snippets plugin
            dependencies = { 'rafamadriz/friendly-snippets' },
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
          'saadparwaiz1/cmp_luasnip', -- Snippets source for nvim-cmp
          {
            'tzachar/cmp-tabnine',
            build = (vim.fn.has('win32') == 1) and 'powershell ./install.ps1' or './install.sh',
          },
          'onsails/lspkind.nvim',
          {
            'windwp/nvim-autopairs',
            event = "InsertEnter",
            opts = {}
          },
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
              -- ['<CR>'] = cmp.mapping(cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace,
              --   select = true, }, { 'i', 'c' }),
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
                if require('luasnip').expand_or_jumpable() then
                  vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-expand-or-jump', true, true, true), "")
                else
                  fallback()
                end
              end, { 'i', 's' }),
              ['<C-k>'] = cmp.mapping(function(fallback)
                if require('luasnip').jumpable( -1) then
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
                local splits = U.mysplit(entry.source.name, '_')
                vim_item.menu = '[' .. string.upper(splits[#splits]) .. ']'
                if entry.source.name == 'cmp_tabnine' then
                  local detail = (entry.completion_item.data or {}).detail
                  vim_item.kind = ''
                  if detail and detail:find('.*%%.*') then
                    vim_item.kind = vim_item.kind .. ' ' .. detail
                  end
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
              { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
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
        end
      },
      'williamboman/mason.nvim',
      {
        'folke/neodev.nvim',
        config = function()
          -- IMPORTANT: make sure to setup neodev BEFORE lspconfig
          require('neodev').setup({
            -- add any options here, or leave empty to use the default settings
          })
        end
      },
      'b0o/schemastore.nvim',
    },
    config = function()
      -- Add additional capabilities supported by nvim-cmp
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true
      }

      local lspconfig = require('lspconfig')
      require('mason-lspconfig').setup {
        ensure_installed = { 'lua_ls', 'jedi_language_server', 'jsonls', },
        automatic_installation = true,
        handlers = {
          -- The first entry (without a key) will be the default handler
          -- and will be called for each installed server that doesn't have
          -- a dedicated handler.
          function (server_name) -- default handler (optional)
              lspconfig[server_name].setup({
                -- on_attach = my_custom_on_attach,
                capabilities = capabilities,
              })
          end,
          -- Next, you can provide a dedicated handler for specific servers.
          -- For example, a handler override for the `rust_analyzer`:
          ['lua_ls'] = function ()
            lspconfig.lua_ls.setup(vim.tbl_deep_extend('force', lspconfig, {
              settings = {
                Lua = {
                  workspace = {
                    checkThirdParty = false,
                  },
                  completion = {
                    callSnippet = 'Replace'
                  }
                }
              }
            }))
          end,
          ['jsonls'] = function ()
            lspconfig.jsonls.setup(vim.tbl_deep_extend('force', lspconfig, {
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
    'j-hui/fidget.nvim',
    tag = 'legacy',
    event = 'LspAttach',
    opts = {
      -- options
    },
  },
  {
      'jay-babu/mason-null-ls.nvim',
      event = { 'BufReadPre', 'BufNewFile' },
      dependencies = {
        {
          'jose-elias-alvarez/null-ls.nvim',
          event = { 'BufReadPre', 'BufNewFile' },
          dependencies = {
            'nvim-lua/plenary.nvim',
            'williamboman/mason.nvim',
          },
          config = function()
              local null_ls = require('null-ls')
              null_ls.setup({
                sources = {
                  -- null_ls.builtins.code_actions.gitsigns,
                  -- null_ls.builtins.code_actions.shellcheck,
                  -- null_ls.builtins.completion.luasnip,
                  -- null_ls.builtins.completion.spell,
                  -- null_ls.builtins.completion.tags,
                  -- null_ls.builtins.diagnostics.codespell,
                  -- null_ls.builtins.diagnostics.commitlint,
                  -- null_ls.builtins.diagnostics.flake8,
                  -- null_ls.builtins.diagnostics.luacheck,
                  -- null_ls.builtins.diagnostics.markdownlint,
                  -- null_ls.builtins.diagnostics.pydocstyle,
                  -- null_ls.builtins.diagnostics.shellcheck,
                  -- null_ls.builtins.formatting.black,
                  -- null_ls.builtins.formatting.codespell,
                  -- null_ls.builtins.formatting.latexindent,
                  -- null_ls.builtins.formatting.lua_format,
                  -- null_ls.builtins.formatting.prettier,
                  -- null_ls.builtins.formatting.shfmt
                }
              })
          end,
        }
      },
      config = function()
        require('mason-null-ls').setup({
            ensure_installed = {
              -- linter
              'luacheck',

              -- formatter
              'stylua',
            },
            automatic_installation = true,
            handlers = {},
        })
      end,
  }
}
