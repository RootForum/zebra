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

zb_color_on() {
    if ! [ -t 1 ] || ! [ -t 2 ]; then
        ZB_USE_COLORS="no"
    fi

    if [ ${ZB_USE_COLORS} = "yes" ]; then
        ZB_COLOR_RESET="\033[0;0m"
        ZB_COLOR_RESET_REAL="${ZB_COLOR_RESET}"
        ZB_COLOR_BOLD="\033[1m"
        ZB_COLOR_UNDER="\033[4m"
        ZB_COLOR_BLINK="\033[5m"
        ZB_COLOR_BLACK="\033[0;30m"
        ZB_COLOR_RED="\033[0;31m"
        ZB_COLOR_GREEN="\033[0;32m"
        ZB_COLOR_AMBER="\033[0;33m"
        ZB_COLOR_BLUE="\033[0;34m"
        ZB_COLOR_MAGENTA="\033[0;35m"
        ZB_COLOR_CYAN="\033[0;36m"
        ZB_COLOR_LIGHT_GRAY="\033[0;37m"
        ZB_COLOR_DARK_GRAY="\033[1;30m"
        ZB_COLOR_LIGHT_RED="\033[1;31m"
        ZB_COLOR_LIGHT_GREEN="\033[1;32m"
        ZB_COLOR_YELLOW="\033[1;33m"
        ZB_COLOR_LIGHT_BLUE="\033[1;34m"
        ZB_COLOR_LIGHT_MAGENTA="\033[1;35m"
        ZB_COLOR_LIGHT_CYAN="\033[1;36m"
        ZB_COLOR_WHITE="\033[1;37m"

        ZB_COLOR_WARN=${ZB_COLOR_YELLOW}
        ZB_COLOR_DEBUG=${ZB_COLOR_CYAN}
        ZB_COLOR_ERROR=${ZB_COLOR_RED}
        ZB_COLOR_INFO=${ZB_COLOR_LIGHT_GRAY}
        ZB_COLOR_NOTICE=${ZB_COLOR_WHITE}
        ZB_COLOR_SUCCESS=${ZB_COLOR_GREEN}
        ZB_COLOR_IGNORE=${ZB_COLOR_DARK_GRAY}
        ZB_COLOR_SKIP=${ZB_COLOR_AMBER}
        ZB_COLOR_FAIL=${ZB_COLOR_RED}
        ZB_COLOR_EM=${ZB_COLOR_LIGHT_MAGENTA}${ZB_COLOR_BOLD}
    fi
}

zb_color_off() {
    ZB_COLOR_RESET=""
    ZB_COLOR_RESET_REAL="${ZB_COLOR_RESET}"
    ZB_COLOR_BOLD=""
    ZB_COLOR_UNDER=""
    ZB_COLOR_BLINK=""
    ZB_COLOR_BLACK=""
    ZB_COLOR_RED=""
    ZB_COLOR_GREEN=""
    ZB_COLOR_AMBER=""
    ZB_COLOR_BLUE=""
    ZB_COLOR_CYAN=""
    ZB_COLOR_MAGENTA=""
    ZB_COLOR_LIGHT_GRAY=""
    ZB_COLOR_DARK_GRAY=""
    ZB_COLOR_LIGHT_RED=""
    ZB_COLOR_LIGHT_GREEN=""
    ZB_COLOR_YELLOW=""
    ZB_COLOR_LIGHT_BLUE=""
    ZB_COLOR_LIGHT_MAGENTA=""
    ZB_COLOR_LIGHT_CYAN=""
    ZB_COLOR_WHITE=""

    ZB_COLOR_WARN=${ZB_COLOR_YELLOW}
    ZB_COLOR_DEBUG=${ZB_COLOR_CYAN}
    ZB_COLOR_ERROR=${ZB_COLOR_RED}
    ZB_COLOR_INFO=${ZB_COLOR_LIGHT_GRAY}
    ZB_COLOR_SUCCESS=${ZB_COLOR_GREEN}
    ZB_COLOR_IGNORE=${ZB_COLOR_DARK_GRAY}
    ZB_COLOR_SKIP=${ZB_COLOR_AMBER}
    ZB_COLOR_FAIL=${ZB_COLOR_RED}
    ZB_COLOR_EM=${ZB_COLOR_LIGHT_MAGENTA}${ZB_COLOR_BOLD}
}
