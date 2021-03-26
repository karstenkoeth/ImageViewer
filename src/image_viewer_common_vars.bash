# #########################################
#
# Overview
#
# This is an bash script include file.
# This file is used by:
#  • image_viewer_server.sh
#  • html_collect_pictures.sh

# #########################################
#
# Versions
#
# 2018-03-17 0.01 kdk First version
# 2018-03-18 0.02 kdk First version with version number.
# 2018-04-05 0.03 kdk With all variables from html_collect_pictures.
# 2018-05-21 0.10 kdk With license text and file extension changed from inc to
#                     bash.
# 2020-11-16 0.11 kdk With ExportBashScript
# 2021-03-26 0.12 kdk With more comments

# #########################################
#
# MIT license (MIT)
#
# Copyright 2021 - 2018 Karsten Köth
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
# Variables
#

ECHODEBUG="0"
ECHOVERBOSE="0"
ECHONORMAL="1"
ECHOWARNING="1"
ECHOERROR="1"

# #########################################
#
# Constants
#

HOME="/Users/koeth"
SETTINGSFILE="$HOME/.imageviewer"
DATABASEFOLDER="$HOME/Pictures/ImageViewer"
#DATABASEFOLDER="$HOME/Sites/ImageViewer"
DATABASEFILE="$DATABASEFOLDER/pictures.csv"
UUIDFILE="$DATABASEFOLDER/filenames.csv"
ALBUMFILE="$DATABASEFOLDER/albumnames.csv"
ALBUMPREFIX="$DATABASEFOLDER/album_"
ALBUMPOSTFIX=".csv"
#THUMBNAILFOLDER="$DATABASEFOLDER/Thumbnails"
THUMBNAILFOLDER="$HOME/Sites/ImageViewer/Thumbnails"
EXPORTFOLDER="$HOME/tmp/ImageViewer/Export"
EXPORTBASHSCRIPT="$EXPORTFOLDER/image_viewer_export.sh" # Will be created by image_viewer_server.sh
# TODO MIRRORFOLDER
# In JavaScript hard coded:
#WEBFOLDER="$DATABASEFOLDER"
#WEBTHUMBNAIL="$WEBFOLDER/Thumbnails"

TEST="Mein Test"
