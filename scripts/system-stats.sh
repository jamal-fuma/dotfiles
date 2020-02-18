#!/bin/sh

memory_pct(){
    free -m \
        | awk 'NR==2{printf "%.2f", $3*100/$2 }'
}

disk_pct(){
    df -h \
        | awk '$NF=="/"{printf "%s", $5}' \
        | sed -e 's/%//'
}

cpu_load(){
    top -bn1 \
        | awk '/load/{printf "%.2f", $(NF-2)}'
}

MESSAGE="memory_pct=$(memory_pct) disk_pct=$(disk_pct) cpu_load=$(cpu_load)"
echo $MESSAGE
