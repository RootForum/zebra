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

# include output coloring helpers
. ${SCRIPTPREFIX}/include/early/color.sh

# include auxiliaries
. ${SCRIPTPREFIX}/include/normal/aux.sh

# standard output is going to the terminal.
: ${ZB_OUTPUT_CHANNEL:=term}
[ "${ZB_USE_COLORS}"="yes" ] && zb_color_on

_zb_log_numeric_level() {
    # return the numeric value corresponding to a log level
    [ $# -ne 1 ] && return 1
    case ${1} in
        debug|DEBUG)
            echo 5
            ;;
        info|INFO)
            echo 4
            ;;
        notice|NOTICE)
            echo 3
            ;;
        warn|WARNING)
            echo 2
            ;;
        error|ERR)
            echo 1
            ;;
        silent|none)
            echo 0
            ;;
        *)
            echo 3
            ;;
    esac
    return 0
}

# log level remains as specified if no increment was indicated
: ${ZB_LOG_INCREMENT:=0}

# determine the real log level to be respected (numeric value)
ZB_LOG_LEVEL=$(_zb_log_numeric_level ${LOG_LEVEL})
ZB_LOG_LEVEL=$((${ZB_LOG_LEVEL}+${ZB_LOG_INCREMENT}))
ZB_LOG_LEVEL=$(min ${ZB_LOG_LEVEL} 5)
ZB_LOG_LEVEL=$(max ${ZB_LOG_LEVEL} 0)

# module-specific variables
zbb_logger=$(zb_detect_binary "logger")
zbb_date=$(zb_detect_binary "date")

_zb_log_term() {
    # Send log messages to a terminal
    #
    # Arguments:
    # (1) criticality - one of DEBUG, INFO, NOTICE, WARNING, ERR
    # (2) message     - the message to log

    # Verify two arguments were submitted
    [ $# -ne 2 ] && return 1

    # Respect the log level
    [ "$(_zb_log_numeric_level ${1})" -gt "${ZB_LOG_LEVEL}" ] && return 0

    # Select message prefix
    local prefix=""
    case ${1} in
        DEBUG)
            prefix="${ZB_COLOR_DEBUG}${ZB_COLOR_BOLD}>>> Debg:${ZB_COLOR_RESET}${ZB_COLOR_IGNORE}"
            ;;
        INFO)
            prefix="${ZB_COLOR_INFO}${ZB_COLOR_BOLD}>>> Info:${ZB_COLOR_RESET}${ZB_COLOR_IGNORE}"
            ;;
        NOTICE)
            prefix="${ZB_COLOR_NOTICE}${ZB_COLOR_BOLD}>>> Note:${ZB_COLOR_RESET}"
            ;;
        WARNING)
            prefix="${ZB_COLOR_WARN}${ZB_COLOR_BOLD}>>> Warn:${ZB_COLOR_RESET}"
            ;;
        ERR)
            prefix="${ZB_COLOR_ERROR}${ZB_COLOR_BOLD}>>> Fail:${ZB_COLOR_RESET}"
            ;;
        *)
            prefix="${ZB_COLOR_NOTICE}${ZB_COLOR_BOLD}>>> Note:${ZB_COLOR_RESET}"
            ;;
    esac

    # output the log message
    printf "${prefix} ${2}${ZB_COLOR_RESET_REAL}\n"
}

_zb_log_file() {
    # Send log messages to a file
    #
    # Arguments:
    # (1) criticality - one of DEBUG, INFO, NOTICE, WARNING, ERR
    # (2) message     - the message to log

    # Verify two arguments were submitted
    [ $# -ne 2 ] && return 1

    # Respect the log level
    [ "$(_zb_log_numeric_level ${1})" -gt "${ZB_LOG_LEVEL}" ] && return 0

    # Select message prefix
    local prefix=""
    local timestamp=$(${zbb_date} '+%Y-%m-%d %H:%M:%S')
    case ${1} in
        DEBUG)
            prefix="[${timestamp}] [DEBG]"
            ;;
        INFO)
            prefix="[${timestamp}] [INFO]"
            ;;
        NOTICE)
            prefix="[${timestamp}] [NOTE]"
            ;;
        WARNING)
            prefix="[${timestamp}] [WARN]"
            ;;
        ERR)
            prefix="[${timestamp}] [FAIL]"
            ;;
        *)
            prefix="[${timestamp}] [NOTE]"
            ;;
    esac

    # output the log message
    echo "${prefix} ${2}" >> "${LOG_FILE}"
}

_zb_log_syslog() {
    # Send log messages to syslog
    #
    # Arguments:
    # (1) criticality - one of DEBUG, INFO, NOTICE, WARNING, ERR
    # (2) message     - the message to log

    # Verify two arguments were submitted
    [ $# -ne 2 ] && return 1

    # Respect the log level
    [ "$(_zb_log_numeric_level ${1})" -gt "${ZB_LOG_LEVEL}" ] && return 0

    # Select message prefix
    local prefix=""
    local level=""
    case ${1} in
        DEBUG)
            prefix="[DEBG]"
            level="debug"
            ;;
        INFO)
            prefix="[INFO]"
            level="info"
            ;;
        NOTICE)
            prefix="[NOTE]"
            level="notice"
            ;;
        WARNING)
            prefix="[WARN]"
            level="warning"
            ;;
        ERR)
            prefix="[FAIL]"
            level="err"
            ;;
        *)
            prefix="[NOTE]"
            level="notice"
            ;;
    esac

    # output the log message
    ${zbb_logger} -t "${prefix}" -p "${LOG_TARGET}.${level}"  "${2}"
}

zb_log() {
    # log the submitted message to the currently valid logging channel
    #
    # Arguments:
    # (1) criticality - one of DEBUG, INFO, NOTICE, WARNING, ERR
    # (2) message     - the message to log

    # Verify two arguments were submitted
    [ $# -ne 2 ] && return 1

    # Respect the log level
    [ "$(_zb_log_numeric_level ${1})" -gt "${ZB_LOG_LEVEL}" ] && return 0

    # log the message into the right channel
    case ${ZB_OUTPUT_CHANNEL} in
        term)
            _zb_log_term ${1} "${2}"
            ;;
        file)
            _zb_log_file ${1} "${2}"
            ;;
        syslog)
            _zb_log_syslog ${1} "${2}"
            ;;
    esac
}

zb_log_error() {
    # log the submitted message with error criticality

    # Verify an argument was submitted
    [ $# -ne 1 ] && return 1

    # Respect the log level
    [ "1" -gt "${ZB_LOG_LEVEL}" ] && return 0

    # log the message
    zb_log "ERR" "${1}"
    return $?
}

zb_log_warn() {
    # log the submitted message with warning criticality

    # Verify an argument was submitted
    [ $# -ne 1 ] && return 1

    # Respect the log level
    [ "2" -gt "${ZB_LOG_LEVEL}" ] && return 0

    # log the message
    zb_log "WARNING" "${1}"
    return $?
}

zb_log_note() {
    # log the submitted message with notice criticality

    # Verify an argument was submitted
    [ $# -ne 1 ] && return 1

    # Respect the log level
    [ "3" -gt "${ZB_LOG_LEVEL}" ] && return 0

    # log the message
    zb_log "NOTICE" "${1}"
    return $?
}

zb_log_info() {
    # log the submitted message with info criticality

    # Verify an argument was submitted
    [ $# -ne 1 ] && return 1

    # Respect the log level
    [ "4" -gt "${ZB_LOG_LEVEL}" ] && return 0

    # log the message
    zb_log "INFO" "${1}"
    return $?
}

zb_log_debug() {
    # log the submitted message with error criticality

    # Verify an argument was submitted
    [ $# -ne 1 ] && return 1

    # Respect the log level
    [ "5" -gt "${ZB_LOG_LEVEL}" ] && return 0

    # log the message
    zb_log "DEBUG" "${1}"
    return $?
}

zb_prog_msg() {
    [ "${ZB_OUTPUT_CHANNEL}" != "term" ] && return 0
    [ "3" -gt "${ZB_LOG_LEVEL}" ] && return 0
    COLOR_ARROW="${COLOR_INFO}${COLOR_BOLD}"
    printf "${COLOR_ARROW}>>>${COLOR_RESET} ${COLOR_INFO}${1}"
    printf "${COLOR_BOLD} ... ${COLOR_RESET_REAL}"
}

zb_prog_success() {
    [ "${ZB_OUTPUT_CHANNEL}" != "term" ] && return 0
    [ "3" -gt "${ZB_LOG_LEVEL}" ] && return 0
    printf "${COLOR_SUCCESS}${COLOR_BOLD}success${COLOR_RESET_REAL}\n"
}

zb_prog_fail() {
    [ "${ZB_OUTPUT_CHANNEL}" != "term" ] && return 0
    [ "3" -gt "${ZB_LOG_LEVEL}" ] && return 0
    printf "${COLOR_FAIL}${COLOR_BOLD}fail${COLOR_RESET_REAL}\n"
}

zb_die() {
    if [ $# -ne 2 ]; then
        zb_die 1 "zb_die() expects 2 arguments: exit_number \"message\""
    fi
    zb_log_error "${2}" || :
    exit $1
}
