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

# include binary detection
. ${SCRIPTPREFIX}/include/early/binary.sh

# module-specific variables
zbb_zfs=$(zb_detect_binary "zfs")
zbb_zpool=$(zb_detect_binary "zpool")

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
