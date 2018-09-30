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
${PROJECT_ROOT}/scripts/pdftostdout	${HOME}/bin/pdftostdout
${PROJECT_ROOT}/bash/aliases	    ${HOME}/.bash_aliases
${PROJECT_ROOT}/bash/bashrc	        ${HOME}/.bashrc
${PROJECT_ROOT}/bash/profile	    ${HOME}/.profile
${PROJECT_ROOT}/vim/vimrc	        ${HOME}/.vimrc
${PROJECT_ROOT}/git/gitconfig	    ${HOME}/.gitconfig
${PROJECT_ROOT}/mutt/muttrc	        ${HOME}/.muttrc
${PROJECT_ROOT}/screen/screenrc	    ${HOME}/.screenrc
${PROJECT_ROOT}/readline/inputrc	${HOME}/.inputrc
${PROJECT_ROOT}/git/attributes	    ${HOME}/.config/git/attributes
EOS
}

make_dirs()
{
	while read dname;
	do
        ( cd ${dname} || mkdir -p ${dname} );
	done <<EOS
${HOME}/bin
${HOME}/.config/git
${HOME}/.mutt-cache/bodies
${HOME}/.mutt-cache/headers
${HOME}/.mutt-cache/certificates
EOS
}

case $1 in
*)
    cd ${PROJECT_ROOT} && git submodule update --init
    make_dirs
	symlink_files
;;
esac
