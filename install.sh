#!/bin/sh

# workout the absolute path to the checkout directory
abspath()
{
    case "${1}" in
        [./]*)
            local ABSPATH="$(cd ${1%/*}; pwd)/${1##*/}"
            echo "${ABSPATH}"
            ;;
        *)
            echo "${PWD}/${1}"
            ;;
    esac
}

SCRIPT=$(abspath ${0})
ROOTPATH=`dirname ${SCRIPT}`
export PROJECT_ROOT=${ROOTPATH}

symlink_files()
{
	while read from to;
	do
        [ -f $to ] || \
            ln -sv ${from} ${to}
	done <<EOS
${PROJECT_ROOT}/bash/aliases	    ${HOME}/.bash_aliases
${PROJECT_ROOT}/bash/bashrc	        ${HOME}/.bashrc
${PROJECT_ROOT}/bash/profile	    ${HOME}/.profile
${PROJECT_ROOT}/vim/vimrc	        ${HOME}/.vimrc
${PROJECT_ROOT}/git/gitconfig	    ${HOME}/.gitconfig
${PROJECT_ROOT}/mutt/muttrc	        ${HOME}/.muttrc
${PROJECT_ROOT}/screen/screenrc	    ${HOME}/.screenrc
EOS
}

make_mutt_cache_dirs()
{
    mkdir -p ~/.mutt-cache/{bodies,headers,certificates}
}

case $1 in
*)
    cd ${PROJECT_ROOT} && git submodule update --init
	symlink_files
    make_mutt_cache_dirs
;;
esac
