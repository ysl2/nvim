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
5. Other websites: [`chatGPT`](https://chat.openai.com), [`Google`](https://www.google.com), [`Github`](https://github.com), [`Reddit`](https://www.reddit.com), [`Stackoverflow`](https://stackoverflow.com), etc.

## Prerequisites, install, update, and write down your local configuration

### Prerequisites

- make (for MacOS and Linux) or  cmake (for Windows): Essential, for enhance telescope performance.
- ripgrep: Essential, for fuzzy find and replace.
- nerd-font: Optional, but recommended.
- lazygit: Optional, for git support.
- npm & yarn: Optional, for markdown preview and [`coc`](https://github.com/neoclide/coc.nvim) language server backend support.

### Install & update

```bash
# Install
git clone git@github.com:ysl2/nvim.git ~/.config/nvim

# Update: Choose an option below.
# Option 1. If you don't add some modification, you can simply pull from the origin url.
git pull origin master
# Option 2. If you have modified some code yourself, you should fetch then you might need to merge your configuration with origin url
git fetch origin && git merge origin/master --no-edit
```

## Keymaps

|key| command | note |
|---|---| --- |
||||

## Systems

### Color & outlook system

### Session system

### File system

### LSP system

### Fuzzy search & global replace system

### Mark system

### Register & history system

### Motion system

### Buffer & window system

### Terminal system

### Miscellaneous

#### With VSCode

#### With Chrome

#### Applications
