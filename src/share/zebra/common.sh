#!/bin/sh
#
# Copyright (c) 2015 Jesco Freund
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

detect_binary() {
    local BINDIRS="/bin /usr/bin /sbin /usr/sbin /usr/local/bin /usr/local/sbin"
    local rval=""
    for i in ${BINDIRS}; do
        if [ -x "${i}/${1}" ]; then
            rval="${i}/${1}"
            break
        fi
    done
    echo $rval
}

b_awk=$(detect_binary "awk")
b_cap_mkdb=$(detect_binary "cap_mkdb")
b_cat=$(detect_binary "cat")
b_chflags=$(detect_binary "chflags")
b_cp=$(detect_binary "cp")
b_grep=$(detect_binary "grep")
b_ln=$(detect_binary "ln")
b_ls=$(detect_binary "ls")
b_make=$(detect_binary "make")
b_mergemaster=$(detect_binary "mergemaster")
b_mkdir=$(detect_binary "mkdir")
b_more=$(detect_binary "more")
b_mount=$(detect_binary "mount")
b_mv=$(detect_binary "mv")
b_pw=$(detect_binary "pw")
b_realpath=$(detect_binary "realpath")
b_rm=$(detect_binary "rm")
b_sed=$(detect_binary "sed")
b_svn=$(detect_binary "svn")
[ -z "${b_svn}" ] && b_svn=$(detect_binary "svnlite")
b_sysctl=$(detect_binary "sysctl")
b_wc=$(detect_binary "wc")
b_zfs=$(detect_binary "zfs")

svn_flags="--quiet --non-interactive --trust-server-cert"

log() {
    if [ -n "${COLOR_ARROW}" ] || [ -z "${1##*\033[*}" ]; then
        printf "${COLOR_ARROW}>>>${COLOR_RESET} ${1}${COLOR_RESET_REAL}\n"
    else
        printf ">>> ${1}\n"
    fi
}

log_error() {
    COLOR_ARROW="${COLOR_ERROR}${COLOR_BOLD}" \
        log "${COLOR_ERROR}${COLOR_BOLD}Error:${COLOR_RESET} $1" >&2
    return 0
}

log_warn() {
    COLOR_ARROW="${COLOR_WARN}${COLOR_BOLD}" \
        log "${COLOR_WARN}${COLOR_BOLD}Warning:${COLOR_RESET} $@" >&2
    return 0
}

log_debug() {
    COLOR_ARROW="${COLOR_DEBUG}${COLOR_BOLD}" \
        log "${COLOR_DEBUG}${COLOR_BOLD}Debug:${COLOR_RESET}${COLOR_IGNORE} $@" >&2
    return 0
}

log_info() {
    COLOR_ARROW="${COLOR_INFO}${COLOR_BOLD}" \
        log "${COLOR_INFO}${COLOR_BOLD}Info:${COLOR_RESET}${COLOR_IGNORE} $@" >&2
    return 0
}

prog_msg() {
    COLOR_ARROW="${COLOR_INFO}${COLOR_BOLD}"
    printf "${COLOR_ARROW}>>>${COLOR_RESET} ${COLOR_INFO}${1}"
    printf "${COLOR_BOLD} ... ${COLOR_RESET_REAL}"
}

prog_success() {
    printf "${COLOR_SUCCESS}${COLOR_BOLD}success${COLOR_RESET_REAL}\n"
}

prog_fail() {
    printf "${COLOR_FAIL}${COLOR_BOLD}fail${COLOR_RESET_REAL}\n"
}

die() {
    if [ $# -ne 2 ]; then
        die 1 "die() expects 2 arguments: exit_number \"message\""
    fi
    log_error "${2}" || :
    exit $1
}

version_sys() {
    local version=$(${b_sysctl} -qn kern.osrelease | ${b_sed} 's/-.*//g' | \
        ${b_grep} -E '^[[:digit:]]{1,2}\.[[:digit:]]{1,2}$')
    [ -z "${version}" ] && return 1
    echo "${version}" && return 0
}

zfs_create() {
    if [ $# -ne 4 ]; then
        die 1 "zfs_create() expects 4 arguments: \"dataset\", \"flags\", \"simulate\" and \"quiet\""
    fi
    [ "${4}" != "yes" ] && prog_msg "Creating zfs dataset ${1}"
    if [ "${3}" = "yes" ]; then
        rval=0
    else
        {
            ${b_zfs} create ${2} ${1}
        }> /dev/null 2>&1
        rval=$?
    fi
    [ "${rval}" -ne "0" ] && [ "${4}" != "yes" ] && prog_fail
    [ "${rval}" -eq "0" ] && [ "${4}" != "yes" ] && prog_success
    return ${rval}
}

zfs_destroy() {
    if [ $# -ne 4 ]; then
        die 1 "zfs_destroy() expects 4 arguments: \"dataset\", \"flags\", \"simulate\" and \"quiet\""
    fi
    local flags="${2}"
    [ "${3}" = "yes" ] && flags="${flags} -n"
    [ "${4}" != "yes" ] && prog_msg "Deleting zfs dataset ${1}"
    {
        ${b_zfs} destroy ${flags} ${1};
    }> /dev/null 2>&1
    rval=$?
    [ "${rval}" -ne "0" ] && [ "${4}" != "yes" ] && prog_fail
    [ "${rval}" -eq "0" ] && [ "${4}" != "yes" ] && prog_success
    return ${rval}
}

zfs_exists() {
    # Check if a ZFS dataset already exists. If true, return 0.
    # Otherwise, return an exit status of 1.
    if [ $# -ne 1 ]; then
        die 1 "zfs_exists() expects 1 argument: \"dataset\""
    fi
    {
        local rval=$(${b_zfs} list -H -t all -o name ${1} | ${b_wc} -l)
    }> /dev/null 2>&1
    [ ${rval} -eq "1" ] && return 0
    return 1
}

detect_fs() {
    # detect the file system of a specific mount point.
    if [ $# -ne 1 ]; then
        die 1 "detect_fs() expects 1 argument: \"moint point\""
    fi
    local fs=$(${b_mount} | ${b_grep} "on ${1}" | ${b_awk} '{print $4}' | ${b_sed} 's/[^[:alnum:]]//g')
    [ -z "${fs}" ] && return 1
    echo "${fs}" && return 0
}

tmp_is_noexec() {
    # detect if /tmp is mounted with the noexec option
    local tmp=$(${b_mount} | ${b_grep} "on ${ZB_SYS_TMP}" | ${b_grep} 'noexec')
    [ -z "${tmp}" ] && return 1
    return 0
}

tmp_device() {
    # returns the device /tmp is mounted from
    local device=$(${b_mount} | ${b_grep} "on ${ZB_SYS_TMP}" | ${b_awk} '{print $1}')
    [ -z "${device}" ] && return 1
    echo "${device}" && return 0
}

get_tmp_flags() {
    # get the flags needed to mount /tmp (apart from exec/noexec)
    local noatime=$(${b_mount} | ${b_grep} "on ${ZB_SYS_TMP}" | ${b_grep} 'noatime')
    local nosuid=$(${b_mount} | ${b_grep} "on ${ZB_SYS_TMP}" | ${b_grep} 'nosuid')
    local acls=$(${b_mount} | ${b_grep} "on ${ZB_SYS_TMP}" | ${b_grep} 'acls')
    rval=""
    [ -n "${noatime}" ] && rval="-o noatime"
    if [ -n "${nosuid}" ]; then
        [ -z "${rval}" ] && rval="-o nosuid"
        [ -n "${rval}" ] && rval="${rval} -o nosuid"
    fi
    if [ -n "${acls}" ]; then
        [ -z "${rval}" ] && rval="-o acls"
        [ -n "${rval}" ] && rval="${rval} -o acls"
    fi
    echo "${rval}"
}

tmp_noexec_off() {
    # switch noexec option off for /tmp
    tmp_is_noexec
    [ "$?" -ne "0" ] && return 0
    local device=$(tmp_device)
    [ "$?" -ne "0" ] && return 1
    rval=0
    case "$(detect_fs ${ZB_SYS_TMP})" in
        zfs)
            ${b_zfs} set exec=on $device
            rval=$?
            ;;
        *)
            ${b_mount} -u -o "exec" $(get_tmp_flags) ${device}
            rval=$?
            ;;
    esac
    return ${rval}
}

tmp_noexec_on() {
    # switch noexec option on for /tmp
    [ "${TMP_NOEXEC}" = "off" ] && return 0
    tmp_is_noexec
    [ "$?" -eq "0" ] && return 0
    local device=$(tmp_device)
    [ "$?" -ne "0" ] && return 1
    rval=0
    case "$(detect_fs ${ZB_SYS_TMP})" in
        zfs)
            ${b_zfs} set exec=off $device
            rval=$?
            ;;
        *)
            ${b_mount} -u -o noexec $(get_tmp_flags) ${device}
            rval=$?
            ;;
    esac
    return ${rval}
}

# cd into / to avoid foot-shooting if running from deleted dirs or
# NFS dir which root has no access to.
SAVED_PWD="${PWD}"
cd /

# Pre-set information from calling binary
: ${ZEBRA_STATUS:=0}
: ${USE_COLORS:=yes}

# include non-configurable defaults
. ${SCRIPTPREFIX}/include/defaults.sh

# include output coloring helpers
. ${SCRIPTPREFIX}/include/color.sh

# look for the zebra configuration file
[ -z "${ZEBRA_ETC}" ] &&
    ZEBRA_ETC=$(${b_realpath} ${SCRIPTPREFIX}/../../${ZB_ETC})
# If this is a relative path, add in ${PWD} as a cd / is done.
[ "${ZEBRA_ETC#/}" = "${ZEBRA_ETC}" ] && \
    ZEBRA_ETC="${SAVED_PWD}/${ZEBRA_ETC}"
ZEBRAD="${ZEBRA_ETC}/${ZB_ZEBRAD}"
if [ -r "${ZEBRA_ETC}/${ZB_CONF}" ]; then
    . "${ZEBRA_ETC}/${ZB_CONF}"
elif [ -r "${ZEBRAD}/${ZB_CONF}" ]; then
    . "${ZEBRAD}/${ZB_CONF}"
else
    die 1 "Unable to find a readable ${ZB_CONF} in ${ZEBRA_ETC} or ${ZEBRAD}"
fi

# check if /tmp is noexec by default or not
tmp_is_noexec
if [ "$?" -eq "0" ]; then
    TMP_NOEXEC="on"
else
    TMP_NOEXEC="off"
fi

. ${SCRIPTPREFIX}/include/config.sh
