#!/bin/bash

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
# Constants
#

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
tsc actions.ts
tsc websockets.ts
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

# Actions
cp actions.js "$TARGET"
cp websockets.js "$TARGET"
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
cp html_collect_pictures.sh "$SERVER"
cp exif2html.sh "$SERVER"

echo "Post install ..."
chmod u+x "$SERVER/image_viewer_server.sh"
chmod u+x "$SERVER/image_viewer_common_vars.bash"
chmod u+x "$SERVER/image_viewer_common_func.bash"
chmod u+x "$SERVER/html_collect_pictures.sh"
chmod u+x "$SERVER/exif2html.sh"

# #########################################

echo "Done."

# #########################################
