#!/bin/sh

cat <<EOS
[filter "openssl"]
    smudge = ${HOME}/dotfiles/gitencrypt/smudge_filter_openssl
    clean  = ${HOME}/dotfiles/gitencrypt/clean_filter_openssl
[diff "openssl"]
    textconv = ${HOME}/dotfiles/gitencrypt/diff_filter_openssl
EOS
