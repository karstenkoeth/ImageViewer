# #########################################
#
# Overview
#
# This is an bash script include file.
# This file is used by:
# image_viewer_server.sh
# html_collect_pictures.sh

# #########################################
#
# Versions
#
# 2018-04-06 0.01 kdk First version
# 2018-05-21 0.10 kdk With license text.
# 2022-02-23 0.11 kdk With echol()
# 2022-02-24 0.12 kdk With delFile()

# #########################################
#
# MIT license (MIT)
#
# Copyright 2022 - 2018 Karsten Köth
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# #########################################
#
# Functions
#

# #########################################
# echod
# Shows debug messages.
# Parameters:
# $1 : Function calling
# $2 : Content
function echod()
{
  if [ "$ECHODEBUG" = "1" ] ; then
    echo "[$PROG_NAME:$1] $2"
  fi
}

# #########################################
# echov
# Shows verbose messages.
# Parameters:
# $1 : Function calling
# $2 : Content
function echov()
{
  if [ "$ECHOVERBOSE" = "1" ] ; then
    echo "[$PROG_NAME:$1] $2"
  fi
}

# #########################################
# echon
# Shows normal messages. Could be switched off with e.g. "-q" = "--quiet"
# Parameters:
# $1 : Function calling
# $2 : Content
function echon()
{
  if [ "$ECHONORMAL" = "1" ] ; then
    echo "[$PROG_NAME:$1] $2"
  fi
}

# #########################################
# echow
# Shows warning messages.
# Parameters:
# $1 : Function calling
# $2 : Content
function echow()
{
  if [ "$ECHOWARNING" = "1" ] ; then
    echo "[$PROG_NAME:$1] $2"
  fi
}

# #########################################
# echoe
# Shows error messages.
# Parameters:
# $1 : Function calling
# $2 : Content
function echoe()
{
  if [ "$ECHOERROR" = "1" ] ; then
    echo "[$PROG_NAME:$1] $2"
  fi
}

# #########################################
# echol
# Log messages into file.
# Parameters:
# $1 : Function calling
# $2 : Content
function echol()
{
  if [ "$ECHOLOG" = "1" ] ; then
    local actDateTime=$(date "+%Y-%m-%d.%H_%M_%S")
    echo "$actDateTime [$PROG_NAME:$1] $2" >> "$LOGFILE"
  fi
}

# #########################################
# delFile()
# Parameter
#   1: File name
# Deletes a file, if it exists.
# Code copied from bashutils - bashutils_common_functions.bash Version 0.27
function delFile()
{
    if [ -f "$1" ] ; then
        rm "$1"
    fi
}
