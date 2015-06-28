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
b_grep=$(zb_detect_binary "grep")
b_mount=$(zb_detect_binary "mount")
b_realpath=$(zb_detect_binary "realpath")
b_rm=$(zb_detect_binary "rm")
b_sed=$(zb_detect_binary "sed")
b_sysctl=$(zb_detect_binary "sysctl")
b_wc=$(zb_detect_binary "wc")
b_zfs=$(zb_detect_binary "zfs")
b_zpool=$(zb_detect_binary "zpool")
