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
EOS
}

case $1 in
*)
	symlink_files
;;
esac
