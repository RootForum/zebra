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

# This file defines non-configurable defaults, that are used by
# zebra internally.

# Tmp location
ZB_SYS_TMP=/tmp

# Name of the zebra etc directory
ZB_ETC=etc

# Name of the zebra configuration directory
ZB_ZEBRAD=zebra.d

# Name of the zebra configuration file
ZB_CONF=zebra.conf

# Current version number
ZB_FBSD_CURRENT=11

# Full backup mode
ZB_MODE_FULL=full

# Differential backup mode
ZB_MODE_DIFF=diff

# Incremental backup mode
ZB_MODE_INC=inc

# no compression method
ZB_COMP_NONE=none

# bzip2 compression method
ZB_COMP_BZ=bz2

# gzip compression method
ZB_COMP_GZ=gz

# xz compression method
ZB_COMP_XZ=xz

# Default time for backup execution
ZB_DEFAULT_MINUTE="1"
ZB_DEFAULT_HOUR="1"
ZB_DEFAULT_MDAY="*"
ZB_DEFAULT_MONTH="*"
ZB_DEFAULT_WDAY="*"

# Default backup mode
ZB_DEFAULT_MODE=${ZB_MODE_FULL}

# Default backup generations
ZB_DEFAULT_GENS=1

# Default compression method
ZB_DEFAULT_COMP=${ZB_COMP_XZ}

# Default encryption setting
ZB_DEFAULT_ENC=no

# Default pre snapshot hook
ZB_DEFAULT_PRE=none

# Default post snapshot hook
ZB_DEFAULT_POST=none

# Default recursive operation setting
ZB_DEFAULT_REC=no

# Template for the job tab file header
ZB_JOBTAB_HEADER="# ++++++++++++++++++++++
# + Zebra Job Tab File +
# ++++++++++++++++++++++
#
# Basically, this file strongly resembles an ordinary crontab, listing
# a timetable with all datasets to be backed up. Similar to the crontab
# format, empty and commented lines (beginning with a hash sign #) will
# be ignored. However, inline comments are not explicitely supported, so
# they should be avoided.
#
# Since this job tab is serving a slightly different purpose than a crontab,
# some fields look different and have a different purpose. Here is a list of
# fields supported:
#
# Field    Meaning                 Allowed values
# -------- ----------------------  --------------
# minute   minute                  0-59
# hour     hour                    0-23
# mday     day of month            1-31
# month    month                   1-12
# wday     day of week             0-7 (0 or 7 is Sun)
# mode     backup mode             full, diff, inc
# gens     number of generations   integer >=1
# comp     compression method      none, bz2, gz, xz
# enc      encrypt the backup      yes, no
# pre      pre-snapshot hook       none or custom function
# post     post-snapshot hook      none or custom function
# rec      recursive operation     yes, no
# dataset  zfs dataset             valid zfs dataset
#
#minute\thour\tmday\tmonth\twday\tmode\tgens\tcomp\tenc\tpre\tpost\trec\tdataset
#\n"
