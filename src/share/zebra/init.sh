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

# set up the zebra environment
SCRIPTPATH=$(/bin/realpath $0)
SCRIPTPREFIX=${SCRIPTPATH%/*}
. ${SCRIPTPREFIX}/common.sh

zb_init_usage() {
    umsg="${COLOR_BOLD}usage: ${COLOR_RED}${COLOR_BOLD}zebra init"
    umsg="${umsg} ${COLOR_WHITE}[${COLOR_RED}${COLOR_BOLD}-f${COLOR_WHITE}] ["
    umsg="${umsg}${COLOR_RED}${COLOR_BOLD}-p ${COLOR_GREEN}${COLOR_BOLD}zpool"
    umsg="${umsg}${COLOR_WHITE}] [${COLOR_RED}${COLOR_BOLD}-s${COLOR_WHITE}] ["
    umsg="${umsg}${COLOR_RED}${COLOR_BOLD}-t ${COLOR_GREEN}${COLOR_BOLD}jobtab"
    umsg="${umsg}${COLOR_WHITE}]"

    [ "${ZB_SILENT}" = "yes" ] || echo -e "${umsg}
${COLOR_RED}${COLOR_BOLD}Options:
${COLOR_RED}${COLOR_BOLD}    -f${COLOR_RESET}          -- Force initialisation; i. e. delete any pre-
                   existing job tab at the specified location
${COLOR_RED}${COLOR_BOLD}    -p ${COLOR_GREEN}${COLOR_BOLD}zpool${COLOR_RESET}    -- Scan alternate zpool instead of default
                   zpool ${COLOR_EM}${ZPOOL}${COLOR_RESET}
${COLOR_RED}${COLOR_BOLD}    -s${COLOR_RESET}          -- Simulation mode. Do not apply any change,
                   just print out the job tab
${COLOR_RED}${COLOR_BOLD}    -t ${COLOR_GREEN}${COLOR_BOLD}jobtab${COLOR_RESET}   -- Write result to alternate job tab instead
                   of default file ${COLOR_EM}${ZEBRAD}/${JOBTAB}${COLOR_RESET}
"
}

# setup internal flags
ZB_INIT_FORCE="no"
ZB_INIT_SIMULATE="no"
ZB_INIT_JOBTAB="${ZEBRAD}/${JOBTAB}"
ZB_INIT_ZPOOL="${ZPOOL}"

# evaluate command line options
while getopts "fshp:t:" FLAG; do
    case "${FLAG}" in
        f)
            ZB_INIT_FORCE="yes"
            ;;
        p)
            zb_zpool_exists "${OPTARG}"
            [ "$?" -ne "0" ] && \
                zb_die 1 "argument ${OPTARG} is not a valid zpool"
            ZB_INIT_ZPOOL=${OPTARG}
            ;;
        s)
            ZB_INIT_SIMULATE="yes"
            ;;
        t)
            ZB_INIT_JOBTAB=${OPTARG}
            [ "${ZB_INIT_JOBTAB#/}" = "${ZB_INIT_JOBTAB}" ] && \
                ZB_INIT_JOBTAB="${SAVED_PWD}/${ZB_INIT_JOBTAB}"
            ;;
        *)
            zb_init_usage
            exit 1
            ;;
    esac
done

# Debug output of selected options
zb_log_debug "Selected job tab:         ${ZB_INIT_JOBTAB}"
zb_log_debug "Selected zpool:           ${ZB_INIT_ZPOOL}"
zb_log_debug "Force job tab overwrite:  ${ZB_INIT_FORCE}"
zb_log_debug "Output job tab to stdout: ${ZB_INIT_SIMULATE}"

# Simulation and the SILENT flag don't work together. Since no output may be
# generated, we can stop here as well...
[ "${ZB_SILENT}" = "yes" ] && [ "${ZB_INIT_SIMULATE}" = "yes" ] && \
    exit ${ZEBRA_STATUS}

# force and simulate don't work together. If both were specified,
# ignore the more dangerous `force` option and go on with simulation.
[ "${ZB_INIT_FORCE}" = "yes" ] && [ "${ZB_INIT_SIMULATE}" = "yes" ] && \
    zb_log_debug "-f and -s are mutually exclusive, ignoring -f" && \
    ZB_INIT_FORCE="no"

# with force selected and job tab existing, remove it
if [ -e "${ZB_INIT_JOBTAB}" ]; then
    if [ "${ZB_INIT_FORCE}" = "yes" ]; then
        zb_prog_msg "Deleting ${ZB_INIT_JOBTAB}"
        zb_rm_file "${ZB_INIT_JOBTAB}"
        [ "${?}" -ne "0" ] && zb_prog_fail && \
            zb_die 1 "Failed to delete ${ZB_INIT_JOBTAB}"
        zb_prog_success
    else
        [ "${ZB_INIT_SIMULATE}" != "yes" ] && \
            zb_log_warn "${ZB_INIT_JOBTAB} already exists." && \
            zb_die 1 "job tab file exists. Use -f to replace it."
    fi
fi

zb_prog_msg "Scanning zpool ${COLOR_EM}${ZPOOL}${COLOR_RESET} for datasets"
ZB_INIT_DATASETS=$(zb_zfs_list_datasets ${ZPOOL})
[ "${?}" -ne "0" ] && zb_prog_fail && zb_die 1 "Dataset detection failed"
zb_prog_success
[ -z "${ZB_INIT_DATASETS}" ] && \
    zb_log_warn "No datasets detected in ${COLOR_EM}${ZPOOL}${COLOR_RESET}" && \
    zb_die 1 "No job tab created (empty set)"

# When not simulating, redirect output to job tab file
if [ "${ZB_INIT_SIMULATE}" != "yes" ]; then
    zb_prog_msg "Writing new job tab file"
    exec 4>&1
    exec 1>${ZB_INIT_JOBTAB}
fi

printf "${ZB_JOBTAB_HEADER}"
for i in ${ZB_INIT_DATASETS}; do
    printf "${ZB_DEFAULT_MINUTE}\t${ZB_DEFAULT_HOUR}"
    printf "\t${ZB_DEFAULT_MDAY}\t${ZB_DEFAULT_MONTH}"
    printf "\t${ZB_DEFAULT_WDAY}\t${ZB_DEFAULT_MODE}"
    printf "\t${ZB_DEFAULT_GENS}\t${ZB_DEFAULT_COMP}"
    printf "\t${ZB_DEFAULT_ENC}\t${ZB_DEFAULT_PRE}"
    printf "\t${ZB_DEFAULT_POST}\t${ZB_DEFAULT_REC}\t${i}\n"
done

if [ "${ZB_INIT_SIMULATE}" != "yes" ]; then
    exec 1>&4
    exec 4>&-
    zb_prog_success
fi

exit ${ZEBRA_STATUS}
