#!/bin/sh

establish_local_network_connection(){
    local iface_devn=${1:-'enx28f10e516956'}
    local iface_gw=${2:-'10.60.30.1'}
    local iface_peer=${3:-'10.60.30.192'}
    ifconfig ${iface_devn} down
    ifconfig ${iface_devn} ${iface_gw}/${iface_cidr} up
    route add -host ${iface_peer} dev ${iface_devn}
    ping ${iface_peer}
}

show_certificate_expiration_date(){
    local hostname=${1:-'senpaid.com'}
    local hostport=${2:-'443'}
    cat /dev/null \
        | openssl s_client \
    -showcerts \
        -servername ${hostname} \
        -connect ${hostname}:${hostport} \
        2>/dev/null \
        | openssl x509 \
        -inform pem \
        -noout \
        -enddate
}

main(){
    case $1 in
        up|down) establish_local_network_connection;;
        show) show_certificate_expiration_date;;
        *)
            printf "%s\n" "try up or show";
            exit `false`
            ;;
    esac
}

main "$@"
