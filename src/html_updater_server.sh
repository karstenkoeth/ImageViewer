#!/bin/bash

# #########################################
#
# Versions
#
# 2020-01-26 0.01 kdk First version

# This shell script is the bash endpoint of a websocket to update the html 
# page in the browser if the html page changes on the server.

# #########################################
#
# MIT license (MIT)
#
# Copyright 2018 Karsten Köth
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
# Usage
#
# Now let's turn it into a WebSocket server:
#
# $ websocketd --port=8081 ./html_updater_server.sh
#
# Inside the javascript code, the same port must be used.
#

# #########################################
#
# Links
#
# See TypeScript file html_Updater_client.ts 
# See make.sh in project root directory

# #########################################
#
# Constants
#

PROG_NAME="html_updater_server"
PROG_VERSION="0.01"

PROJECT="/Users/koeth/programmieren/ImageViewer/git/ImageViewer"
SOURCE="/Users/koeth/programmieren/ImageViewer/git/ImageViewer/src"
TARGET="/Users/koeth/Sites/ImageViewer"
SERVER="/Users/koeth/bin"

# #########################################
#
# Background Information
#
# Inotify-Tools: enthält mit Inotifywait und Inotifywatch zwei Tools für einfache Aufgaben.
# Iwatch: ein sehr einfach anzuwendendes Werkzeug.
# FsWatcher: ein komplexes Tool mit vielen Funktionen.
# Inotail: eine Inotify-gesteuerte Version von Tail als Alternative zum Aufruf tail -F Datei.
# Fsniper: ein konfigurationsgesteuerter Inotify-Monitor mit recht umständlicher Syntax.
# Watchman: ein konfigurationsgesteuerter Inotify-Monitor mit zahlreichen Funktionen.
# DirEvent: die GNU-kompatible, systemunabhängige Version.

# #########################################
#
# Includes
#
# Will be read once on start of the program. Used for debug output:

source image_viewer_common_vars.bash
source image_viewer_common_func.bash

# ##############################################################################
#
# Functions
#

# #########################################
#
# check_for_changes
#
# This funciton checks for change in the filesystem. If there is a change, the function
# informs over websocket: Reload
# Parameter: Nothing
# Return:    Nothing
check_for_changes()
{
    echo "CHCK=Starting ..."
    # If fswatch find a change, fire the reload information:
    fswatch -1 "$SOURCE" > /dev/null
    echo "CHCK=Change found. Preparing ..."
    # Change found, rerun make:
    "$PROJECT/make.sh" > /dev/null
    # Inform Webside:
    echo "RELD"
}

# #########################################
#
#  check_for_make
#
# This function checks the development directory and compile, convert, install, ... the 
# specific files - file by file.
# Event based working - not stupid working
# Parameter: Nothing
# Return:    Nothing
check_for_make()
{
    # TODO
    echo "MAKE=Starting ..."
    #fswatch -0 "$SOURCE/websockets.ts"        | xargs -0 -n 1 tsc "$SOURCE/websockets.ts"
    fswatch -0 "$SOURCE/html_updater_client.ts" | xargs -0 -n 1 tsc "$SOURCE/html_updater_client.ts" # TODO: In Background schicken, damit viel gemacht werden kann.
    # fswatch will run and allways starts the xargs again ... endless
    echo "MAKE=Started."
}

# ##############################################################################
#
# Main
#

# Init
# We are a webserver service, therefore:
ECHODEBUG="0"

# Main loop:
while read line; do
  len=${#line}
  # All commands have exact 4 characters.
  # Some commands have parameters. The first character of a parameter starts at
  # position "5". The character at position "4" between command and parameter
  # must be a "=".
  if [ "$len" -lt "4" ] ; then
    # String length too short. Exit:
    exit
  else
    # String could be a command:
    CMD=${line:0:4}
    DATA=""
    # Do we have a parameter?
    if [ "$len" -ge "5" ] ; then
      # We have a parameter!
      DATA=${line:5}
    fi
    echod "Main:Split" "CMD ='$CMD'"
    echod "Main:Split" "DATA='$DATA'"

    # ###########################
    #
    # Which command
    #

    # Common Commands:
    if [ "$CMD" = "QUIT" ] ; then
      echo "ACKN=QUIT"
      exit
    fi

    if [ "$CMD" = "ECHO" ] ; then
      echo "$DATA"
    fi

    if [ "$CMD" = "VERS" ] ; then
      echo "$PROG_NAME ($PROG_VERSION)"
    fi

    if [ "$CMD" = "DEBU" ] ; then
      if [ "$DATA" = "ON" ] ; then
        ECHODEBUG="1"
        echod "Main" "Debug output switched on."
      else
        ECHODEBUG="0"
      fi
    fi

    if [ "$CMD" = "HELP" ] ; then
      echo "$PROG_NAME ($PROG_VERSION)"
      echo "Four character command code. Some commands have arguments:"
      echo "QUIT      Quit program"
      echo "ECHO text Print text to stdout"
      echo "VERS      Print program name and version number to stdout."
      echo "DEBU=ON | OFF Switch debug output on and off. With debug on, the javascript will not work."
      echo "CHCK      Check for changes in the source directory and reload by a change the entire html side."
      echo "MAKE      Check for changes for specific files and do only that functions."
    fi

    if [ "$CMD" = "CHCK" ] ; then
      check_for_changes
    fi

    if [ "$CMD" = "MAKE" ] ; then
      check_for_make
    fi

  fi
done
