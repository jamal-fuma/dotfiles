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
		ln -sv ${from} ${to}
	done <<EOS
${PROJECT_ROOT}/bash/aliases	    ${HOME}/.bash_aliases
${PROJECT_ROOT}/vim/vimrc	        ${HOME}/.vimrc
${PROJECT_ROOT}/git/gitconfig	    ${HOME}/.gitconfig
${PROJECT_ROOT}/mutt/muttrc	        ${HOME}/.muttrc
EOS
}

make_mutt_cache_dirs()
{
    mkdir -p ~/.mutt-cache/{bodies,headers,certificates}
}

install_vim_plugins()
{
    vim -E -s -c "source ~/.vimrc" -c PluginInstall -c qa
}

case $1 in
*)
    cd ${PROJECT_ROOT} && git submodule update --init
	symlink_files
    install_vim_plugins
    make_mutt_cache_dirs
;;
esac
