#!/bin/bash

# #########################################
#
# Versions
#
# 2016-05-17 0.01 kdk First Ideas
# 2017-11-12 0.02 kdk Going on quik and dirty
# 2017-11-18 0.03 kdk Going on
# 2017-11-23 0.04 kdk and on
# 2018-02-16 0.05 kdk With ECHODEBUG, ...
# 2018-02-17 0.06 kdk CheckSettings enhanced
# 2018-02-25 0.07 kdk With PDF
# 2018-03-02 0.08 kdk source
# 2018-03-04 0.09 kdk realpath + UUIDFILE
# 2018-03-12 0.10 kdk Changed from SettingsFile to SETTINGSFILE
# 2018-03-17 0.11 kdk With ALBUMFILE
# 2018-03-18 0.12 kdk With Documentation to collection of albumfiles.
# 2018-04-05 0.13 kdk With Include
# 2018-04-06 0.14 kdk With two Includes
# 2018-05-21 0.15 kdk Include file extension changed from inc to bash, with
#                     license text.
# 2021-03-26 0.16 kdk Bug fixing
# 2022-02-13 0.17 kdk showHelp() enhanced with '-r', FULLHDFOLDER support added
# 2022-02-22 0.18 kdk fileSize() added
# 2022-02-23 0.19 kdk FullHD: Only resize if greater. FileSize() tested
# 2022-02-23 0.20 kdk after ShellCheck
# 2022-02-24 0.21 kdk Comments deleted and other added, support for image_viewer_find_doubles.sh added - not yet tested
# 2024-04-01 0.22 kdk Support alternative settings

PROG_NAME="html_collect_pictures"
PROG_VERSION="0.22"
PROG_DATE="2024-04-01"
PROG_CLASS="ImageViewer"
PROG_SCRIPTNAME="html_collect_pictures.sh"

# #########################################
#
# MIT license (MIT)
#
# Copyright 2024 - 2018 Karsten Köth
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
# Notes
#
# Store settings under: /Users/koeth/.imageviewer
#
# Start program with: html_collect_pictures.sh *
#    or
#                     html_collect_pictures.sh .
#

# #########################################
#
# Limitations
#
# Only pictures greater 320x320 will be inserted into the DATABASEFILE.
#

# #########################################
#
# User Stories
#
# Ich möchte alle Bilder als Thumbs in einem Ordner sehen.                      DONE
# Ich möchte die Bilder auf einer html Seite sehen.                             DONE
# Ich möchte alle Bilder von allen Laufwerken (von Windows als rießen USB-Stick DONE
#     mit "kopieren mit integrieren".) immer wieder sammeln ohne Dubletten zu
#     erzeugen.
# Ich möchte Bilder mit doppelten Ablageorten finden.
# Ich möchte Alben zusammen stellen können.
# Ich möchte einfach Bilder exportieren.
# Ich möchte Bilder rotieren können.

# #########################################
#
# Specifications
#
# UUID stellt Beziehung zwischen Thumb und Speicherplatz des Originalbildes her.
# Bilder nicht mehrfach scannen:
# Ist Bildname mit Speicherplatz und gleicher 
#     WIDTH + HEIGHT + DATE + CAMERA + FILESIZE    <== Fünf wichtige Eigenschaften eines Bildes!
# schon in Datenbank?
#
# Datenbanken:
#
# DATABASEFILE
# Enthält alle Infos über die Originaldatei bis auf die UUID. Dadurch kann in
# der Datenbank einfach gesucht werden, ob Datei schon aufgenommen wurde.
# echo "$FULLFILENAME;$IMAGEVIEWERFILENAME;$IMAGEVIEWERDATETIME;$IMAGEVIEWERWIDTH;$IMAGEVIEWERHEIGHT;$IMAGEVIEWERCAMERA;$IMAGEVIEWERSIZE" >> "$DATABASEFILE"
# Get one field with 'cut', e.g. :>  echo $DATABASEFILE | cut -d ";" -f 1 --> Get $FULLFILENAME
#  1  $FULLFILENAME
#  2  $IMAGEVIEWERFILENAME
#  3  $IMAGEVIEWERDATETIME
#  4  $IMAGEVIEWERWIDTH
#  5  $IMAGEVIEWERHEIGHT
#  6  $IMAGEVIEWERCAMERA
#  7  $IMAGEVIEWERSIZE
#
# THUMBNAILFOLDER
# Enthält alle Thumbnails. Diese enthalten: $DATETIME.$UUID.$WIDTH"x"$HEIGHT.$CAMERA.THUMB.$FILENAME
# Thumbnails sind immer im PNG-Format.
#
# FULLHDFOLDER
# Enthält alle Bilder in FullHD Auflösung oder kleiner, falls keine FullHD 
# Auflösung existiert. Der Dateiname ist gleich dem der Thumbnails.
# FullHD Bilder sind immer im JPEG-Format.
#
# UUIDFILE
# Enthält Verknüpfung zwischen UUID und FULLFILENAME
# Ohne folgendes Semikolon!
# UUID hat feste Feldlänge --> Rest der Zeile ist Dateiname mit Leerzeichen
# und Path.
# UUID;FULLFILENAME
#
# ALBUMFILE
# Contains the names of all Albums created.
# Every name corresponds to one uppercase letter. The letter is the shortcut
# for the album name.
# The lines must not sorted alphabetically.
# Not all possible uppercase letters must be included.
# If an album name should be changed, the line must be appended to the file.
# Therefore we are mutli thread save. Only the last occurence of the shortcuts
# counts.
# The format of the file is: uppercase letter followed by a semicolon followed
# by the album name. The album name starts always at character position "2".
# The first position is "0".
# A;Aaron
# B;
# L;Lukas
# K;Karsten
#
# LOGFILE
# Contains some logs in unstructured file format.
#
# FILEPOINTERFILE
# Contains line number in DATABASEFILE with first new line.
# Normally, one run of html_collect_pictures.sh should be followed by one run of
# image_viewer_find_doubles.sh. But maybe, the run order will not be noticed.
# Therefore the collect script add the line number to this file.
# If the find script was successfully finished, this file will be deleted.
#
# Collection of Album Files
# Every Album file contains the UUIDs of the images inserted into this album.
# One UUID per line.
# The name of every album file starts with $ALBUMPREFIX and ends with
# $ALBUMPOSTFIX. Between pre and postfix, there is the uppercase letter of this
# specific album. E.g. if the album shortcut is stored in $1:
# filename="$ALBUMPREFIX$1$ALBUMPOSTFIX"
#
# MIRRORFOLDER
# Enthält von ausgewählten Bildern das Originalbild, allerdings mit Dateiname:
# $UUID.jpg
# $UUID.png
# $UUID.tiff
# $UUID.pdf
# ...

# TODO: Fehlermeldungen in Error.log vermerken.

# #########################################
#
# Needed programs:
#
# exiftool
# exif2html.sh
# realpath (must be installed with brew: brew install coreutils)
#   PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
#   MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"

# #########################################
#
# Variables
#

# See include

# #########################################
#
# Constants
#


# #########################################
#
# Includes
#
# Will be read once on start of the program:

source image_viewer_common_vars.bash


RECURSIVE="0"

# #########################################
#
# Functions
#

source image_viewer_common_func.bash

# #########################################
# fileSize()
# Parameter
#   1: file name
# Return
#   File size in Bytes
# Function first used inside AssetHub Usage Scripts (MIT License)
# Tested at:
# "17.7.0" = MAC OS X High Sierra 10.13.6
# SUSE Linux Enterprise Server 15 SP1
# Copied from bashutils - bashutils_common_functions.bash - Version 0.26
function fileSize()
{
    if [ -f "$1" ] ; then
        # Get file size
        # tSize=$(wc -c "$1" | cut -d " " -f 1 -) # Too unsecure, sometimes more " " before the first value.
        # tSize=$(ls -l "$1" | cut -d " " -f 5 -)  # Too unsecure, sometimes more " " between values.
        tSize=$(wc -c "$1" | awk '{print $1}')
        echo "$tSize"
    fi
}

# #########################################
# CheckSettings
# Only run function if file is present.
# Change global settings according ot settings file.
#
function CheckSettings()
{
  echod "CheckSettings" "Start ..."

  # #####
  # First check the folders...

  # Only if there is the option in the configuration file: change the global
  # variable:
  # First, I have to test if the settings file exists and is readable:
  if [ -r "$1" ] ; then
    TMPCONF=$(grep DATABASEFOLDER "$1")
  else
    TMPCONF=""
  fi
  if [ -n "$TMPCONF" ] ; then
    # The option is configured. Get the new content and test it:
    TMPCONF=$(echo "$TMPCONF" | cut -d = -f 2)
    echod "CheckSettings:DATABASEFOLDER" "TMPCONF=\"$TMPCONF\""
    if [ ! -d "$TMPCONF" ] ; then
      # Try to create dir:
      mkdir -p "$TMPCONF"
    fi
    if [ -d "$TMPCONF" ] ; then
      # Directory exists
      # Could we write into it?
      TMPFILE=$(mktemp "$TMPCONF"/test.XXXXXXXXX)
      if [ -e "$TMPFILE" ] ; then
        rm "$TMPFILE"
        DATABASEFOLDER="$TMPCONF"
        # all ok, adapt filenames:
        DATABASEFILE="$DATABASEFOLDER/pictures.csv"
        UUIDFILE="$DATABASEFOLDER/filenames.csv"
        ALBUMFILE="$DATABASEFOLDER/albumnames.csv"
        ALBUMPREFIX="$DATABASEFOLDER/album_"
        ALBUMPOSTFIX=".csv"
        LOGFILE="$DATABASEFOLDER/log.txt"
        FILEPOINTERFILE="$DATABASEFOLDER/filepointer.txt"
      else
        # directory exists but not useable:
        echow "CheckSettings:DATABASEFOLDER" "Can't use configured database folder. Try to use default one."
        CheckDatabaseFolder
      fi
    else
      # Directory from settings file did not exists.
      # Try to use default directory:
      CheckDatabaseFolder
    fi
  else
    # The option is not configured.
    # I should create the directory if it does not exists.
    echod "CheckSettings:DATABASEFOLDER:Default" "Test presence ..."
    if [ ! -d "$DATABASEFOLDER" ] ; then
      # Try to create dir:
      echod "CheckSettings:DATABASEFOLDER:Default" "Try to create folder ..."
      mkdir -p "$DATABASEFOLDER"
    fi
    if [ -d "$DATABASEFOLDER" ] ; then
      # Directory exists
      echod "CheckSettings:DATABASEFOLDER:Default" "Folder exists."
      # Could we write into it?
      TMPFILE=$(mktemp "$DATABASEFOLDER"/test.XXXXXXXXX)
      if [ -e "$TMPFILE" ] ; then
        rm "$TMPFILE"
        # all ok, next settings
        echod "CheckSettings:DATABASEFOLDER:Default" "Folder useable."
      else
        # directory exists but not useable:
        echoe "CheckSettings:DATABASEFOLDER" "Can't use default database folder. Exit."
        exit
      fi
    fi
  fi

  if [ -r "$1" ] ; then
    TMPCONF=$(grep THUMBNAILFOLDER "$1")
  else
    TMPCONF=""
  fi
  if [ -n "$TMPCONF" ] ; then
    # The option is configured. Get the new content and test it:
    TMPCONF=$(echo "$TMPCONF" | cut -d = -f 2)
    echod "CheckSettings:THUMBNAILFOLDER" "TMPCONF=\"$TMPCONF\""
    if [ ! -d "$TMPCONF" ] ; then
      # Try to create dir:
      mkdir -p "$TMPCONF"
    fi
    if [ -d "$TMPCONF" ] ; then
      # Directory exists
      # Could we write into it?
      TMPFILE=$(mktemp "$TMPCONF"/test.XXXXXXXXX)
      if [ -e "$TMPFILE" ] ; then
        rm "$TMPFILE"
        THUMBNAILFOLDER="$TMPCONF"
        # all ok, next settings
      else
        # directory exists but not useable:
        echow "CheckSettings:THUMBNAILFOLDER" "Can't use configured thumbnail folder. Try to use default one."
        CheckThumbnailFolder
      fi
    else
      # Directory from settings file did not exists.
      # Try to use default directory:
      CheckThumbnailFolder
    fi
  else
    # The option is not configured.
    # I should create the directory if it does not exists.
    if [ ! -d "$THUMBNAILFOLDER" ] ; then
      # Try to create dir:
      mkdir -p "$THUMBNAILFOLDER"
    fi
    if [ -d "$THUMBNAILFOLDER" ] ; then
      # Directory exists
      # Could we write into it?
      TMPFILE=$(mktemp "$THUMBNAILFOLDER"/test.XXXXXXXXX)
      if [ -e "$TMPFILE" ] ; then
        rm "$TMPFILE"
        # all ok, next settings
      else
        # directory exists but not useable:
        echoe "CheckSettings:THUMBNAILFOLDER" "Can't use default thumbnail folder. Exit."
        exit
      fi
    fi
  fi

  if [ -r "$1" ] ; then
    TMPCONF=$(grep FULLHDFOLDER "$1")
  else
    TMPCONF=""
  fi
  if [ -n "$TMPCONF" ] ; then
    # The option is configured. Get the new content and test it:
    TMPCONF=$(echo "$TMPCONF" | cut -d = -f 2)
    echod "CheckSettings:FULLHDFOLDER" "TMPCONF=\"$TMPCONF\""
    if [ ! -d "$TMPCONF" ] ; then
      # Try to create dir:
      mkdir -p "$TMPCONF"
    fi
    if [ -d "$TMPCONF" ] ; then
      # Directory exists
      # Could we write into it?
      TMPFILE=$(mktemp "$TMPCONF"/test.XXXXXXXXX)
      if [ -e "$TMPFILE" ] ; then
        rm "$TMPFILE"
        FULLHDFOLDER="$TMPCONF"
        # all ok, next settings
      else
        # directory exists but not useable:
        echow "CheckSettings:FULLHDFOLDER" "Can't use configured Full HD folder. Try to use default one."
        CheckFullHDFolder
      fi
    else
      # Directory from settings file did not exists.
      # Try to use default directory:
      CheckFullHDFolder
    fi
  else
    # The option is not configured.
    # I should create the directory if it does not exists.
    if [ ! -d "$FULLHDFOLDER" ] ; then
      # Try to create dir:
      mkdir -p "$FULLHDFOLDER"
    fi
    if [ -d "$FULLHDFOLDER" ] ; then
      # Directory exists
      # Could we write into it?
      TMPFILE=$(mktemp "$FULLHDFOLDER"/test.XXXXXXXXX)
      if [ -e "$TMPFILE" ] ; then
        rm "$TMPFILE"
        # all ok, next settings
      else
        # directory exists but not useable:
        echoe "CheckSettings:FULLHDFOLDER" "Can't use default FULL HD folder. Exit."
        exit
      fi
    fi
  fi

  if [ -r "$1" ] ; then
    TMPCONF=$(grep EXPORTFOLDER "$1")
  else
    TMPCONF=""
  fi
  if [ -n "$TMPCONF" ] ; then
    # The option is configured. Get the new content and test it:
    TMPCONF=$(echo "$TMPCONF" | cut -d = -f 2)
    echod "CheckSettings:EXPORTFOLDER" "TMPCONF=\"$TMPCONF\""
    if [ ! -d "$TMPCONF" ] ; then
      # Try to create dir:
      mkdir -p "$TMPCONF"
    fi
    if [ -d "$TMPCONF" ] ; then
      # Directory exists
      # Could we write into it?
      TMPFILE=$(mktemp "$TMPCONF"/test.XXXXXXXXX)
      if [ -e "$TMPFILE" ] ; then
        rm "$TMPFILE"
        EXPORTFOLDER="$TMPCONF"
        # all ok, adjust settings:
        EXPORTBASHSCRIPT="$EXPORTFOLDER/image_viewer_export.sh" # Will be created by image_viewer_server.sh
      else
        # directory exists but not useable:
        echow "CheckSettings:EXPORTFOLDER" "Can't use configured export folder. Try to use default one."
        CheckExportFolder
      fi
    else
      # Directory from settings file did not exists.
      # Try to use default directory:
      CheckExportFolder
    fi
  else
    # The option is not configured.
    # I should create the directory if it does not exists.
    if [ ! -d "$EXPORTFOLDER" ] ; then
      # Try to create dir:
      mkdir -p "$EXPORTFOLDER"
    fi
    if [ -d "$EXPORTFOLDER" ] ; then
      # Directory exists
      # Could we write into it?
      TMPFILE=$(mktemp "$EXPORTFOLDER"/test.XXXXXXXXX)
      if [ -e "$TMPFILE" ] ; then
        rm "$TMPFILE"
        # all ok, next settings
      else
        # directory exists but not useable:
        echoe "CheckSettings:EXPORTFOLDER" "Can't use default export folder. Exit."
        exit
      fi
    fi
  fi

  # #####
  # Second, check the files.

  if [ -r "$1" ] ; then
    TMPCONF=$(grep DATABASEFILE "$1")
  else
    TMPCONF=""
  fi
  if [ -n "$TMPCONF" ] ; then
    # The option is configured. Get the new content and test it:
    TMPCONF=$(echo "$TMPCONF" | cut -d = -f 2)
    echod "CheckSettings:DATABASEFILE" "TMPCONF=\"$TMPCONF\""
    if [ -n "$TMPCONF" ] ; then
      if [ ! -e "$TMPCONF" ] ; then
        echod "CheckSettings:DATABASEFILE:Configured" "Create file..."
        touch "$TMPCONF"
      fi
      if [ -w "$TMPCONF" ] ; then
        # All ok, use it:
        DATABASEFILE="$TMPCONF"
      else
        echow "CheckSettings:DATABASEFILE" "Can't write to configured database file. Try to use default one."
        TMPCONF=""
      fi
    fi
  fi
  if [ ! -n "$TMPCONF" ] ; then
    # Default file name.
    if [ ! -e "$DATABASEFILE" ] ; then
      echod "CheckSettings:DATABASEFILE:Default" "Create file..."
      touch "$DATABASEFILE"
    fi
    if [ ! -w "$DATABASEFILE" ] ; then
      echoe "CheckSettings:DATABASEFILE" "Can't use default database file. Exit."
      exit
    fi
  fi

  if [ -r "$1" ] ; then
    TMPCONF=$(grep UUIDFILE "$1")
  else
    TMPCONF=""
  fi
  if [ -n "$TMPCONF" ] ; then
    # The option is configured. Get the new content and test it:
    TMPCONF=$(echo "$TMPCONF" | cut -d = -f 2)
    echod "CheckSettings:UUIDFILE" "TMPCONF=\"$TMPCONF\""
    if [ -n "$TMPCONF" ] ; then
      if [ ! -e "$TMPCONF" ] ; then
        echod "CheckSettings:UUIDFILE:Configured" "Create file..."
        touch "$TMPCONF"
      fi
      if [ -w "$TMPCONF" ] ; then
        # All ok, use it:
        UUIDFILE="$TMPCONF"
      else
        echow "CheckSettings:UUIDFILE" "Can't write to configured uuid file. Try to use default one."
        TMPCONF=""
      fi
    fi
  fi
  if [ ! -n "$TMPCONF" ] ; then
    # Default file name.
    if [ ! -e "$UUIDFILE" ] ; then
      echod "CheckSettings:UUIDFILE:Default" "Create file..."
      touch "$UUIDFILE"
    fi
    if [ ! -w "$UUIDFILE" ] ; then
      echoe "CheckSettings:UUIDFILE" "Can't use default uuid file. Exit."
      exit
    fi
  fi

  if [ -r "$1" ] ; then
    TMPCONF=$(grep ALBUMFILE "$1")
  else
    TMPCONF=""
  fi
  if [ -n "$TMPCONF" ] ; then
    # The option is configured. Get the new content and test it:
    TMPCONF=$(echo "$TMPCONF" | cut -d = -f 2)
    echod "CheckSettings:ALBUMFILE" "TMPCONF=\"$TMPCONF\""
    if [ -n "$TMPCONF" ] ; then
      if [ ! -e "$TMPCONF" ] ; then
        echod "CheckSettings:ALBUMFILE:Configured" "Create file..."
        touch "$TMPCONF"
      fi
      if [ -w "$TMPCONF" ] ; then
        # All ok, use it:
        ALBUMFILE="$TMPCONF"
        ALBUMPREFIX="$DATABASEFOLDER/album_"
        ALBUMPOSTFIX=".csv"
      else
        echow "CheckSettings:ALBUMFILE" "Can't write to configured album file. Try to use default one."
        TMPCONF=""
      fi
    fi
  fi
  if [ ! -n "$TMPCONF" ] ; then
    # Default file name.
    if [ ! -e "$ALBUMFILE" ] ; then
      echod "CheckSettings:ALBUMFILE:Default" "Create file..."
      touch "$ALBUMFILE"
    fi
    if [ ! -w "$ALBUMFILE" ] ; then
      echoe "CheckSettings:ALBUMFILE" "Can't use default album file. Exit."
      exit
    fi
  fi

  # Next settings ...
}

# #########################################
# CheckDatabaseFolder
#
function CheckDatabaseFolder()
{
  if [ -d "$DATABASEFOLDER" ] ; then
    # Directory exists
    # Could we write into it?
    TMPFILE=$(mktemp "$DATABASEFOLDER"/test.XXXXXXXXX)
    if [ -e "$TMPFILE" ] ; then
      rm "$TMPFILE"
      # We could use folder.
      return
    else
      echoe "CheckDatabaseFolder" "Can't use default database folder. Exit."
      exit
    fi
  else
    echoe "CheckDatabaseFolder" "Default database folder didn't exists. Exit."
    exit
  fi
}

# #########################################
# CheckThumbnailFolder
#
function CheckThumbnailFolder()
{
  if [ -d "$THUMBNAILFOLDER" ] ; then
    # Directory exists
    # Could we write into it?
    TMPFILE=$(mktemp "$THUMBNAILFOLDER"/test.XXXXXXXXX)
    if [ -e "$TMPFILE" ] ; then
      rm "$TMPFILE"
      # We could use folder.
      return
    else
      echoe "CheckThumbnailFolder" "Can't use default thumbnail folder. Exit."
      exit
    fi
  else
    echoe "CheckThumbnailFolder" "Default thumbnail folder didn't exists. Exit."
    exit
  fi
}

# #########################################
# CheckFullHDFolder
#
function CheckFullHDFolder()
{
  if [ -d "$FULLHDFOLDER" ] ; then
    # Directory exists
    # Could we write into it?
    TMPFILE=$(mktemp "$FULLHDFOLDER"/test.XXXXXXXXX)
    if [ -e "$TMPFILE" ] ; then
      rm "$TMPFILE"
      # We could use folder.
      return
    else
      echoe "CheckFullHDFolder" "Can't use default Full HD folder. Exit."
      exit
    fi
  else
    echoe "CheckFullHDFolder" "Default Full HD folder didn't exists. Exit."
    exit
  fi
}

# #########################################
# CheckExportFolder
#
function CheckExportFolder()
{
  if [ -d "$EXPORTFOLDER" ] ; then
    # Directory exists
    # Could we write into it?
    TMPFILE=$(mktemp "$EXPORTFOLDER"/test.XXXXXXXXX)
    if [ -e "$TMPFILE" ] ; then
      rm "$TMPFILE"
      # We could use folder.
      return
    else
      echoe "CheckExportFolder" "Can't use default export folder. Exit."
      exit
    fi
  else
    echoe "CheckExportFolder" "Default export folder didn't exists. Exit."
    exit
  fi
}

# #########################################
# DebugSettings
# Show all Settings.
function DebugSettings()
{
  echod "DebugSettings" "DATABASEFOLDER=$DATABASEFOLDER"
  echod "DebugSettings" "DATABASEFILE=$DATABASEFILE"
  echod "DebugSettings" "UUIDFILE=$UUIDFILE"
  #echod "DebugSettings" "ALBUMFILE=$ALBUMFILE" # The ALBUMFILE will not be used in this script.
  echod "DebugSettings" "THUMBNAILFOLDER=$THUMBNAILFOLDER"
  echod "DebugSettings" "FULLHDFOLDER=$FULLHDFOLDER"
  echod "DebugSettings" "EXPORTFOLDER=$EXPORTFOLDER"
  echod "DebugSettings" "SETTINGSFILE=$SETTINGSFILE"
}

# #########################################
# DebugProgParams
# Show all Settings.
#function DebugProgParams()
# {
#  echo "[$PROG_NAME:DebugProgParams] verzeichnis=$verzeichnis"
# }

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
    echo "    -d     : Debug output on."
    echo "    -v     : Verbose output on."
    echo "    -w     : Warning output on."
    echo "    -e     : Error output on."
    echo "    -q     : Normal output off. Be quiet. Show only warnings and errors."
    echo "    -Q     : Be absolute quit. Show nothing."
    echo "    -r     : Start in recursive mode (should not be set by user)."
    echo "   ....    : '....' is folder to scan. Must be the last program parameter."
    echo ""
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

# ##############################################################################
#
# Main
#

# Check program parameter:
if [ $# -gt 0 ] ; then
  echod "Main:Program Parameter" "Scanning program parameters ..."
  for param in $@
  do
      echod "Main:Program Parameter:Scan" "$param"
      if [ "$param" = "-d" ] ; then
        ECHODEBUG="1"
        ECHOVERBOSE="1"
        ECHOWARNING="1"
        ECHOERROR="1"
        echod "Main:Program Parameter:Scan" "Debug output on."
      fi
      if [ "$param" = "-v" ] ; then
        ECHOVERBOSE="1"
        ECHOWARNING="1"
        ECHOERROR="1"
        echod "Main:Program Parameter:Scan" "Verbose output on."
      fi
      if [ "$param" = "-w" ] ; then
        ECHOWARNING="1"
        ECHOERROR="1"
        echod "Main:Program Parameter:Scan" "Warning output on."
      fi
      if [ "$param" = "-e" ] ; then
        ECHOERROR="1"
        echod "Main:Program Parameter:Scan" "Error output on."
      fi
      if [ "$param" = "-q" ] ; then
        ECHONORMAL="0"
        echod "Main:Program Parameter:Scan" "Normal output off. Be quiet."
      fi
      if [ "$param" = "-Q" ] ; then
        ECHODEBUG="0"
        ECHOVERBOSE="0"
        ECHONORMAL="0"
        ECHOWARNING="0"
        ECHOERROR="0"
        echod "Main:Program Parameter:Scan" "Be absolute quiet."
      fi
      if [ "$param" = "-r" ] ; then
        RECURSIVE="1"
        echod "Main:Program Parameter:Scan" "In recursive execution ..."
      fi
      if [ "$param" = "-h" ] ; then
        showHelp ; exit;
      fi
      if [ "$param" = "-V" ] ; then
        showVersion ; exit;
      fi
  done
fi

if [ "$RECURSIVE" = "0" ] ; then
  # Check Settings:
  if [ -e "$SETTINGSFILE" ] ; then
    # Check, if some settings are stored in the file:
    CheckSettings "$SETTINGSFILE"
  else
    # The file did not exists, but the standard tests should be done:
    CheckSettings "-#FileNotReallyThere."
  fi

  # Remember the first new line we will write into the database.
  # This helps image_viewer_find_doubles to not scan all files again.
  FirstNewLine=$(cat "$DATABASEFILE" | wc -l | sed 's/^[ ]* \(.*\)/\1/') # sed removes the trailing spaces
  echo "$FirstNewLine" >> "$FILEPOINTERFILE"

  echod "Main:RECURSIVE" "Prepare for recursive execution ..."
  # Set settings for recursive execution:
  export IMAGEVIEWERDATABASEFOLDER="$DATABASEFOLDER"
  export IMAGEVIEWERDATABASEFILE="$DATABASEFILE"
  export IMAGEVIEWERUUIDFILE="$UUIDFILE"
  export IMAGEVIEWERTHUMBNAILFOLDER="$THUMBNAILFOLDER"
  export IMAGEVIEWERFULLHDFOLDER="$FULLHDFOLDER"
  export IMAGEVIEWEREXPORTFOLDER="$EXPORTFOLDER"
  export IMAGEVIEWERECHODEBUG="$ECHODEBUG"
  export IMAGEVIEWERECHOVERBOSE="$ECHOVERBOSE"
  export IMAGEVIEWERECHONORMAL="$ECHONORMAL"
else
  # Settings were checked in first instance of shell.
  echod "Main:RECURSIVE" "In recursive execution. Set variables..."
  DATABASEFOLDER="$IMAGEVIEWERDATABASEFOLDER"
  DATABASEFILE="$IMAGEVIEWERDATABASEFILE"
  UUIDFILE="$IMAGEVIEWERUUIDFILE"
  THUMBNAILFOLDER="$IMAGEVIEWERTHUMBNAILFOLDER"
  FULLHDFOLDER="$IMAGEVIEWERFULLHDFOLDER"
  EXPORTFOLDER="$IMAGEVIEWEREXPORTFOLDER"
  ECHODEBUG="$IMAGEVIEWERECHODEBUG"
  ECHOVERBOSE="$IMAGEVIEWERECHOVERBOSE"
  ECHONORMAL="$IMAGEVIEWERECHONORMAL"
fi

# array delimiter not spaces:
OLDIFS=$IFS
IFS=$(echo -en "\n\b")

if [ "$ECHODEBUG" = "1" ] ; then
  DebugSettings
  #DebugProgParams # obsolete
fi

# Der abgelegte Dateiname sollte immer absolut sein.
#   --> Wird erledigt: s.u. bei realpath.

# "." sollte als Parameter erlaubt sein, wenn keine Rekursive ausführung ist.
#   --> Funktioniert - warum auch immer. Aber getestet.

for datei in $@
do
  echod "Main" "$datei"
  if [ "$datei" = "-d" ] || \
     [ "$datei" = "-v" ] || \
     [ "$datei" = "-w" ] || \
     [ "$datei" = "-e" ] || \
     [ "$datei" = "-q" ] || \
     [ "$datei" = "-r" ] ; then
    # Only program parameter
    echod "Main:Parse" "Program parameter, no file or folder. Skip."
  else
    # $datei zerlegen in pfad und rest:
    PART=$(basename "$datei")
    if [ -d "$datei" ] ; then
      # Directory: Only walk down the tree:
      if [ "$PART" != "." ] && [ "$PART" != ".." ]
      then
        #recursion
        IFS=$OLDIFS
        echod "Main:Start recursion" "$datei"
        $0 -r "$datei"/*
      fi
      if [ "$PART" = "." ] && [ "$datei" = "." ] && [ "$RECURSIVE" = "0" ]
      then
        # Start first recursion:
        IFS=$OLDIFS
        echod "Main:Start first recursion" "."
        #$0 -r `pwd`/*    # Version 0.19 and prior, tested
        $0 -r "$(pwd)"/*  # Changed by Version 0.19 --> 0.20, untested
      fi
    else
      # Normal file.
      # Is readable?
      if [ ! -r "$datei" ] || [ ! -s "$datei" ] ; then
        echow "Main:File" "File $datei not readable or has size zero. Skip."
      else
        # Get mime type ...
        MIMETYPE=$(file --mime-type --separator ";" "$datei" | cut -d ";" -f 2 )
        echod "Main:MimeType" ">$MIMETYPE<"
        # Get file size ...
        IMAGEVIEWERSIZE=$(fileSize "$datei")
        echod "Main:FileSize" "$IMAGEVIEWERSIZE Bytes"

        # #########################################
        # Is Picture?
        if [ "$MIMETYPE" = " image/png" ] || \
           [ "$MIMETYPE" = " image/jpeg" ] || \
           [ "$MIMETYPE" = " image/tiff" ]
        then
          MIMEKNOWN="1"
          echod "Main:MimeType" "Is Image."
          export IMAGEVIEWERWIDTH="0"
          export IMAGEVIEWERHEIGHT="0"
          export IMAGEVIEWERTHUMB=""
          export IMAGEVIEWERFULLHD=""
          export IMAGEVIEWERFILENAME="$PART"
          # Create file to get variables from exif2html.sh:
          IMAGEVIEWERTMPFILE=$(mktemp .$PROG_NAME.Return.XXXXXXXXX)
          export IMAGEVIEWERTMPFILE
          # Run exif2html.sh "$FULLPATH" #>> "$DATABASEFILE"
          exif2html.sh "$datei"
          # Get variables from exif2html.sh:
          source "$IMAGEVIEWERTMPFILE"
          # Delete tmp file:
          rm "$IMAGEVIEWERTMPFILE"
          echod "Main:exif2html" "Image: $IMAGEVIEWERWIDTH x $IMAGEVIEWERHEIGHT = $IMAGEVIEWERTHUMB"
          # uuidgen für THUMBNAME wird in exif2html erledigt.
          if [ "$IMAGEVIEWERWIDTH" != "0" ] && \
             [ "$IMAGEVIEWERHEIGHT" != "0" ] && \
             [ -n "$IMAGEVIEWERTHUMB" ] ; then
            echod "Main:Thumbnail" "Image has dimension."
            # Thumb nur anlegen, wenn Bild größer gleich 320x320 ist:
            if [ "$IMAGEVIEWERWIDTH" -ge "320" ] && [ "$IMAGEVIEWERHEIGHT" -ge "320" ] ; then
              # Resize to small image:
              # convert Glasfront_filtered.png -resize 320 Glasfront_klein.png
              # biggest dimension of new image is 320 pixel.
              # Datei nur anlegen, wenn noch nicht angelegt. Dafür zuerst
              # kompletten Pfad ermitteln:
              FULLFILENAME=$(realpath "$datei")
              # #########################################
              # Example:
              # TODO: ... $IMAGEVIEWERLOCATION could be inserted additionally
              TMPSTRING="$FULLFILENAME;$IMAGEVIEWERFILENAME;$IMAGEVIEWERDATETIME;$IMAGEVIEWERWIDTH;$IMAGEVIEWERHEIGHT;$IMAGEVIEWERCAMERA;$IMAGEVIEWERSIZE;"
              # do we have scanned the picture in a previous scan?
              TMPRESULT=$(grep "$TMPSTRING" "$DATABASEFILE")
              if [ "$TMPRESULT" = "$TMPSTRING" ] ; then
                echod "Main:Exists" "Image exists in database. Skip."
              else
                echod "Main:Exists" "Insert new image into database."
                echo "$TMPSTRING" >> "$DATABASEFILE"
                echo "$IMAGEVIEWERUUID;$FULLFILENAME" >> "$UUIDFILE"
                # Ich will nur pngs als Thumb haben!
                convert "$datei" -resize 320x320 "$THUMBNAILFOLDER"/"$IMAGEVIEWERTHUMB".png
                if [ "$IMAGEVIEWERWIDTH" -gt "1920" ] || [ "$IMAGEVIEWERHEIGHT" -gt "1080" ] ; then
                  convert "$datei" -resize 1920x1080 "$FULLHDFOLDER"/"$IMAGEVIEWERFULLHD".jpeg 
                else
                  # Copy complete file as file for FullHD Presentations. We only want to have jpegs:
                  if [ "$MIMETYPE" = " image/jpeg" ] ; then
                    cp "$datei" "$FULLHDFOLDER"/"$IMAGEVIEWERFULLHD".jpeg
                  else
                    convert "$datei" "$FULLHDFOLDER"/"$IMAGEVIEWERFULLHD".jpeg
                  fi
                fi
              fi
            fi
          fi
        fi

        # #########################################
        if [ "$MIMETYPE" = " application/pdf" ]
        then
          MIMEKNOWN="1"
          echod "Main:MimeType" "Is PDF."
          echol "Main:MimeType" "File '$datei' is PDF. Unsupported"
          # TODO: Aus PDF Daten auslesen:
          # pdfinfo -isodates "$datei"
          # CreationDate:   2012-05-03T10:29:02+02
          # Page size:      1689.45 x 2386.77 pts
          #       Aus PDF ein Screen Shot erstellen. --> 1080 hoch
          #       Und Thumbnail erstellen
          # convert poster__03052012.pdf -resize 320x320 poster_thumbB.png
          # convert "$datei" -resize 320x320 "$THUMBNAILFOLDER"/pdfthumb."$PART.png"
        fi

        # TODO html als png ablegen

        # TODO andere File types in excluded log datei vermerken mit vollen Pfad.
        # Run exif2html.sh "$FULLPATH" >> "$DATABASEFILE"
        if [ "$MIMEKNOWN" != "1" ] ; then
          echod "Main:MimeType" "Mime Type '$MIMETYPE' unknown"
          echol "Main:MimeType" "Mime Type '$MIMETYPE' unknown in '$datei'"
        fi

        # One line per file found.
        #IFS=$OLDIFS
        echon "Main:Done" "$datei"
      fi
    fi
  fi
done

# reset array delimiter:
IFS=$OLDIFS
