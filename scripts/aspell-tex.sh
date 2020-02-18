#!/bin/sh

ASPELL=${ASPELL:-'/usr/bin/aspell'}

exec ${ASPELL} \
	   -t \
	   --add-tex-command="lstinputlisting oOOOp" \
	   -c "$@"
echo "Exec of '$ASPELL' Failed"
exit `false`
