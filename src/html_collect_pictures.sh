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
# Ist Bildname mit Speicherplatz und gleicher WIDTH + HEIGHT + DATE + CAMERA     <== Vier wichtige Eigenschaften eines Bildes!
# schon in Datenbank?
#
# Datenbanken:
#
# DATABASEFILE
# Enthält alle Infos über die Originaldatei bis auf die UUID. Dadurch kann in
# der Datenbank einfach gesucht werden, ob Datei schon aufgenommen wurde.
# echo "$FULLFILENAME;$IMAGEVIEWERFILENAME;$IMAGEVIEWERDATETIME;$IMAGEVIEWERWIDTH;$IMAGEVIEWERHEIGHT;$IMAGEVIEWERCAMERA;" >> "$DATABASEFILE"
#
# THUMBNAILFOLDER
# Enthält alle Thumbnails. Diese enthalten: $DATETIME.$UUID.$WIDTH"x"$HEIGHT.$CAMERA.THUMB.$FILENAME
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

PROG_NAME="html_collect_pictures"


# #########################################
#
# Includes
#
# Will be read once on start of the program:

source image_viewer_common_vars.bash


RECURSIVE="0"


SETTINGSFILE="$HOME/.imageviewer"

# #########################################
#
# Functions
#

source image_viewer_common_func.bash

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
    TMPCONF=`echo "$TMPCONF" | cut -d = -f 2`
    echod "CheckSettings:DATABASEFOLDER" "TMPCONF=\"$TMPCONF\""
    if [ ! -d "$TMPCONF" ] ; then
      # Try to create dir:
      mkdir -p "$TMPCONF"
    fi
    if [ -d "$TMPCONF" ] ; then
      # Directory exists
      # Could we write into it?
      TMPFILE=`mktemp "$TMPCONF"/test.XXXXXXXXX`
      if [ -e "$TMPFILE" ] ; then
        rm "$TMPFILE"
        DATABASEFOLDER="$TMPCONF"
        # all ok, next settings
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
      TMPFILE=`mktemp "$DATABASEFOLDER"/test.XXXXXXXXX`
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
    TMPCONF=`echo "$TMPCONF" | cut -d = -f 2`
    echod "CheckSettings:THUMBNAILFOLDER" "TMPCONF=\"$TMPCONF\""
    if [ ! -d "$TMPCONF" ] ; then
      # Try to create dir:
      mkdir -p "$TMPCONF"
    fi
    if [ -d "$TMPCONF" ] ; then
      # Directory exists
      # Could we write into it?
      TMPFILE=`mktemp "$TMPCONF"/test.XXXXXXXXX`
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
      TMPFILE=`mktemp "$THUMBNAILFOLDER"/test.XXXXXXXXX`
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
    TMPCONF=$(grep EXPORTFOLDER "$1")
  else
    TMPCONF=""
  fi
  if [ -n "$TMPCONF" ] ; then
    # The option is configured. Get the new content and test it:
    TMPCONF=`echo "$TMPCONF" | cut -d = -f 2`
    echod "CheckSettings:EXPORTFOLDER" "TMPCONF=\"$TMPCONF\""
    if [ ! -d "$TMPCONF" ] ; then
      # Try to create dir:
      mkdir -p "$TMPCONF"
    fi
    if [ -d "$TMPCONF" ] ; then
      # Directory exists
      # Could we write into it?
      TMPFILE=`mktemp "$TMPCONF"/test.XXXXXXXXX`
      if [ -e "$TMPFILE" ] ; then
        rm "$TMPFILE"
        EXPORTFOLDER="$TMPCONF"
        # all ok, next settings
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
      TMPFILE=`mktemp "$EXPORTFOLDER"/test.XXXXXXXXX`
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
    TMPCONF=`echo "$TMPCONF" | cut -d = -f 2`
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
    TMPCONF=`echo "$TMPCONF" | cut -d = -f 2`
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
    TMPFILE=`mktemp "$DATABASEFOLDER"/test.XXXXXXXXX`
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
    TMPFILE=`mktemp "$THUMBNAILFOLDER"/test.XXXXXXXXX`
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
# CheckExportFolder
#
function CheckExportFolder()
{
  if [ -d "$EXPORTFOLDER" ] ; then
    # Directory exists
    # Could we write into it?
    TMPFILE=`mktemp "$EXPORTFOLDER"/test.XXXXXXXXX`
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
  echod "DebugSettings" "EXPORTFOLDER=$EXPORTFOLDER"
  echod "DebugSettings" "SETTINGSFILE=$SETTINGSFILE"
}

# #########################################
# DebugProgParams
# Show all Settings.
function DebugProgParams()
{
  echo "[$PROG_NAME:DebugProgParams] verzeichnis=$verzeichnis"
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
        echod "Main:Program Parameter:Scan" "Debug output on."
      fi
      if [ "$param" = "-v" ] ; then
        ECHOVERBOSE="1"
        echod "Main:Program Parameter:Scan" "Verbose output on."
      fi
      if [ "$param" = "-w" ] ; then
        ECHOWARNING="1"
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
      if [ "$param" = "-r" ] ; then
        RECURSIVE="1"
        echod "Main:Program Parameter:Scan" "In recursive execution ..."
      fi

  done
fi

if [ "$RECURSIVE" = "0" ] ; then
  # Check Settings:
  if [ -e "$SETTINGSFILE" ] ; then
    # Check, if some settings aer stored in the file:
    CheckSettings "$SETTINGSFILE"
  else
    # The file did not exists, but the standard tests should be done:
    CheckSettings "-#FileNotReallyThere."
  fi

  echod "Main:RECURSIVE" "Prepare for recursive execution ..."
  # Set settings for recursive execution:
  export IMAGEVIEWERDATABASEFOLDER="$DATABASEFOLDER"
  export IMAGEVIEWERDATABASEFILE="$DATABASEFILE"
  export IMAGEVIEWERUUIDFILE="$UUIDFILE"
  export IMAGEVIEWERTHUMBNAILFOLDER="$THUMBNAILFOLDER"
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
    PART=`basename "$datei"`
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
        $0 -r `pwd`/*
      fi
    else
      # Normal file.
      # Is readable?
      if [ ! -r "$datei" ] || [ ! -s "$datei" ] ; then
        echow "Main:File" "File $datei not readable or has size zero. Skip."
      else
        # Get mime type...
        MIMETYPE=`file --mime-type --separator ";" "$datei" | cut -d ";" -f 2 `
        echod "Main:MimeType" ">$MIMETYPE<"

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
          export IMAGEVIEWERFILENAME="$PART"
          # Create file to get variables from exif2html.sh:
          export IMAGEVIEWERTMPFILE=`mktemp .$PROG_NAME.Return.XXXXXXXXX`
          # Run exif2html.sh "$FULLPATH" #>> "$DATABASEFILE"
          exif2html.sh "$datei"
          # Get ariables from exif2html.sh:
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
              TMPSTRING="$FULLFILENAME;$IMAGEVIEWERFILENAME;$IMAGEVIEWERDATETIME;$IMAGEVIEWERWIDTH;$IMAGEVIEWERHEIGHT;$IMAGEVIEWERCAMERA;"
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
              fi
            fi
          fi
        fi

        # #########################################
        if [ "$MIMETYPE" = " application/pdf" ]
        then
          MIMEKNOWN="1"
          echod "Main:MimeType" "Is PDF."
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

        # One line per file found.
        #IFS=$OLDIFS
        echon "Main:Done" "$datei"
      fi
    fi
  fi
done

# reset array delimiter:
IFS=$OLDIFS
