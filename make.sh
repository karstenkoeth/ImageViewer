#!/bin/bash

# #########################################
#
# MIT license (MIT)
#
# Copyright 2018 - 2021 Karsten Köth
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
#
# Make'n'run
#
# COMMAND: ifconfig | grep "inet " | grep "broadcast" | cut -f 2 -d " "
# OUTPUT:  10.0.1.12 (2018-05-22)
# RUN: image_viewer_startserver.sh

# #########################################
#
# Links
#
# See html_updater_server.sh

# #########################################
#
# Constants
#

PROJECT="/Users/koeth/programmieren/ImageViewer/git/ImageViewer"
SOURCE="/Users/koeth/programmieren/ImageViewer/git/ImageViewer/src"
TARGET="/Users/koeth/Sites/ImageViewer"
SERVER="/Users/koeth/bin"

# #########################################
#
# Main
#

echo "Preparing ..."
cd ./src/

echo "Starting ..."

echo "Transcode ..."
#tsc actions.ts
tsc websockets.ts
tsc html_updater_client.ts
#tsc renderer.ts

echo "Prepare..."
if [ ! -d "$TARGET" ] ; then
  # Try to create dir:
  mkdir -p "$TARGET"
fi
if [ ! -d "$TARGET/img" ] ; then
  # Try to create dir:
  mkdir -p "$TARGET/img"
fi

# #########################################

echo "Install Website ..."
# Layout
cp index.html "$TARGET"
cp global.css "$TARGET"
cp settings.html "$TARGET"
cp information.html "$TARGET"
cp helptext.html "$TARGET"

# Actions
#cp actions.js "$TARGET"
cp websockets.js "$TARGET"
cp html_updater_client.js "$TARGET"
#cp renderer.js "$TARGET"

# Content
cp ../img/default.png "$TARGET/img"
cp ../img/schnee.png "$TARGET/img"
cp ../img/wolken.png "$TARGET/img"

echo "Post install ..."
chmod +x "$TARGET"
chmod +x "$TARGET/img"
chmod +r "$TARGET/"*
chmod +r "$TARGET/img/"*

# #########################################

echo "Install Server ..."
cp image_viewer_server.sh "$SERVER"
cp image_viewer_common_vars.bash "$SERVER"
cp image_viewer_common_func.bash "$SERVER"
cp image_viewer_startserver.sh "$SERVER"
cp html_collect_pictures.sh "$SERVER"
cp exif2html.sh "$SERVER"
cp html_updater_server.sh "$SERVER" 

echo "Post install ..."
chmod u+x "$SERVER/image_viewer_server.sh"
chmod u+x "$SERVER/image_viewer_common_vars.bash"
chmod u+x "$SERVER/image_viewer_common_func.bash"
chmod u+x "$SERVER/image_viewer_startserver.sh"
chmod u+x "$SERVER/html_collect_pictures.sh"
chmod u+x "$SERVER/exif2html.sh"
chmod u+x "$SERVER/html_updater_server.sh"

# #########################################

echo "Done."
echo ""
echo "Run with: image_viewer_startserver.sh"
#echo "Run with: websocketd --port=8080 ./image_viewer_server.sh"
#echo "Run with: websocketd --port=8081 ./html_updater_server.sh"
echo ""
MYMASCHINE=$(ifconfig | grep "inet " | grep "broadcast" | cut -f 2 -d " ")
echo "You will run on $MYMASCHINE"

# #########################################
