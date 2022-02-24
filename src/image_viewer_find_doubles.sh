#!/bin/bash

# #########################################
#
# Overview
#
# This script find doubles in the image viewer data base.

# #########################################
#
# Versions
#
# 2020-12-17 0.01 kdk First Version of bashutils - bash-script-template
# 2020-12-20 0.02 kdk With actDateTime
# 2021-01-29 0.03 kdk 2021 year ready, with PROG_DATE and Copyright in help, with showVersion()
# 2021-02-08 0.04 kdk License text enhanced.
# 2022-02-24 0.05 kdk First version of ImageViewer Find Doubles - not yet tested

PROG_NAME="ImageViewer Find Doubles"
PROG_VERSION="0.05"
PROG_DATE="2022-02-24"
PROG_CLASS="ImageViewer"
PROG_SCRIPTNAME="image_viewer_find_doubles.sh"

# #########################################
#
# TODOs
#

# #########################################
#
# This software is licensed under
#
# MIT license (MIT)
#
# Copyright 2022 Karsten Köth
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
# Includes
#
# TODO: Given in this way, the include file must be in same directory the 
#       script is called from. We have to auto-detect the path to the binary.
# source bashutils_common_functions.bash



# #########################################
#
# Constants
#


# #########################################
#
# Variables
#

source image_viewer_common_vars.bash


# #########################################
#
# Functions
#

source image_viewer_common_func.bash


# #########################################
# getFirstNewLine()
# Parameter
#    -
# Return Value
#    Line Number
# Returns the number of the first new line in the database file
function getFirstNewLine()
{
    if [ -f "$FILEPOINTERFILE" ] ; then
        head -n 1 "$FILEPOINTERFILE"
    else
        # No file found. Therefore start from beginning:
        echo 0
    fi
}

# #########################################
# showHelp()
# Parameter
#    -
# Return Value
#    -
# Show help.
function showHelp()
{
    echo "[$PROG_NAME] Program Parameter:"
    echo "    -V     : Show Program Version"
    echo "    -h     : Show this help"
    echo "Copyright $PROG_DATE by Karsten Köth"
}

# #########################################
# showVersion()
# Parameter
#    -
# Return Value
#    -
# Show version information.
function showVersion()
{
    echo "$PROG_NAME ($PROG_CLASS) $PROG_VERSION"
}

# #########################################
#
# Main
#

echon "Main" "Starting ..."

# Check for program parameters:
if [ $# -eq 1 ] ; then
    if   [ "$1" = "-V" ] ; then
        showVersion ; exit;
    else [ "$1" = "-h" ] 
        showHelp ; exit;
    fi
fi

# Check if database is reachable:
if [ -f "$DATABASEFILE" ] ; then
    echod "Main:Check" "Database File presend"
else
    echoe "Main:Check" "Database File not found. Exit"
    exit
fi


# TODO
# Hier muss losgelegt werden
#

StartingLine=$(getFirstNewLine)

#
#for
# jede Zeile in ... startend mit dem ersten neuen Eintrag.

# Clean up:
delFile "$FILEPOINTERFILE"

echon "Main" "Done."
