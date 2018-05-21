#!/bin/sh

# #######################################################
# Versions:
#
# 2013-06-12 0.01 kdk First Version
# 2014-07-11 0.02 kdk
# 2016-05-17 0.03 kdk Adaptations for html_collect_pictures.sh
# 2017-11-23 0.04 kdk TODOs added.
# 2018-02-25 0.05 kdk export variables
# 2018-03-04 0.06 kdk With speed enhancements
# 2018-05-21 0.10 kdk With license text.

PROG_NAME="exif2html"
PROG_CLASS="htmlutils"
PROG_VERSION="0.10"
PROG_DATUM="21. Mai 2018"

# #######################################################
# Overview:
# Read out date and time of shot from photo.

# #######################################################
# Parameter:
# First program parameter: photo file

# #######################################################
# Needed programs:
#  exiftool
#  grep
#  getopt
#  cut

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

# ################################################
# Variables:

DEBUG=0
VERBOSE=0
QUIET=0


# ################################################
# Constants:

XS_ERROR="Error"
XS_WARNING="Warning"
XS_STATE="State"
XS_DEBUG="Debug"


# ###########################################
# Funktionen

function hilfe
{
  echo "Syntax: $PROG_NAME [OPTIONS] input_file"
  echo "Options: "
  echo "         -h or --help : Shows this help text and exit."
  echo "         -v or --verbose : Shows information on working."
  echo "         -q or --quiet : Shows nothing."
  echo "         -V or --version : Shows the version number of this script and exit."
  echo " "
  echo " "
  echo "Return Values: "
  echo "         0  No error occured."
  echo "         1  An error occured."
  echo "Copyright $PROG_DATUM by Karsten Köth"
  return
}

function version
{
  echo "$PROG_NAME ($PROG_CLASS) $PROG_VERSION"
  return
}

# #######################################################
# Main

  # getopt funktioniert nicht mit Dateinamen mit Leerzeichen, daher ohne:
  VERBOSE=0
  DEBUG=0

  # Get variables content from external program:
  DATABASEFOLDER=""
  DATABASEFOLDER="$IMAGEVIEWERDATABASEFOLDER"
  if [ -d "$DATABASEFOLDER" ] ; then
    DEBUG="$IMAGEVIEWERECHODEBUG"
    VERBOSE="$IMAGEVIEWERECHOVERBOSE"
  fi

  # Changes 2018-03-04: "" added
  JPGFILE="$1"

# program parameter parsed, start program:
if [ $VERBOSE = 1 ] ; then
  echo "[$PROG_NAME:$XS_STATE:ProgramParameter] Input File: '$JPGFILE'"
fi

# Read from jpg-File date of shot:
EXIFDATA=`exiftool -s -d "%Y-%m-%d.%H_%M_%S" "$JPGFILE"`

if [ $DEBUG = 1 ] ; then
  echo "[$PROG_NAME:$XS_DEBUG:AllData] '$EXIFDATA'"
fi

# Take only Field with date and jump over first space:
EXIFDATE=`echo "$EXIFDATA" | grep ^DateTimeOrig | cut -d ":" -f 2 | cut -c 2- -`
FILEDATE=`echo "$EXIFDATA" | grep ^FileModifyDate | cut -d ":" -f 2 | cut -c 2- -`
if [ $VERBOSE = 1 ] && [ "$EXIFDATE" != "" ]
then
    echo "[$PROG_NAME:$XS_STATE:Output] File '$JPGFILE' was made at $EXIFDATE."
fi

# Picture taken with wich camera?
CAMERA=`echo "$EXIFDATA" | grep ^Model | cut -d ":" -f 2 | cut -c 2- - | sed -e 's/ /-/g'`
# If only a picture without camera name:
if [ -z "$CAMERA" ] ; then
    CAMERA="File"
fi
if [ $VERBOSE = 1 ] ; then
    echo "[$PROG_NAME:$XS_STATE:Output] File '$JPGFILE' was made with $CAMERA."
fi

WIDTH=$(echo "$EXIFDATA" | grep ^ExifImageWidth | cut -d ":" -f 2 | cut -c 2- -)
if [ "$WIDTH" = "" ] ; then
    WIDTH=$(echo "$EXIFDATA" | grep ^ImageWidth | cut -d ":" -f 2 | cut -c 2- -)
fi
if [ $VERBOSE = 1 ] ; then
    echo "[$PROG_NAME:$XS_STATE:Output] File '$JPGFILE' has width $WIDTH."
fi

HEIGHT=$(echo "$EXIFDATA" | grep ^ExifImageHeight | cut -d ":" -f 2 | cut -c 2- -)
if [ "$HEIGHT" = "" ] ; then
    HEIGHT=$(echo "$EXIFDATA" | grep ^ImageHeight | cut -d ":" -f 2 | cut -c 2- -)
fi
if [ $VERBOSE = 1 ] ; then
    echo "[$PROG_NAME:$XS_STATE:Output] File '$JPGFILE' has height $HEIGHT."
fi


# The same picture could be stored in different folders. But all thumbs will
# be stored in same folder. Therefore make the thumb unique:
UUID=$(uuidgen)

# If no EXIFDATE is found, use file date:
if [ "$EXIFDATE" = "" ] ; then
  DATETIME="$FILEDATE"
else
  DATETIME="$EXIFDATE"
fi

NEWFILENAME="$DATETIME.$WIDTH"x"$HEIGHT.$CAMERA.$IMAGEVIEWERFILENAME"
THUMBNAME="$DATETIME.$UUID.$WIDTH"x"$HEIGHT.$CAMERA.THUMB.$IMAGEVIEWERFILENAME"


# TODO Create html line with link to thumbnail...

if [ $VERBOSE = 1 ] ; then
  echo "[$PROG_NAME:$XS_STATE:Output] File '$JPGFILE' has mirror name $NEWFILENAME."
  #echo "$NEWFILENAME"
fi

# Handle over content to calling program:
if [ -w "$IMAGEVIEWERTMPFILE" ] ; then
  echo "IMAGEVIEWERWIDTH=$WIDTH" > "$IMAGEVIEWERTMPFILE"
  echo "IMAGEVIEWERHEIGHT=$HEIGHT" >> "$IMAGEVIEWERTMPFILE"
  echo "IMAGEVIEWERTHUMB=\"$THUMBNAME\"" >> "$IMAGEVIEWERTMPFILE"
  echo "IMAGEVIEWERCAMERA=\"$CAMERA\"" >> "$IMAGEVIEWERTMPFILE"
  echo "IMAGEVIEWERUUID=\"$UUID\"" >> "$IMAGEVIEWERTMPFILE"
  echo "IMAGEVIEWERDATETIME=\"$DATETIME\"" >> "$IMAGEVIEWERTMPFILE"
fi
