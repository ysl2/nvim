# ysl2/nvim: An ultimate modern neovim pure lua configuration that focuses on KISS principle

![image](https://github.com/ysl2/nvim/assets/39717545/71741871-8792-4ac8-be7b-fe82504c315f)

> TLDR:
>
> 1. Single main file: There is only one main file `./lua/ysl/init.lua` which contains common configuration and lots of common plugins.
> 2. All things you need: language server support & auto completion & diagnostics, file tree, motion, bookmark, register, edit history, buffer & window control, terminal, git, session save & auto restore like vscode, colors & highlight & outlooks, fuzzy find & global replace, remote ssh, markdown image paste & markdown preview
> 3. Original keymap: I don't like to define many custom keymaps so I try my best to keep native keymaps and only map some functions or applications.
> 4. Very fast: All plugins are lazyloaded so you can gain best performance of this configuration.
> 5. Clean: The files are clean and well structured so that you can easily understand and modify them to fit your needs.
> 6. Choose your own: I provide a local config file `./lua/ysl/secret.lua` so that you can cover some default settings like: which colorscheme, which lsp backend, which file to require, add your own plugin list. For example, You can select your lsp backend flavor from `./lua/ysl/lsp/nvim_lsp.lua` or `./lua/ysl/lsp/coc.lua`, default is `nvim_lsp`, choose the one you like from these two files, write it into `./lua/ysl/secret.lua`.
> 7. Integration with others: VSCode's neovim extension support, Chrome input frame edit support.

## Introduction

The configuration is built to fit my needs, might also fit yours. Feel free to use it.

Insights from:

1. Boilerplate: [`kickstart.nvim`](https://github.com/nvim-lua/kickstart.nvim) shows the single file structure, I think it has more benefits than lots of files especially when you're debugging with lots of plugins.
2. Distributions: [`LunarVim`](https://github.com/LunarVim/LunarVim) & [`LazyVim`](https://github.com/LazyVim/LazyVim) & [`NvChad`](https://github.com/NvChad/NvChad) provide the most popular plugins list.
3. Collections: [`awesome-neovim`](https://github.com/rockerBOO/awesome-neovim) provides more special-interest plugins.
4. Personal configs: [`FledgeXu/NeovimZero2Hero`](https://github.com/FledgeXu/NeovimZero2Hero) for minimal lsp & cmp configuration, [`theniceboy/nvim`](https://github.com/theniceboy/nvim) for some useful plugins.
5. Other websites: `chatGPT`, `Google`, `Github`, `Reddit`, `Stackoverflow`, etc.

## Prerequisites, install, update

### Prerequisites

- A build tool: Essential, for enhance telescope performance, choose one below depends on your system.
  - `make` (for MacOS and Linux only)
  - `cmake` (for Windows only)
- A C compiler `clang` or `gcc` (choose one between them): Essential, for nvim-treesitter support.
- `ripgrep`: Essential, for fuzzy search and replace.
- `nerd-font`: Optional, but recommended.
- `npm` & `yarn`: Optional, for some lsp support, markdown preview, and [`coc`](https://github.com/neoclide/coc.nvim) language server backend support.

### Install & update

```bash
# Install
# Option 1. On Linux/MacOS
git clone git@github.com:ysl2/nvim.git ~/.config/nvim
# Option 2. On Windows
git clone git@github.com:ysl2/nvim.git %LOCALAPPDATA%\nvim

# Dependencies
pip install pynvim

# Update: Choose an option below.
# Option 1. If you don't add some modification, you can simply pull from the origin url.
git pull origin master
# Option 2. If you have modified some code yourself, you should fetch then you might need to merge your configuration with origin url
git fetch origin && git merge origin/master --no-edit
```

## Project structure tree, and how to replace the default settings with your local configuration

### Project structure tree

```text
❯ tree --dirsfirst
.
├── lua                                |
│   └── ysl                            |
│       ├── lsp                        | Choose one LSP backend between them.
│       │   ├── coc.lua                | Coc LSP backend.
│       │   └── nvim_lsp.lua           | Nvim built-in LSP backend.
│       ├── init.lua                   | Main configuration file.
│       ├── secret.lua                 | Self local configuration, for overriding some default value. Default not exists, needs to be created by yourself.
│       └── utils.lua                  | Some useful functions.
├─ scripts                             | Some build scripts stored here.
│  └── build_snippets.py               |
├── templates                          |
│   ├── snippets                       | Snippets folder.
│   │   ├── cython.json -> python.json |
│   │   ├── lua.json                   |
│   │   ├── package.json               | Used by LuaSnip to recognize snippets folder structure.
│   │   └── python.json                |
│   ├── cspell.json                    | Words whitelist for cspell diagnostic in markdown file.
│   └── eisvogel.latex                 | Markdown to Latex template.
├── coc-settings.json                  | Coc settings file.
├── init.lua                           | Project entrance. Nvim will read this file first.
├── lazy-lock-coc.json                 | Plugins version tracking file, for coc branch.
├── lazy-lock.json                     | Only be created when lsp backend is nil. E.g, when you use neovim into vscode by vscode's neovim plugin.
├── lazy-lock-nvim_lsp.json            | Plugins version tracking file, for nvim_lsp branch.
├── LICENSE                            |
└── README.md                          |

6 directories, 19 files
```

### Replace the default settings with your local configuration

Put the code below into `./lua/ysl/secret.lua`

```lua
-- ./lua/ysl/secret.lua

local M = {}

-- M.requires, default value: { 'ysl.lsp.nvim_lsp' }
M.requires = {
  'ysl.lsp.coc'  -- Use coc to override default LSP backend (default: nvim_lsp).
  -- 'ysl.lsp.nvim_lsp'
}

-- M.plugins, default value: {}
-- You can add some plugins into the table, lazy.nvim plugins manager will load them.
-- M.plugins = {}

-- M.config, default value: {}
M.config = {
  vim = {
    opt = {
      -- WARNING: Transparency is an experimental feature now.
      -- winblend = 70  -- Uncomment this to enable transparency.
    }
  }
}

-- M.colorscheme, default value: { 'folke/tokyonight.nvim' }
-- You can specify `colorscheme` to override default colorscheme.
-- M.colorscheme = {
--   {
--     'folke/tokyonight.nvim',
--     lazy = false,
--     priority = 1000,
--     config = function()
--       vim.cmd('colorscheme tokyonight-storm')
--     end
--   }
-- }

return M
```

## Keymaps

| key | command | note |
| --- | ------- | ---- |
|     |         |      |

## Systems

### Plugins management system

### Color & outlook system

#### Transparency

Experimental now. Not recommended.

### Session system

### File system

### LSP system

About debugger: My neovim configuration does not provide inner debugger like `nvim-dap`. Integrate an inner debugger is not a hard work, but I prefer using other more powerful outer debugger.

You can find language-specific outer debuggers below.

#### Python

1. Python environment dependencies

   ```bash
   # For nvim_lsp and coc both:
   pip install flake8 black
   # Optional:
   # 1. This library provides python static type check:
   # pip install flake8-annotations

   # For coc only:
   pip install jedi sourcery

   # If you don't know which to install, you can directly install all of them.
   pip install pynvim jedi flake8 black sourcery
   ```

2. Python debugger

   Again, my neovim configuration does not provide inner debugger like `nvim-dap`. Integrate an inner debugger is not a hard work, but I prefer using other outer debugger.

   For python, there are several pip libs can support debug. E.g, `pdb`, `ipdb`, `pudb`.

   Another choice is to use some logger like `pysnooper`, `loguru`.

   ```bash
   # pdb is python built-in library, so you don't need to install it via pip. Just import it.
   pip install ipdb pudb pysnooper loguru
   ```

#### C

`./clang-format` on project root or root's parent folder. See: https://github.com/clangd/coc-clangd/issues/39

#### Rust

```bash
# For coc, rust-analyzer is installed by rustup.
rustup component add rust-analyzer

# For nvim_lsp, rust-analyzer only auto starts for cargo projects.
# To create a cargo project, run the following shell command:
cargo new {project_name}
# If you need to start rust-analyzer for single rust file, you should run neovim command `:RustStartStandaloneServerForBuffer`
```

#### Markdown

```
# For coc dependencies:
marksman
```

`~/.markdownlint`

#### Latex

Need to install `zathura` pdf viewer, and use `<C-LeftMouse>` to inverse search.

The inverse search is unavailable beacuse the `vimtex` plugin is lazyloaded to gain best startup speed. If you want to inverse search, you should remove the lazy load statement.

For multiple tex files in a project, use `{main_file_name}.tex.latexmain` to define the main file. For example, if the main file in the project is `./main.tex`, you should add another file named as `./main.tex.latexmain` to tell vimtex the `./main.tex` is exactly the main file.

### Fuzzy search & global replace system

### Mark system

### Register & history system

### Motion system

### Buffer & window system

#### File content diff

##### Whole file diff

1. Vsplit two files left and right into different buffer or window.
2. Focus to the left file, type command `:diffthis<CR>`
3. Focus to the right file, do the same command.
4. To close diff mode, type command `:diffoff<CR>`

##### Part of file diff

1. `:Linediff`

### Terminal system

### Miscellaneous

#### With VSCode

#### With Chrome

#### Applications

##### Wakatime

Install `wakatime-cli`.

##### Lazygit

Install `lazygit`.

##### Lf

## My forked plugins list

## Tricks

```lua
-- Silent save.
vim.keymap.set('n', ':w<CR>', '<CMD>silent w<CR>', { silent = true })

-- No pain to read source code.
vim.keymap.set('n', 'gD', function ()
  vim.fn['CocAction']('jumpDefinition', 'vsplit')
  vim.cmd('normal zt')
end, { silent = true })

-- For changing hlslens `n` and `N` keys to keep the searched words in the middle line of screen.
n -> nzzzv
N -> Nzzzv
```
