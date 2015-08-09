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

# cd into / to avoid foot-shooting if running from deleted dirs or
# NFS dir which root has no access to.
ZB_SAVED_PWD="${PWD}"
cd /

# Pre-set information from calling binary
: ${ZEBRA_STATUS:=0}
: ${ZB_USE_COLORS:=yes}

# include non-configurable defaults
. ${SCRIPTPREFIX}/include/early/defaults.sh

# include early output handler
. ${SCRIPTPREFIX}/include/early/output.sh

# include binary detection
. ${SCRIPTPREFIX}/include/early/binary.sh

# module-specific variables
zbb_realpath=$(zb_detect_binary "realpath")

# set up configurable settings
# look for the zebra configuration file
[ -z "${ZEBRA_ETC}" ] &&
    ZEBRA_ETC=$(${zbb_realpath} ${SCRIPTPREFIX}/../../${ZB_ETC})
# If this is a relative path, add in ${PWD} as a cd / is done.
[ "${ZEBRA_ETC#/}" = "${ZEBRA_ETC}" ] && \
    ZEBRA_ETC="${SAVED_PWD}/${ZEBRA_ETC}"
ZEBRAD="${ZEBRA_ETC}/${ZB_ZEBRAD}"
if [ -r "${ZEBRA_ETC}/${ZB_CONF}" ]; then
    . "${ZEBRA_ETC}/${ZB_CONF}"
elif [ -r "${ZEBRAD}/${ZB_CONF}" ]; then
    . "${ZEBRAD}/${ZB_CONF}"
else
    zb_early_die 1 "Unable to find a readable ${ZB_CONF} in ${ZEBRA_ETC} or ${ZEBRAD}"
fi

. ${SCRIPTPREFIX}/include/early/config.sh

# include normal output handler
. ${SCRIPTPREFIX}/include/normal/output.sh

# include global auxiliary functions
. ${SCRIPTPREFIX}/include/normal/aux.sh

# include file operation functions
. ${SCRIPTPREFIX}/include/normal/unistd.sh

# include ZFS operation functions
. ${SCRIPTPREFIX}/include/normal/zfs.sh
