#!/bin/bash

# #########################################
#
# Overview
#
# This script starts the image_viewer_server.sh shell script.

# #########################################
#
# Versions
#
# 2021-02-24 0.01 kdk First Version - Done of base from bashutils/bash-script-template.sh 2021-02-08 0.04

PROG_NAME="ImageViewer Start"
PROG_VERSION="0.01"
PROG_DATE="2021-02-24"
PROG_CLASS="ImageViewer"
PROG_SCRIPTNAME="image_viewer_startserver.sh"

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
# Copyright 2021 Karsten Köth
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


# #########################################
#
# Constants
#

appSocket="websocketd"
appServer="image_viewer_server.sh"

# #########################################
#
# Variables
#

# Typically, we need in a lot of scripts the start date and time of the script:
actDateTime=$(date "+%Y-%m-%d +%H:%M:%S")

# Handle output of the different verbose levels - in combination with the 
# "echo?" functions inside "bashutils_common_functions.bash":
ECHODEBUG="0"
ECHOVERBOSE="0"
ECHONORMAL="1"
ECHOWARNING="0"
ECHOERROR="0"

# #########################################
#
# Functions
#

# #########################################
# checkDependencies()
# Parameter
#    -
# Return Value
#    -
# Check if all dependencies are available.
function checkDependencies()
{
    # Web Sockets Bash Extension:
    checkApp=$(which "$appSocket")
    if [ -n "$checkApp" ] ; then
        if [ -x "$checkApp" ] ; then
            echo "[$PROG_NAME:STATUS] Socket layer found."
        else
            echo "[$PROG_NAME:ERROR] No execution rights at socket layer. Exit."
            exit
        fi
    else
        echo "[$PROG_NAME:ERROR] Socket layer not found. Exit."
        exit
    fi 

    # Check main program:
    checkApp=$(which "$appServer")
    if [ -n "$checkApp" ] ; then
        if [ -x "$checkApp" ] ; then
            echo "[$PROG_NAME:STATUS] Server found."
        else
            echo "[$PROG_NAME:ERROR] No execution rights at server. Exit."
            exit
        fi

    # Maybe later, we could check the version number:
    #
    #    versionS=$($appServer -V)
    #    versionB=$(echo "$versionS" | grep ")")
    #    if [ -n "$versionB" ] ; then
    #        versionI=$(echo "$versionS" | cut -d ")" -f 2 - )
    #        ...

    else
        echo "[$PROG_NAME:ERROR] Server not found. Exit."
        exit
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
    echo "[$PROG_NAME:STATUS] Program Parameter:"
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

echo "[$PROG_NAME] Starting ..."

# Check for program parameters:
if [ $# -eq 1 ] ; then
    if [ -f "$1" ] ; then
        echo "[$PROG_NAME:STATUS] Input file exists."
    elif [ "$1" = "-V" ] ; then
        showVersion ; exit;
    elif [ "$1" = "-h" ] ; then
        showHelp ; exit;
    else
        echo "[$PROG_NAME:ERROR] No input file. Exit." ; exit;
    fi
fi

checkDependencies

# Start Server:
websocketd --port=8080 image_viewer_server.sh 
# TODO: Maybe with version 1.0 and higher we could add an "&" at line end.

echo "[$PROG_NAME] Done."
