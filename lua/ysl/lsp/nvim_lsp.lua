local U = require('ysl.utils')
return {
  {
    'williamboman/mason.nvim',
    build = ':MasonUpdate',
    event = 'VeryLazy',
    cmd = { 'Mason', 'MasonInstall', 'MasonUpdate' },
    config = function()
      require('mason').setup({
        github = { download_url_template = U.GITHUB.RAW .. '%s/releases/download/%s/%s', }
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
        group = U.GROUP.NVIM_LSP,
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
    event = { 'BufReadPost', 'BufNewFile' },
    cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
    dependencies = {
      'williamboman/mason.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'neovim/nvim-lspconfig',
      'hrsh7th/cmp-nvim-lsp', -- LSP source for nvim-cmp
      'folke/neodev.nvim',
      'b0o/schemastore.nvim',
      'simrat39/rust-tools.nvim',
    },
    config = function()
      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true
      }

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                callSnippet = 'Replace'
              },
              telemetry = { enable = false },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              diagnostics = { disable = { 'missing-fields' } },
            }
          }
        },
        jedi_language_server = {},
        json_ls = {
          settings = {
            json = {
              schemas = require('schemastore').json.schemas(),
              validate = { enable = true },
            },
          }
        },
        vimls = {},
        bashls = {},
        marksman = {},
        sourcery = {},
        clangd = {},
        ruff_lsp = {
          on_attach = function(client, bufnr)
            -- Ref: https://github.com/astral-sh/ruff-lsp/issues/78
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.hoverProvider = false
            client.server_capabilities.renameProvider = false
          end
        },
        typst_lsp = {}
      }

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'rust_analyzer',
      })

      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('neodev').setup({
        -- add any options here, or leave empty to use the default settings
      })

      require('rust-tools').setup({
        server = {
          capabilities = capabilities,
        }
      })

      require('mason-lspconfig').setup {
        handlers = {
          function (server_name) -- default handler (optional)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for tsserver)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
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
      require('luasnip.loaders.from_vscode').lazy_load({ paths = {
        U.CUSTOM_SNIPPETS_PATH,
        U.path({vim.fn.stdpath('data'), 'lazy', 'friendly-snippets'}),
        U.path({vim.fn.stdpath('data'), 'lazy', 'cython-snips'}),
      }})
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
    'ysl2/nvim-cmp', -- Autocompletion plugin
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp', -- LSP source for nvim-cmp
      'hrsh7th/cmp-buffer',
      'https://codeberg.org/FelipeLema/cmp-async-path',
      'L3MON4D3/LuaSnip', -- Snippets plugin
      'saadparwaiz1/cmp_luasnip', -- Snippets source for nvim-cmp
      {
        'tzachar/cmp-tabnine',
        build = (vim.fn.has('win32') == 1) and 'powershell ./install.ps1' or './install.sh',
      },
      'hrsh7th/cmp-nvim-lua',
      'onsails/lspkind.nvim',
      'windwp/nvim-autopairs',
      'saecki/crates.nvim',
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
          -- ['<Tab>'] = cmp.mapping(function(fallback)
          --   if cmp.visible() then
          --     cmp.select_next_item()
          --   else
          --     fallback()
          --   end
          -- end, { 'i', 's' }),
          -- ['<S-Tab>'] = cmp.mapping(function(fallback)
          --   if cmp.visible() then
          --     cmp.select_prev_item()
          --   else
          --     fallback()
          --   end
          -- end, { 'i', 's' }),
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
          { name = 'crates' },
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
          ghost_text = false,
        }
      })

      -- If you want insert `(` after select function or method item
      cmp.event:on(
        'confirm_done',
        require('nvim-autopairs.completion.cmp').on_confirm_done()
      )
    end
  },
  -- {
  --   'nvimtools/none-ls.nvim',
  --   event = { 'BufReadPost', 'BufNewFile' },
  --   dependencies = {
  --     'nvim-lua/plenary.nvim',
  --   },
  --   config = function()
  --       local null_ls = require('null-ls')
  --       -- local cspell = {
  --       --   filetypes = U.LSP.CSPELL.FILETYPES,
  --       --   extra_args = {
  --       --     '--config=' .. U.LSP.CSPELL.EXTRA_ARGS.CONFIG
  --       --   },
  --       -- }
  --       null_ls.setup({
  --         -- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
  --         sources = {
  --           null_ls.builtins.code_actions.gitsigns,
  --           null_ls.builtins.completion.luasnip,
  --           null_ls.builtins.completion.spell,
  --           -- null_ls.builtins.diagnostics.cspell.with(cspell),
  --           -- null_ls.builtins.code_actions.cspell.with(cspell),
  --           null_ls.builtins.completion.tags,
  --           -- null_ls.builtins.diagnostics.flake8.with({ extra_args = U.LSP.FLAKE8.EXTRA_ARGS }),
  --           -- null_ls.builtins.formatting.black.with({ extra_args = U.LSP.BLACK.EXTRA_ARGS }),
  --           null_ls.builtins.formatting.stylua,
  --           -- BUG: here.
  --           -- null_ls.builtins.code_actions.shellcheck,
  --           null_ls.builtins.formatting.shfmt,
  --           null_ls.builtins.diagnostics.markdownlint
  --         }
  --       })
  --   end,
  -- },
  -- {
  --     'jay-babu/mason-null-ls.nvim',
  --     event = { 'BufReadPost', 'BufNewFile' },
  --     dependencies = {
  --       'williamboman/mason.nvim',
  --       'nvimtools/none-ls.nvim',
  --     },
  --     config = function()
  --       require('mason-null-ls').setup({
  --           ensure_installed = nil,
  --           automatic_installation = true,
  --       })
  --     end,
  -- },
  {
    'smjonas/inc-rename.nvim',
    event = 'VeryLazy',
    config = function()
      require('inc_rename').setup()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = U.GROUP.NVIM_LSP,
        callback = function(ev)
          vim.keymap.set('n', '\\rn', function()
            return ':IncRename ' .. vim.fn.expand('<cword>')
          end, { expr = true })
        end
      })
    end,
  },
  -- {
  --   'saecki/crates.nvim',
  --   event = 'VeryLazy',
  --   dependencies = {
  --     'nvim-lua/plenary.nvim',
  --     'nvimtools/none-ls.nvim',
  --   },
  --   config = function()
  --     require('crates').setup({
  --       null_ls = {
  --         enabled = true,
  --       },
  --     })
  --   end
  -- },
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo', 'Format', 'MySaveAndFormatToggle' },
    config = function()
      require('conform').setup({
        formatters_by_ft = {
          lua = { 'stylua' },
          python = { 'ruff_lsp' },
        },
      })

      vim.api.nvim_create_user_command('Format', function(args)
        local range = nil
        if args.count ~= -1 then
          local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
          range = {
            start = { args.line1, 0 },
            ['end'] = { args.line2, end_line:len() },
          }
        end
        require('conform').format({ async = true, lsp_fallback = true, range = range })
      end, { range = true })

      require('conform').setup({
        format_on_save = function(bufnr)
          if vim.g.autoformat or vim.b[bufnr].autoformat then
            return { timeout_ms = 500, lsp_fallback = true }
          end
        end
      })

      vim.api.nvim_create_user_command('MySaveAndFormatToggle', function(args)
        if args.bang then
          -- FormatDisable! will disable formatting just for this buffer
          if vim.b.autoformat then
            vim.b.autoformat = false
          else
            vim.b.autoformat = true
          end
          print('"vim.b.autoformat" = ' .. tostring(vim.b.autoformat))
        else
          if vim.g.autoformat then
            vim.g.autoformat = false
          else
            vim.g.autoformat = true
          end
          print('"vim.g.autoformat" = ' .. tostring(vim.g.autoformat))
        end
      end, {
        desc = 'Re-enable autoformat-on-save',
        bang = true,
      })

    end
  },
  {
    'zapling/mason-conform.nvim',
    event = 'VeryLazy',
    dependencies = {
      'williamboman/mason.nvim',
      'stevearc/conform.nvim',
    },
    config = function()
      require('mason-conform').setup()
    end
  },
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufReadPost', 'BufNewFile', 'InsertLeave' },
    config = function()
      local lint = require('lint')
      lint.linters_by_ft = {
        markdown = {'markdownlint',}
      }

      vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufReadPost', 'BufNewFile', 'InsertLeave' }, {
        callback = function()

          -- try_lint without arguments runs the linters defined in `linters_by_ft`
          -- for the current filetype
          lint.try_lint()

          -- You can call `try_lint` with a linter name or a list of names to always
          -- run specific linters, independent of the `linters_by_ft` configuration
          -- require('lint').try_lint('cspell')
        end,
      })
    end
  },
  {
    'rshkarin/mason-nvim-lint',
    event = 'VeryLazy',
    dependencies = {
      'williamboman/mason.nvim',
      'mfussenegger/nvim-lint',
    },
    config = function()
      require('mason-nvim-lint').setup()
    end
  }
}
