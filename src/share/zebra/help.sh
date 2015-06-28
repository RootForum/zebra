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

umsg="${ZB_COLOR_BOLD}usage: ${ZB_COLOR_RED}${ZB_COLOR_BOLD}zebra ${ZB_COLOR_WHITE}["
umsg="${umsg}${ZB_COLOR_RED}${ZB_COLOR_BOLD}-d${ZB_COLOR_WHITE}] ["
umsg="${umsg}${ZB_COLOR_RED}${ZB_COLOR_BOLD}-e ${ZB_COLOR_GREEN}${ZB_COLOR_BOLD}etcdir"
umsg="${umsg}${ZB_COLOR_WHITE}] [${ZB_COLOR_RED}${ZB_COLOR_BOLD}-N${ZB_COLOR_WHITE}]"
umsg="${umsg} [${ZB_COLOR_RED}${ZB_COLOR_BOLD}-S${ZB_COLOR_WHITE}]"
umsg="${umsg} ${ZB_COLOR_RED}${ZB_COLOR_BOLD}command ${ZB_COLOR_WHITE}[${ZB_COLOR_GREEN}"
umsg="${umsg}${ZB_COLOR_BOLD}options${ZB_COLOR_WHITE}]"

[ "${ZB_SILENT}" = "yes" ] || echo -e "$umsg

${ZB_COLOR_RED}${ZB_COLOR_BOLD}Options:
${ZB_COLOR_RED}${ZB_COLOR_BOLD}    -d${ZB_COLOR_RESET}          -- Show debug messages
${ZB_COLOR_RED}${ZB_COLOR_BOLD}    -e ${ZB_COLOR_GREEN}${ZB_COLOR_BOLD}etcdir${ZB_COLOR_RESET}   -- Specify an alternate etc/ dir where zebra configuration
                   resides.
${ZB_COLOR_RED}${ZB_COLOR_BOLD}    -N${ZB_COLOR_RESET}          -- Disable colors
${ZB_COLOR_RED}${ZB_COLOR_BOLD}    -S${ZB_COLOR_RESET}          -- Silent mode suppressing any output

${ZB_COLOR_RED}${ZB_COLOR_BOLD}Commands:
${ZB_COLOR_GREEN}${ZB_COLOR_BOLD}    help${ZB_COLOR_RESET}        -- Show usage
${ZB_COLOR_GREEN}${ZB_COLOR_BOLD}    init${ZB_COLOR_RESET}        -- Create new zebra tab
${ZB_COLOR_GREEN}${ZB_COLOR_BOLD}    backup${ZB_COLOR_RESET}      -- Create new backups
${ZB_COLOR_GREEN}${ZB_COLOR_BOLD}    restore${ZB_COLOR_RESET}     -- Restore an existing backup
${ZB_COLOR_GREEN}${ZB_COLOR_BOLD}    version${ZB_COLOR_RESET}     -- Show the version of zebra
"

exit ${ZEBRA_STATUS}
