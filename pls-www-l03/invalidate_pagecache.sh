#!/bin/sh

function display_dots() {

        [[ ${DEBUG} -eq 1 ]] && set +x

        [[ "${2}" != "" ]] && _DISPLAY_DOTS=${2} || _DISPLAY_DOTS=${DISPLAY_DOTS}
        [[ "${3}" != "" ]] && _DISPLAY_CHAR=${3} || _DISPLAY_CHAR="."

        PARAM_LENGTH=${#1}
        PARAM_REMAIN=$(($_DISPLAY_DOTS-$PARAM_LENGTH))

        printf "%s" "${1}"

        while [ ${PARAM_REMAIN} -ne 0 ]; do
                printf "%s" "${_DISPLAY_CHAR}"
                let PARAM_REMAIN=PARAM_REMAIN-1
        done


        [[ ${DEBUG} -eq 1 ]] && set -x
}


function print_usage {
        echo "$1 -o [soft] [-q] [-h] [-d]"
        exit 1
}

QUIET=0
PATH=${PATH}:/usr/bin:/usr/sbin
PAGECACHE="/opt/intershop/eserver1/local/webadapter/pagecache"
USR="intershop1"
GRP="intershop1"

# GETOPT
while getopts hqdo: opt
do
        case $opt in
                h) print_usage ${0}
                        exit 0;;
                d) export DEBUG=1 ;;
                o) export OPTION=${OPTARG} ;;
                q) export QUIET=1 ;;
                ?) print_usage ${0}
                        exit 1 ;;
        esac
done

ESERVER="sudo /sbin/service eserver1-httpd"
RUN=0


if [ ! -d ${PAGECACHE} ]; then
        display_dots "Unable to find pagecache directory ${PAGECACHE}." 100
        echo "[ERROR]"
        exit 1
fi


if [ "${OPTION}" == "soft" ]; then

               
        rm -R ${PAGECACHE}/*
        if [ $? -ne 0 ]; then
                display_dots "Failed to remove content of ${PAGECACHE}." 100
                echo "[ERROR]"

        else


                ${ESERVER} status
                echo "[OK]"


        fi


        RUN=1
fi

if [ ${RUN} -eq 0 ]; then
        print_usage ${0}
fi
