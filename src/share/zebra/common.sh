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

zb_detect_binary() {
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

b_awk=$(zb_detect_binary "awk")
b_cap_mkdb=$(zb_detect_binary "cap_mkdb")
b_cat=$(zb_detect_binary "cat")
b_chflags=$(zb_detect_binary "chflags")
b_cp=$(zb_detect_binary "cp")
b_grep=$(zb_detect_binary "grep")
b_ln=$(zb_detect_binary "ln")
b_ls=$(zb_detect_binary "ls")
b_make=$(zb_detect_binary "make")
b_mergemaster=$(zb_detect_binary "mergemaster")
b_mkdir=$(zb_detect_binary "mkdir")
b_more=$(zb_detect_binary "more")
b_mount=$(zb_detect_binary "mount")
b_mv=$(zb_detect_binary "mv")
b_pw=$(zb_detect_binary "pw")
b_realpath=$(zb_detect_binary "realpath")
b_rm=$(zb_detect_binary "rm")
b_sed=$(zb_detect_binary "sed")
b_svn=$(zb_detect_binary "svn")
[ -z "${b_svn}" ] && b_svn=$(zb_detect_binary "svnlite")
b_sysctl=$(zb_detect_binary "sysctl")
b_wc=$(zb_detect_binary "wc")
b_zfs=$(zb_detect_binary "zfs")
b_zpool=$(zb_detect_binary "zpool")

zb_svn_flags="--quiet --non-interactive --trust-server-cert"

zb_echo() {
    # internal echo wrapper respecting the SILENT flag
    [ "${ZB_SILENT}" = "yes" ] && return 0
    echo $@
}

zb_printf() {
    # internal printf wrapper respecting the SILENT flag
    [ "${ZB_SILENT}" = "yes" ] && return 0
    printf $@
}

zb_log() {
    [ "${ZB_SILENT}" = "yes" ] && return 0
    if [ -n "${COLOR_ARROW}" ] || [ -z "${1##*\033[*}" ]; then
        printf "${COLOR_ARROW}>>>${COLOR_RESET} ${1}${COLOR_RESET_REAL}\n"
    else
        printf ">>> ${1}\n"
    fi
}

zb_log_error() {
    COLOR_ARROW="${COLOR_ERROR}${COLOR_BOLD}" \
        zb_log "${COLOR_ERROR}${COLOR_BOLD}Error:${COLOR_RESET} $1" >&2
    return 0
}

zb_log_warn() {
    COLOR_ARROW="${COLOR_WARN}${COLOR_BOLD}" \
        zb_log "${COLOR_WARN}${COLOR_BOLD}Warning:${COLOR_RESET} $@" >&2
    return 0
}

zb_log_debug() {
    [ ${ZB_DEBUG} = "yes" ] && COLOR_ARROW="${COLOR_DEBUG}${COLOR_BOLD}" \
        zb_log "${COLOR_DEBUG}${COLOR_BOLD}Debug:${COLOR_RESET}${COLOR_IGNORE} $@" >&2
    return 0
}

zb_log_info() {
    COLOR_ARROW="${COLOR_INFO}${COLOR_BOLD}" \
        zb_log "${COLOR_INFO}${COLOR_BOLD}Info:${COLOR_RESET}${COLOR_IGNORE} $@" >&2
    return 0
}

zb_prog_msg() {
    [ "${ZB_SILENT}" = "yes" ] && return 0
    COLOR_ARROW="${COLOR_INFO}${COLOR_BOLD}"
    printf "${COLOR_ARROW}>>>${COLOR_RESET} ${COLOR_INFO}${1}"
    printf "${COLOR_BOLD} ... ${COLOR_RESET_REAL}"
}

zb_prog_success() {
    [ "${ZB_SILENT}" = "yes" ] && return 0
    printf "${COLOR_SUCCESS}${COLOR_BOLD}success${COLOR_RESET_REAL}\n"
}

zb_prog_fail() {
    [ "${ZB_SILENT}" = "yes" ] && return 0
    printf "${COLOR_FAIL}${COLOR_BOLD}fail${COLOR_RESET_REAL}\n"
}

zb_die() {
    if [ $# -ne 2 ]; then
        zb_die 1 "zb_die() expects 2 arguments: exit_number \"message\""
    fi
    zb_log_error "${2}" || :
    exit $1
}

zb_version_sys() {
    local version=$(${b_sysctl} -qn kern.osrelease | ${b_sed} 's/-.*//g' | \
        ${b_grep} -E '^[[:digit:]]{1,2}\.[[:digit:]]{1,2}$')
    [ -z "${version}" ] && return 1
    echo "${version}" && return 0
}

zb_zfs_create() {
    if [ $# -ne 4 ]; then
        die 1 "zb_zfs_create() expects 4 arguments: \"dataset\", \"flags\", \"simulate\" and \"quiet\""
    fi
    [ "${4}" != "yes" ] && zb_prog_msg "Creating zfs dataset ${1}"
    if [ "${3}" = "yes" ]; then
        local rval=0
    else
        {
            ${b_zfs} create ${2} ${1}
        }> /dev/null 2>&1
        local rval=$?
    fi
    [ "${rval}" -ne "0" ] && [ "${4}" != "yes" ] && zb_prog_fail
    [ "${rval}" -eq "0" ] && [ "${4}" != "yes" ] && zb_prog_success
    return ${rval}
}

zb_zfs_destroy() {
    if [ $# -ne 4 ]; then
        die 1 "zb_zfs_destroy() expects 4 arguments: \"dataset\", \"flags\", \"simulate\" and \"quiet\""
    fi
    local flags="${2}"
    [ "${3}" = "yes" ] && flags="${flags} -n"
    [ "${4}" != "yes" ] && zb_prog_msg "Deleting zfs dataset ${1}"
    {
        ${b_zfs} destroy ${flags} ${1};
    }> /dev/null 2>&1
    local rval=$?
    [ "${rval}" -ne "0" ] && [ "${4}" != "yes" ] && zb_prog_fail
    [ "${rval}" -eq "0" ] && [ "${4}" != "yes" ] && zb_prog_success
    return ${rval}
}

zb_zfs_exists() {
    # Check if a ZFS dataset already exists. If true, return 0.
    # Otherwise, return an exit status of 1.
    if [ $# -ne 1 ]; then
        die 1 "zb_zfs_exists() expects 1 argument: \"dataset\""
    fi
    {
        local rval=$(${b_zfs} list -H -t all -o name ${1} | ${b_wc} -l)
    }> /dev/null 2>&1
    [ ${rval} -eq "1" ] && return 0
    return 1
}

zb_zpool_exists() {
    # Check if a Zpool exists. If true, return 0.
    # Otherwise, return an exit status of 1.
    if [ $# -ne 1 ]; then
        die 1 "zb_zpool_exists() expects 1 argument: \"zpool\""
    fi
    {
        local rval=$(${b_zpool} list -H -o name ${1} | ${b_wc} -l)
    }> /dev/null 2>&1
    [ ${rval} -eq "1" ] && return 0
    return 1
}

zb_zfs_list_datasets() {
    # List all datasets within a given ZFS pool.
    if [ $# -ne 1 ]; then
        die 1 "zb_zfs_list_datasets() expects 1 argument: \"pool\""
    fi
    {
        local sets=$(${b_zfs} list -r -H -o name -t filesystem ${1});
        local rval=$?;
    }> /dev/null 2>&1
    [ -z "${sets}" ] && return ${rval}
    echo "${sets}" && return ${rval}
}

zb_detect_fs() {
    # detect the file system of a specific mount point.
    if [ $# -ne 1 ]; then
        die 1 "zb_detect_fs() expects 1 argument: \"moint point\""
    fi
    local fs=$(${b_mount} | ${b_grep} "on ${1}" | ${b_awk} '{print $4}' | ${b_sed} 's/[^[:alnum:]]//g')
    [ -z "${fs}" ] && return 1
    echo "${fs}" && return 0
}

none() {
    # A function that simply does nothing
    return 0
}

zb_tmp_is_noexec() {
    # detect if /tmp is mounted with the noexec option
    local tmp=$(${b_mount} | ${b_grep} "on ${ZB_SYS_TMP}" | ${b_grep} 'noexec')
    [ -z "${tmp}" ] && return 1
    return 0
}

zb_tmp_device() {
    # returns the device /tmp is mounted from
    local device=$(${b_mount} | ${b_grep} "on ${ZB_SYS_TMP}" | ${b_awk} '{print $1}')
    [ -z "${device}" ] && return 1
    echo "${device}" && return 0
}

zb_get_tmp_flags() {
    # get the flags needed to mount /tmp (apart from exec/noexec)
    local noatime=$(${b_mount} | ${b_grep} "on ${ZB_SYS_TMP}" | ${b_grep} 'noatime')
    local nosuid=$(${b_mount} | ${b_grep} "on ${ZB_SYS_TMP}" | ${b_grep} 'nosuid')
    local acls=$(${b_mount} | ${b_grep} "on ${ZB_SYS_TMP}" | ${b_grep} 'acls')
    local rval=""
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

zb_tmp_noexec_off() {
    # switch noexec option off for /tmp
    zb_tmp_is_noexec
    [ "$?" -ne "0" ] && return 0
    local device=$(tmp_device)
    [ "$?" -ne "0" ] && return 1
    local rval=0
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

zb_tmp_noexec_on() {
    # switch noexec option on for /tmp
    [ "${TMP_NOEXEC}" = "off" ] && return 0
    zb_tmp_is_noexec
    [ "$?" -eq "0" ] && return 0
    local device=$(tmp_device)
    [ "$?" -ne "0" ] && return 1
    local rval=0
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
ZB_SAVED_PWD="${PWD}"
cd /

# Pre-set information from calling binary
: ${ZEBRA_STATUS:=0}
: ${ZB_USE_COLORS:=yes}
: ${ZB_DEBUG:=no}
: ${ZB_SILENT:=no}

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
    zb_die 1 "Unable to find a readable ${ZB_CONF} in ${ZEBRA_ETC} or ${ZEBRAD}"
fi

# check if /tmp is noexec by default or not
zb_tmp_is_noexec
if [ "$?" -eq "0" ]; then
    TMP_NOEXEC="on"
else
    TMP_NOEXEC="off"
fi

. ${SCRIPTPREFIX}/include/config.sh
