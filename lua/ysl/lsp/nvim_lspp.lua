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
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      {
        'williamboman/mason.nvim',
        build = function ()
          vim.cmd('MasonInstall')
        end,
        config = function()
          require('mason').setup({
            github = { download_url_template = 'https://ghproxy.com/https://github.com/%s/releases/download/%s/%s', }
          })
        end
      },
      {
        'neovim/nvim-lspconfig',
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
          'hrsh7th/nvim-cmp', -- Autocompletion plugin
          'hrsh7th/cmp-nvim-lsp', -- LSP source for nvim-cmp
          'saadparwaiz1/cmp_luasnip', -- Snippets source for nvim-cmp
          'L3MON4D3/LuaSnip', -- Snippets plugin
        },
        config = function()
          -- Global mappings.
          -- See `:help vim.diagnostic.*` for documentation on any of the below functions
          -- vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
          vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

          -- Use LspAttach autocommand to only map the following keys
          -- after the language server attaches to the current buffer
          vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('UserLspConfig', {}),
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
              vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
              vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
              vim.keymap.set('n', '<space>wl', function()
                print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
              end, opts)
              vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
              vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
              vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
              vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
              vim.keymap.set('n', '<space>f', function()
                vim.lsp.buf.format { async = true }
              end, opts)
            end,
          })

          -- luasnip setup
          local luasnip = require 'luasnip'

          -- nvim-cmp setup
          local cmp = require 'cmp'
          cmp.setup {
            snippet = {
              expand = function(args)
                luasnip.lsp_expand(args.body)
              end,
            },
            mapping = cmp.mapping.preset.insert({
              ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Up
              ['<C-d>'] = cmp.mapping.scroll_docs(4), -- Down
              -- C-b (back) C-f (forward) for snippet placeholder navigation.
              ['<C-Space>'] = cmp.mapping.complete(),
              ['<CR>'] = cmp.mapping.confirm {
                behavior = cmp.ConfirmBehavior.Replace,
                select = true,
              },
              ['<Tab>'] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                elseif luasnip.expand_or_jumpable() then
                  luasnip.expand_or_jump()
                else
                  fallback()
                end
              end, { 'i', 's' }),
              ['<S-Tab>'] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                  luasnip.jump(-1)
                else
                  fallback()
                end
              end, { 'i', 's' }),
            }),
            sources = {
              { name = 'nvim_lsp' },
              { name = 'luasnip' },
            },
          }
        end
      },
      'b0o/schemastore.nvim'
    },
    config = function()
      -- Add additional capabilities supported by nvim-cmp
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      local lspconfig = require("lspconfig")

      require('mason-lspconfig').setup {
        ensure_installed = { 'lua_ls', 'jedi_language_server', 'jsonls', 'shellcheck' },
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
            lspconfig.lua_ls.setup({
              settings = {
                Lua = {
                  diagnostics = {
                    globals = { "vim" }
                  }
                }
              }
            })
          end,
          ['jsonls'] = function ()
            lspconfig.jsonls.setup({
              settings = {
                json = {
                  schemas = require('schemastore').json.schemas(),
                  validate = { enable = true },
                },
              }
            })
          end,
        },
      }
    end
  },
  {
    'jose-elias-alvarez/null-ls.nvim',
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local null_ls = require('null-ls')
        null_ls.setup({
          sources = {
            null_ls.builtins.code_actions.gitsigns,
            null_ls.builtins.code_actions.shellcheck,
            null_ls.builtins.completion.luasnip,
            null_ls.builtins.completion.spell,
            null_ls.builtins.completion.tags,
            -- null_ls.builtins.diagnostics.codespell,
            null_ls.builtins.diagnostics.commitlint,
            null_ls.builtins.diagnostics.flake8,
            -- null_ls.builtins.diagnostics.luacheck,
            null_ls.builtins.diagnostics.markdownlint,
            null_ls.builtins.diagnostics.pydocstyle,
            null_ls.builtins.diagnostics.shellcheck,
            null_ls.builtins.formatting.black,
            null_ls.builtins.formatting.codespell,
            null_ls.builtins.formatting.latexindent,
            null_ls.builtins.formatting.lua_format,
            null_ls.builtins.formatting.prettier,
            null_ls.builtins.formatting.shfmt
          }
        })
    end,
  }
}
