envvim
============

This is a simple vim environment to develop C/C++ software.

Plugin list
------------

surround.vim
NERDTree
FuzzyFinder
YouCompleteMe

Dependencies
------------

vim (:-))
python
cmake


Installation
------------

Fallow this instructions:

    cd ~
    git clone https://github.com/snghojeong/envvim.git
    cd envvim
    git submodule update --init --recursive
    cd bundle/YouCompleteMe
    python install.py --clang-completer
    cd ~
    mv envvim .vim
    cat "source ~/.vim/vimrc_ext" >> .vimrc

And when you use cmake to build makefile,
give -DCMAKE_EXPORT_COMPILE_COMMANDS=ON option to make compile_commands.json.

Simple guide
------------

- Find file: \ff
- View directory tree: <F9>
- New tab: <F2>
- Next tab: <F3>
- Previous tab: <F4>
- Surround: See surround.vim guide.
- And so on... surf my vimrc_ext file!

License
-------

Copyright (c) snghojeong.  Distributed under the same terms as Vim itself.
See `:help license`.
