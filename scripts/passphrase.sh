#!/bin/sh -e
printf "%s\n" "$1" | \
    tee -a /tmp/passphrase.txt | \
    sha256sum  | \
    dd bs=1 count=8 2>/dev/null \
    | xargs printf '$%sA\n'
