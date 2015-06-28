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

# include output coloring helpers
. ${SCRIPTPREFIX}/include/early/color.sh

# enable color support
[ "${ZB_USE_COLORS}"="yes" ] && zb_color_on

zb_early_log() {
    [ "${ZB_SILENT}" = "yes" ] && return 0
    if [ -n "${ZB_COLOR_ARROW}" ] || [ -z "${1##*\033[*}" ]; then
        printf "${ZB_COLOR_ARROW}>>>${ZB_COLOR_RESET} ${1}${ZB_COLOR_RESET_REAL}\n"
    else
        printf ">>> ${1}\n"
    fi
}

zb_early_log_error() {
    ZB_COLOR_ARROW="${ZB_COLOR_ERROR}${ZB_COLOR_BOLD}" \
        zb_early_log "${ZB_COLOR_ERROR}${ZB_COLOR_BOLD}Error:${ZB_COLOR_RESET} $1" >&2
    return 0
}

zb_early_log_warn() {
    ZB_COLOR_ARROW="${ZB_COLOR_WARN}${ZB_COLOR_BOLD}" \
        zb_early_log "${ZB_COLOR_WARN}${ZB_COLOR_BOLD}Warning:${ZB_COLOR_RESET} $@" >&2
    return 0
}

zb_early_log_debug() {
    [ ${ZB_DEBUG} = "yes" ] && ZB_COLOR_ARROW="${ZB_COLOR_DEBUG}${ZB_COLOR_BOLD}" \
        zb_early_log "${ZB_COLOR_DEBUG}${ZB_COLOR_BOLD}Debug:${ZB_COLOR_RESET}${ZB_COLOR_IGNORE} $@" >&2
    return 0
}

zb_early_log_info() {
    ZB_COLOR_ARROW="${ZB_COLOR_INFO}${ZB_COLOR_BOLD}" \
        zb_early_log "${ZB_COLOR_INFO}${ZB_COLOR_BOLD}Info:${ZB_COLOR_RESET}${ZB_COLOR_IGNORE} $@" >&2
    return 0
}

zb_early_die() {
    if [ $# -ne 2 ]; then
        zb_early_die 1 "zb_early_die() expects 2 arguments: exit_number \"message\""
    fi
    zb_early_log_error "${2}" || :
    exit $1
}
