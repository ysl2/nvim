local U = require('ysl.utils')
return {
  {
    'neoclide/coc.nvim',
    branch = 'release',
    event = 'VeryLazy',
    dependencies = {
      'honza/vim-snippets',
      {
        'ysl2/coc-rust-analyzer',
        build = 'yarn install --frozen-lockfile'
      },
      {
        'neoclide/jsonc.vim',
        config = function()
          vim.api.nvim_create_autocmd('FileType', {
            pattern = 'json',
            command = [[syntax match Comment +\/\/.\+$+]]
          })
        end
      },
      {
        'ysl2/coc-marksman',
        build = 'yarn install --frozen-lockfile'
      },
    },
    config = function()
      vim.g.coc_global_extensions = {
        'coc-pyright',
        'coc-sh',
        'coc-tabnine',
        'coc-sumneko-lua',
        'coc-marketplace',
        'coc-json',
        'coc-snippets',
        'coc-prettier',
        'coc-vimlsp',
        'coc-tsserver',
        'coc-dictionary',
        'coc-word',
        'coc-clangd',
        'coc-java',
        'coc-markdownlint'
      }

      vim.g.coc_user_config = {}

      -- HACK: Coc config shared by Windows, Linux and Mac.
      local sep = vim.fn.has('win32') == 1 and '\\' or '/'
      vim.g.coc_user_config = vim.tbl_deep_extend('force', vim.g.coc_user_config, {
        ['snippets.ultisnips.directories'] = {
          vim.fn.stdpath('data') .. sep .. 'lazy' .. sep .. 'vim-snippets' .. sep .. 'UltiSnips',
          vim.fn.stdpath('config') .. sep .. 'ultisnips',
        }
      })

      -- HACK: Coc config for specific Windows.
      if vim.fn.has('win32') == 1 then
        -- local U = require('ysl.utils')
        -- local serverDir = U.mysplit(vim.fn.glob(vim.env.HOME .. '\\.vscode\\extensions\\sumneko.lua*\\server'), '\n')
        -- serverDir = serverDir[#serverDir]
        vim.g.coc_user_config = vim.tbl_deep_extend('force', vim.g.coc_user_config, {
          -- ['sumneko-lua.serverDir'] = serverDir
          ['sumneko-lua.serverDir'] = vim.fn.glob(vim.env.HOME .. '\\.vscode\\extensions\\sumneko.lua*\\server'),
          languageserver = {
            sourcery = {
              command = vim.fn.glob('C:\\Python3*\\Lib\\site-packages\\sourcery\\sourcery.exe')
            }
          }
        })
      end

      local function _my_toggle_save_and_format(opts)
        local m
        if #opts.fargs > 1 then
          print('Too many arguments.')
          return
        end
        if #opts.fargs == 1 then
          m = U.toboolean[opts.fargs[1]]
          if m == nil then
            print('Bad argument.')
            return
          end
        else
          m = vim.g.coc_user_config['coc.preferences.formatOnSave']
          m = (m == nil) and true or (not m)
        end
        vim.g.coc_user_config = vim.tbl_deep_extend('force', vim.g.coc_user_config, {
          ['coc.preferences.formatOnSave'] = m
        })
        vim.cmd('silent CocRestart')
        print('"coc.preferences.formatOnSave" = ' .. tostring(m))
      end

      vim.api.nvim_create_user_command('MySaveAndFormatToggle', _my_toggle_save_and_format, {
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

      vim.keymap.set('n', '<LEADER>x', '<CMD>CocDiagnostics<CR>', { silent = true })

      -- Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
      -- delays and poor user experience.

      -- Always show the signcolumn, otherwise it would shift the text each time
      -- diagnostics appear/become resolved.

      -- Auto complete
      function _G.check_back_space()
        local col = vim.fn.col('.') - 1
        return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
      end

      -- Use tab for trigger completion with characters ahead and navigate.
      -- NOTE: There's always complete item selected by default, you may want to enable
      -- no select by `"suggest.noselect": true` in your configuration file.
      -- NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
      -- other plugin before putting this into your config.
      local opts = { silent = true, expr = true, replace_keycodes = false }
      vim.keymap.set('i', '<TAB>',
        'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()'
        ,
        opts)
      vim.keymap.set('i', '<S-TAB>', [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

      -- Make <CR> to accept selected completion item or notify coc.nvim to format
      -- <C-g>u breaks current undo, please make your own choice.
      vim.keymap.set('i', '<cr>', [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]],
        opts)

      -- Use <c-j> to trigger snippets
      -- vim.keymap.set('i', '<c-j>', '<Plug>(coc-snippets-expand-jump)')
      -- Use <c-space> to trigger completion.
      vim.keymap.set('i', '<c-space>', 'coc#refresh()', { silent = true, expr = true })

      -- Use `[g` and `]g` to navigate diagnostics
      -- Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
      vim.keymap.set('n', '[g', '<Plug>(coc-diagnostic-prev)', { silent = true })
      vim.keymap.set('n', ']g', '<Plug>(coc-diagnostic-next)', { silent = true })

      -- GoTo code navigation.
      vim.keymap.set('n', 'gd', '<Plug>(coc-definition)', { silent = true })
      vim.keymap.set('n', 'gy', '<Plug>(coc-type-definition)', { silent = true })
      vim.keymap.set('n', 'gi', '<Plug>(coc-implementation)', { silent = true })
      vim.keymap.set('n', 'gr', '<Plug>(coc-references)', { silent = true })

      -- Use K to show documentation in preview window.
      function _G.show_docs()
        local cw = vim.fn.expand('<cword>')
        if vim.fn.index({ 'vim', 'help' }, vim.bo.filetype) >= 0 then
          vim.api.nvim_command('h ' .. cw)
        elseif vim.api.nvim_eval('coc#rpc#ready()') then
          vim.fn.CocActionAsync('doHover')
        else
          vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
        end
      end

      vim.keymap.set('n', 'K', '<CMD>lua _G.show_docs()<CR>', { silent = true })

      -- Highlight the symbol and its references when holding the cursor.
      vim.api.nvim_create_augroup('CocGroup', {})
      vim.api.nvim_create_autocmd('CursorHold', {
        group = 'CocGroup',
        command = "silent call CocActionAsync('highlight')",
        desc = 'Highlight symbol under cursor on CursorHold'
      })

      -- Symbol renaming.
      vim.keymap.set('n', [[\rn]], '<Plug>(coc-rename)', { silent = true })

      -- Formatting selected code.
      vim.keymap.set('x', [[\f]], '<Plug>(coc-format-selected)', { silent = true })
      vim.keymap.set('n', [[\f]], '<Plug>(coc-format-selected)', { silent = true })

      -- Setup formatexpr specified filetype(s).
      vim.api.nvim_create_autocmd('FileType', {
        group = 'CocGroup',
        pattern = 'typescript,json',
        command = "setl formatexpr=CocAction('formatSelected')",
        desc = 'Setup formatexpr specified filetype(s).'
      })

      -- Update signature help on jump placeholder.
      vim.api.nvim_create_autocmd('User', {
        group = 'CocGroup',
        pattern = 'CocJumpPlaceholder',
        command = "call CocActionAsync('showSignatureHelp')",
        desc = 'Update signature help on jump placeholder'
      })

      -- Applying codeAction to the selected region.
      -- Example: `<leader>aap` for current paragraph
      local opts = { silent = true, nowait = true }
      vim.keymap.set('x', [[\a]], '<Plug>(coc-codeaction-selected)', opts)
      vim.keymap.set('n', [[\a]], '<Plug>(coc-codeaction-selected)', opts)

      -- Remap keys for applying codeAction to the current buffer.
      vim.keymap.set('n', [[\ac]], '<Plug>(coc-codeaction)', opts)

      -- Apply AutoFix to problem on the current line.
      vim.keymap.set('n', [[\qf]], '<Plug>(coc-fix-current)', opts)

      -- Run the Code Lens action on the current line.
      vim.keymap.set('n', [[\cl]], '<Plug>(coc-codelens-action)', opts)

      -- Map function and class text objects
      -- NOTE: Requires 'textDocument.documentSymbol' support from the language server.
      vim.keymap.set('x', 'if', '<Plug>(coc-funcobj-i)', opts)
      vim.keymap.set('o', 'if', '<Plug>(coc-funcobj-i)', opts)
      vim.keymap.set('x', 'af', '<Plug>(coc-funcobj-a)', opts)
      vim.keymap.set('o', 'af', '<Plug>(coc-funcobj-a)', opts)
      vim.keymap.set('x', 'ic', '<Plug>(coc-classobj-i)', opts)
      vim.keymap.set('o', 'ic', '<Plug>(coc-classobj-i)', opts)
      vim.keymap.set('x', 'ac', '<Plug>(coc-classobj-a)', opts)
      vim.keymap.set('o', 'ac', '<Plug>(coc-classobj-a)', opts)

      -- Remap <C-f> and <C-b> for scroll float windows/popups.
      ---@diagnostic disable-next-line: redefined-local
      local opts = { silent = true, nowait = true, expr = true }
      vim.keymap.set('n', '<C-f>', 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
      vim.keymap.set('n', '<C-b>', 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)
      vim.keymap.set('i', '<C-f>',
        'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
      vim.keymap.set('i', '<C-b>',
        'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
      vim.keymap.set('v', '<C-f>', 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
      vim.keymap.set('v', '<C-b>', 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)

      -- Use CTRL-S for selections ranges.
      -- Requires 'textDocument/selectionRange' support of language server.
      vim.keymap.set('n', '<C-s>', '<Plug>(coc-range-select)', { silent = true })
      vim.keymap.set('x', '<C-s>', '<Plug>(coc-range-select)', { silent = true })

      -- Add `:Format` command to format current buffer.
      vim.api.nvim_create_user_command('Format', "call CocAction('format')", {})

      -- " Add `:Fold` command to fold current buffer.
      vim.api.nvim_create_user_command('Fold', "call CocAction('fold', <f-args>)", { nargs = '?' })

      -- Add `:OR` command for organize imports of the current buffer.
      vim.api.nvim_create_user_command('OR', "call CocActionAsync('runCommand', 'editor.action.organizeImport')", {})

      -- Add (Neo)Vim's native statusline support.
      -- NOTE: Please see `:h coc-status` for integrations with external plugins that
      -- provide custom statusline: lightline.vim, vim-airline.
      -- vim.opt.statusline:prepend("%{coc#status()}%{get(b:,'coc_current_function','')}")

      -- Mappings for CoCList
      -- code actions and coc stuff
      ---@diagnostic disable-next-line: redefined-local
      -- local opts = { silent = true, nowait = true }
      -- Show all diagnostics.
      -- vim.keymap.set('n', '<space>a', ':<C-u>CocList diagnostics<cr>', opts)
      -- Manage extensions.
      -- vim.keymap.set('n', '<space>e', ':<C-u>CocList extensions<cr>', opts)
      -- Show commands.
      -- vim.keymap.set('n', '<space>c', ':<C-u>CocList commands<cr>', opts)
      -- Find symbol of current document.
      -- vim.keymap.set('n', '<space>o', ':<C-u>CocList outline<cr>', opts)
      -- Search workspace symbols.
      -- vim.keymap.set('n', '<space>s', ':<C-u>CocList -I symbols<cr>', opts)
      -- Do default action for next item.
      -- vim.keymap.set('n', '<space>j', ':<C-u>CocNext<cr>', opts)
      -- Do default action for previous item.
      -- vim.keymap.set('n', '<space>k', ':<C-u>CocPrev<cr>', opts)
      -- Resume latest coc list.
      -- vim.keymap.set('n', '<space>p', ':<C-u>CocListResume<cr>', opts)

      -- vim.api.nvim_create_autocmd('VimLeavePre', {
      --   command = [[call coc#rpc#kill()]]
      -- })

      vim.api.nvim_create_autocmd('VimLeave', {
        callback = function()
          local killcmd = 'kill -9 -'
          if vim.fn.has('win32') == 1 then
            killcmd = 'Taskkill /F /PID '
          end
          killcmd = killcmd .. vim.g.coc_process_pid
          vim.cmd(("if get(g:, 'coc_process_pid', 0) | call system('%s') | endif"):format(killcmd))
        end
      })
    end
  },
  {
    'ysl2/winbar.nvim',
    event = 'VeryLazy',
    cond = not vim.g.started_by_firenvim,
    dependencies = {
      'SmiteshP/nvim-navic',
      'nvim-tree/nvim-web-devicons'
    },
    config = function()
      require('winbar').setup({
        enabled = true,
        icons = {
          separator = '',
        }
      })
    end
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      local nvim_autopairs = require('nvim-autopairs')
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
          diagnostics = 'coc'
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
        sections = {
          lualine_c = { 'g:coc_status' },
          lualine_x = { 'encoding', 'fileformat', _my_ft },
        },
        inactive_sections = {
          lualine_c = {},
        }
      })
    end
  },
  {
    'fannheyward/telescope-coc.nvim',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'neoclide/coc.nvim',
    },
    event = 'VeryLazy',
    config = function()
      require('telescope').load_extension('coc')
    end
  }
}
