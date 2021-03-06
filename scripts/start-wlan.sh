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
SCRIPTPATH=`dirname ${SCRIPT}`
export PROJECT_ROOT=${SCRIPTPATH}

APP_NAME="${PROJECT_ROOT}/$(basename $0)"
WPA_SUPPLICANT_CNF=$(pwd)/wpa_supplicant.conf
IFACE=wlan0
# resolve dns with google
NS1="8.8.8.8"
NS2="8.8.4.4"
UID=0
GID=0
ERR="ERROR"


# handle case of resolv.conf being a symlink transparently
RESOLV_CNF=$(
resolv_conf(){
    local f=/etc/resolv.conf;
    [ -s $f  ] && readlink $f || $( [ -f $f ] && echo $f );
}; resolv_conf)

chmod_path(){
    local to_mode="${1}";
    local path="${2}";
    chmod "${to_mode}" "${path}" \
        || printf "%s: '%s'\n" "$ERR" "failed to change mode of  ${path} to ${to_mode}";
}
chown_path(){
    local to_owner="${1}";
    local path="${2}";
    chown "${to_owner}" "${path}" \
        || printf "%s: '%s'\n" "$ERR" "failed to change owner ${path} to ${to_owner}";
}
systemctl_stop(){
    local service="${1}";
    systemctl stop ${service} \
        || printf "%s: '%s'\n" "$ERR" "failed to stop ${service}";
}
systemctl_start(){
    local service="${1}";
    systemctl start ${service} \
        || printf "%s: '%s'\n" "$ERR" "failed to start ${service}";
}

# generate the minimal configuration needed from wpa_passphrase
generate_wpa_supplicant_configuration(){
    local essid=${1:-'missing\ essid\ in\ generate_wpa_supplicant_configuration'}
    wpa_passphrase ${essid} > ${WPA_SUPPLICANT_CNF}
    chmod_path 600 ${WPA_SUPPLICANT_CNF}
    chown_path "${UID}:${GID}" "${WPA_SUPPLICANT_CNF}"
}

# generate the minimal configuration needed for dns resolution
generate_dns_resolver_configuration(){
    cat >"${RESOLV_CNF}"<<EOF
# Modified by ${APP_NAME} do not edit
nameserver ${NS1}
nameserver ${NS2}
EOF

    # resolver should not be world executable or writable
    chmod_path 644 ${RESOLV_CNF}
    chown_path "${UID}:${GID}" "${RESOLV_CNF}"
}

do_bring_wifi_up(){
    systemctl_stop "NetworkManager"
    generate_dns_resolver_configuration

    # generate the minimal configuration needed from wpa_passphrase
    local essid=${1:-''}
    if [ "x$essid" = "x" ]; then
        ( exec 2>&1 ${APP_NAME} help );
        exit `false`;
    fi

    generate_wpa_supplicant_configuration "${essid}";

    # connect to wifi in background
    wpa_supplicant \
        -B \
        -i${IFACE}\
        -Dnl80211,wext \
        -c "${WPA_SUPPLICANT_CNF}"

    # dhcp an address
    dhclient ${IFACE}
}

do_bring_wifi_down(){
    rm -f ${WPA_SUPPLICANT_CNF}
    # disconnect radio
    killall wpa_supplicant;
    # release our dhcp lease
    killall dhclient;

    # resolver should not be world executable or writable
    # however thats how it was before modification
    chmod_path 777 ${RESOLV_CNF}
    chown_path "${UID}:${GID}" "${RESOLV_CNF}"
    systemctl_start NetworkManager
}

main(){
    case $1 in
        up)
            local essid="${2}"
            do_bring_wifi_up "${essid}"
            ;;
        down)
            do_bring_wifi_down
            ;;
        help*)
            printf "%s: up <essid>\n" "${APP_NAME}"
            printf "\t%s\n" "start wpa_supplicant connection to Wifi Ap";
            ;;
        *)
            printf "%s: '%s'\n" "${APP_NAME}" " takes either 'up' or 'down' or 'help' as argument";
            exit `false`;
            ;;
    esac
    exit $?
}

main "$@"
