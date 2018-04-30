#!/bin/sh

# usr/bin
BASENAME=${BASENAME:-"/usr/bin/basename"}
DIRNAME=${DIRNAME:-"/usr/bin/dirname"}
PRINTF=${PRINTF:-"/usr/bin/printf"}
TR=${TR:-"/usr/bin/tr"}
SOFFICE=${SOFFICE:-"/usr/bin/soffice"}
PERL=${PERL:-"/usr/bin/perl"}

#bin
SED=${SED:-"/bin/sed"}
ECHO=${ECHO:-"/bin/echo"}
MKDIR=${MKDIR:-"/bin/mkdir"}

# app
APP_NAME=`${BASENAME} $0`

usage()
{
    ${PRINTF} "usage: %s file.docx\n" "$APP_NAME";
}

die()
{
   ${PRINTF} "%s\n" "$@";
   exit 1;
}

exit_failure()
{
    die "`usage`";
}

# suite names are mandatory
fullname=${1:-"Missing"};
if [ "x$fullname" = "xMissing" ] ; then
    exit_failure;
else
    # generate a text dump of the document via pdf2text
    shift $(( $# > 0 ? 1 : 0 ))

    dname=`${DIRNAME} "${fullname}"`
    fname=`${BASENAME} "${fullname}"`
    extname=`${ECHO} "${fname}" | ${SED} -e '/^\([^\.]\+\)\.\(.\{3,4\}\)$/{ s//.\2/; }'`
    stemname=`${ECHO} "${fname}" | ${SED} -e 's/'"${extname}"'$//'`
    pdfname="${stemname}.pdf"

    case "${extname}" in
.docx)
            ( cd ${dname}; ${SOFFICE} --headless --convert-to pdf "./${fname}" && pdftotext -layout "./${pdfname}" - ; );
            ;;
        *)
            die "dont know how to handle ""${extname}"" from ""${fname}";
            ;;
    esac
    exit 0;
fi
