==============
=== Global ===
==============
Terminal editor (e.g. Bash) follows `emacs` keybindings by default.


=====================
=== Bash Terminal ===
=====================
`!!`, `!-1`
    Run last command


=========================
=== Windows & Buffers ===
=========================
`:ls`
    List all buffers.
`:b 3`
    Jump to the 3rd buffer.
`:tab sball`
    Split all buffer file to tabs.
`:bn`, `:bp`
    Next & Previous buffer.
`:bd`
    Delete current buffer.
`:e`
    Open a new file.
`:tabe`
    Open a new file in a new tab.
`:cd %:h`
    Change vim workspace to current file's parent folder.
`:tabo`
    Only keep current tab and delete all others.
`:source %`
    Source current open file as nvim config.
`:set scrollbind`, `: set noscrollbind`
    Set two (or more) windows scrolled together. But note all windows need to be set this. So you should type this in all windows you need to scroll together. So you should type this in all the windows you want to scroll together.


======================
=== Visual Command ===
======================
`:normal`
    Use it in visual-line mode. Can run normal mode commands in visual-line mode .


============
=== Pipe ===
============
`:r !cat temp.txt`
    Read contents from temp.txt and paste them into current line.
`:w !sudo tee %`
    Write current file using sudo.


================
=== Terminal ===
================
`:term`
    Enter a terminal.
`<C-\><C-n>`
    Exit the terminal.

