#!/bin/bash

# #########################################
#
# Versions
#
# 2018-03-11 0.01 kdk First Tests
# 2018-03-13 0.02 kdk With echod
# 2018-03-17 0.03 kdk More comments, Includes, Albums
# 2018-03-18 0.04 kdk
# 2018-03-20 0.05 kdk With ListSwitch
# 2018-04-06 0.06 kdk with two Includes
# 2018-04-25 0.07 kdk with HELP
# 2018-05-15 0.08 kdk All commands to webside marked with COMMAND=
# 2018-05-21 0.10 kdk With license text and include file extension changed from
#                     inc to bash.
# 2018-06-12 0.11 kdk With ALBU in output.
# 2018-06-21 0.12 kdk With more ideas.
# 2019-01-21 0.13 kdk Version updated.
# 2019-01-22 0.14 kdk AlbumName extended with 2. parameter
# 2019-01-24 0.15 kdk Export Bug fixed
# 2019-02-23 0.16 kdk AGET in echo, with AlbumJSON
# 2019-02-25 0.17 kdk With ALBC + ALBD echo outout to inform client.
# 2020-11-16 0.18 kdk With Export Script
# 2021-02-24 0.19 kdk With showVersion, Usage enhanced, PROG_NAME changed
# 2021-02-28 0.20 kdk File lookup for export

# #########################################
#
# Usage
#
# Start with:
# $ imageviewer_startserver.sh
#
#
# Or by hand:
# Now let's turn it into a WebSocket server:
#
# $ websocketd --port=8080 ./image_viewer_server.sh
#
# Inside the javascript code, the same port must be used.
#

# #########################################
#
# MIT license (MIT)
#
# Copyright 2018 - 2021 by Karsten Köth
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
# Ideas
#
# One process has websocket connection to the ipad.
# Another process has connection to a TFT - browser in fullscreen.
# Between the two websocket backends - running on the same cpu - there is
# communication about Signals (see trap) and shared memory (see ipcs).
#    brew install shmcat
# Within the trap (when triggered via a signal), the $? variable is initially
# set to the signal number plus 128, so you can assign the signal number to a
# variable by making the first statement of the trap action to something like
#    sig=$(($? - 128))
# You can then get the name of the signal using the kill command
#    kill -l $sig
# Or:
#       _handler() {
#         signal=$1
#         echo signal was $signal
#       }
#
#       trap '_handler SIGUSR1' SIGUSR1
#       trap '_handler SIGUSR2' SIGUSR2
#
# share Pictures: brew install imessage-ruby
# Picture per imessage verbreiten.
# imessage -t "Letzter Test" -c "+49 151 22184622"

# #########################################
#
# Constants
#

PROG_NAME="ImageViewer Server"
PROG_VERSION="0.19"
PROG_DATE="2021-02-24"
PROG_CLASS="ImageViewer"
PROG_SCRIPTNAME="image_viewer_server.sh"


# #########################################
#
# Includes
#
# Will be read once on start of the program:

source image_viewer_common_vars.bash
source image_viewer_common_func.bash


# #########################################
# DebugCounter
# Debug the websocket connection
# No Parameter
# Not necessary for productive system.
function DebugCounter()
{
  for ((COUNT = 1; COUNT <= 3; COUNT++)); do
    echo "IV: $COUNT"
    sleep 1
  done
}

# #########################################
# DebugTest
# Not necessary for productive system.
function DebugTest()
{
  echod "DebugTest" "$TEST"
  local stest=( {A..Z} {a..z} {0..9} + / = )
  echod "DebugTest" "$stest"
  echod "DebugTest" "${stest[3]}"
}

# ##############################################################################
#
# List*
#
# List* is something like an bash object. It has a constructor and some member
# functions.
#
# ListPos points to the actual List element. The first element has index "0".
# ListLast points to the latest List element.
# ListWrap is boolean:
#          0: If ListPos = 0 AND CMD=PREV --> ListPos = 0
#          1: If ListPos = 0 AND CMD=PREV --> ListPos = ListLast
# ListType is integer:
#          1: List all images,  default case
#          2: List only images in actual selection.
# AlbumActual is char:
#          "0": No valid Album.
#          "A" ... "Z": Valid Album.

# #########################################
# ListInit
# Must be called before working with List*.
# Remeber: In bash, defining a variable in a function makes the variable to a
#          global one by the first run of the function.
function ListInit()
{
  ListPos=0
  ListLast=0
  ListWrap=0
  ListType=1
  AlbumActual="0"
}

# #########################################
# ListCreate
# Read in the complete list from a file.
# The format of the file is defined in html_collect_pictures.sh.
# The old content of the List will not be deleted. This could generate bugs.
function ListCreate()
{
  if [ $ListType -eq 1 ] ; then
    ListFileNames=( $(cut -d ";" -f 1 "$UUIDFILE") )
  elif [ $ListType -eq 2 ] ; then
    if [ "$AlbumActual" != "0" ] ; then
      local filenametmp="$ALBUMPREFIX$AlbumActual$ALBUMPOSTFIX"
      ListFileNames=( $(cat "$filenametmp") )
    fi
  else
    echod "ListCreate" "Unknow type of List."
    ListFileNames=""
  fi
  ListLast=${#ListFileNames[@]}
  # Security check: Later, I will substract 1, therefore, it must be greater 0:
  if [ $ListLast -lt 1 ] ; then
    ListLast=1
  fi
  echod "ListCreate" "$ListLast"
}

# #########################################
# ListFile
# Print the Path and filename to stdout.
# The absolute path must be removed and the relative path from webserver
# view must be attached.
function ListFile()
{
  local stmp="${ListFileNames[$ListPos]}"
  echod "ListFile" "'$stmp'"
  local sstmp="$(ls -1 $THUMBNAILFOLDER/*$stmp*)"
  # Print the filename with absolute path to stdout:
  #echo "$sstmp"
  local ssstmp="$(basename "$sstmp")"
  # Print the filename without path:
  # COMMAND=FILE
  # echo "FILE=$ssstmp"
  # COMMAND must be added in main loop to support export, ...
  echo "$ssstmp"
  # Print the file name with relative path for webbrowser:
  #echo "$WEBTHUMBNAIL/$ssstmp"
}

# #########################################
# ListFileExport
# Print the absolute Path and filename to stdout.
function ListFileExport()
{
  local stmp="${ListFileNames[$ListPos]}"
  echod "ListFile" "'$stmp'"
  echo "$stmp"
}

# #########################################
# ListGoto
# Go to a specific position.
function ListGoto()
{
  # Parameter must be present:
  if [ -n "$1" ] ; then
    # Parameter must be only a number:
    if [ "$1" -eq "$1" ] 2> /dev/null; then
      if [ $1 -lt 0 ] ; then
        ListPos=0
      elif [ $1 -ge $ListLast ] ; then
        ListPos=$(expr $ListLast - 1)
      else
        ListPos=$1
      fi
    fi
  fi
}

# #########################################
# ListSwitch
# Switch between kinds of Lists.
# Parameter: "A" : List contains filenames from one album.
#            "L" : List contains filenames from all files.
function ListSwitch()
{
  if [ -n "$1" ] ; then
    local stmp="$1"
    if [ ${#stmp} -eq 1 ] ; then
      if [ "$1" = "A" ] ; then
        ListType=2
        if [ "$AlbumActual" != "0" ] ; then
          ListCreate
        fi
      elif [ "$1" = "L" ]; then
        ListType=1
        # Read in:
        ListCreate
      else
        echod "ListSwitch" "Unknown parameter '$1'."
      fi
    else
      echod "ListSwitch" "Unsupported parameter length of '$1'."
    fi
  else
    echod "ListSwitch" "Parameter needed."
  fi
}

# ##############################################################################
#
# Album*
#

# Show the album names only on selected image, not on all images.
#  But:
# Show only images inside album X
#
# Export source image into EXPORTFOLDER --> Create export script which must be  TODO
# executed when the Notebook is connected to the external drives.

# What is the album name of the shortcut?
# Include image into album with shortcut X
# Exclude image from album with shortcut X

# #########################################
# AlbumFile
# In which albums the image is member in? --> Returns a list of shortcuts       TODO
# Prints out on stdout the album shortcuts the given UUID is in.
function AlbumFile()
{
  local stmp="$(grep -l "^$1" $ALBUMPREFIX?$ALBUMPOSTFIX)"
  if [ -n "$stmp" ] ; then
    # stmp contains one line per file
    echod "AlbumFile" "$stmp"
    local strl=${#ALBUMPREFIX}
    echod "AlbumFile" "$strl"  # 40

    # array delimiter not spaces:
    OLDIFS=$IFS
    IFS=$(echo -en "\n\b")

    local datei=""
    local ctmp=""
    local sstmp=""
    for datei in $stmp
    do
      ctmp="${datei:strl:1}"
      echod "AlbumFile" "$ctmp"
      sstmp="$sstmp$ctmp;"
    done
    echod "AlbumFile" "$sstmp"
    # COMMAND=FALB
    echo "FALB=$sstmp"

    # reset array delimiter:
    IFS=$OLDIFS

  fi
}

# #########################################
# AlbumName
# Prints out on stdout the albumname which corresponds to a shortcut.
function AlbumName()
{
  local stmp="$(grep "^$1;" "$ALBUMFILE" | tail -n 1 | cut -d ";" -f 2)"
  if [ -n "$stmp" ] ; then
    if [ $# -ge 2 ] ; then
      echo "$stmp"
    else
      echo "ALBU=$stmp"
    fi
  fi
}

# #########################################
# AlbumJSON
# Shows all defined Album Names with shortcuts.
function AlbumJSON()
{
  # Init:
  stest=( {A..Z} {a..z} {0..9} + / = )
  local itmp=0
  local ctmp="${stest[$itmp]}"
  # For all uppercase letters:
  while [ "$ctmp" != "a" ] ; do
    echod "AlbumAll" "$itmp : '$ctmp'"
    local stmp=$(AlbumName "$ctmp" "A")
    if [ -n "$stmp" ] ; then
      echo "ALBJ=$ctmp:$stmp"
    fi
    itmp=$(expr $itmp + 1)
    ctmp="${stest[$itmp]}"
  done
}

# #########################################
# AlbumAll
# Shows all defined Album Names.
# Shows in every line an album name.
function AlbumAll()
{
  # Init:
  stest=( {A..Z} {a..z} {0..9} + / = )
  local itmp=0
  local ctmp="${stest[$itmp]}"
  # For all uppercase letters:
  while [ "$ctmp" != "a" ] ; do
    echod "AlbumAll" "$itmp : '$ctmp'"
    local stmp=$(AlbumName "$ctmp" "A")
    if [ -n "$stmp" ] ; then
      echo "ALBA=$stmp"
    fi
    itmp=$(expr $itmp + 1)
    ctmp="${stest[$itmp]}"
  done
}

# #########################################
# AlbumShort
# Shows all defined Album Name shortcuts.
# Shows in every line an album name shortcut.
function AlbumShort()
{
  # Init:
  stest=( {A..Z} {a..z} {0..9} + / = )
  local itmp=0
  local ctmp="${stest[$itmp]}"
  # For all uppercase letters:
  while [ "$ctmp" != "a" ] ; do
    echod "AlbumShort" "$itmp : '$ctmp'"
    # Only if a Album name is returned, we have a shortcut found:
    local stmp=$(AlbumName "$ctmp")
    if [ -n "$stmp" ] ; then
      echo "ALBS=$ctmp"
    fi
    itmp=$(expr $itmp + 1)
    ctmp="${stest[$itmp]}"
  done
}

# #########################################
# AlbumCreate
# The parameter must be in form of a ALBUMFILE line.
function AlbumCreate()
{
  local stmp="$1"
  if [ ${#stmp} -gt 2 ] ; then
    # Could be a correct line. Go on.
    if [ ${stmp:1:1} = ";" ] ; then
      echod "AlbumCreate" "New Album for shortcut '${stmp:0:1}' : '${stmp:2}'"
      echo "$stmp" >> "$ALBUMFILE"
    fi
  fi
}

# #########################################
# AlbumDelete
# The parameter must be one uppercase letter.
function AlbumDelete()
{
  local stmp="$1"
  if [ ${#stmp} -eq 1 ] ; then
    echo "$1;" >> "$ALBUMFILE"
    local filenametmp="$ALBUMPREFIX$stmp$ALBUMPOSTFIX"
    if [ -e "$filenametmp" ] ; then
      # Also delete the file of this specific album.
      rm "$filenametmp"
    fi
  fi
}

# #########################################
# AlbumLetter
# The parameter must be one album name.
function AlbumLetter()
{
  if [ -n "$1" ] ; then
    local stmp="$(grep "^.;$1" "$ALBUMFILE" | tail -n 1 | cut -d ";" -f 1)"
    echod "AlbumLetter" "'$stmp'"
    # Is the last line with album name also the last line with this shortcut?
    if [ -n "$stmp" ] ; then
      local sstmp="$(AlbumName $stmp)"
      echod "AlbumLetter" "'$1' = '$sstmp'"
      if [ "$1" = "$sstmp" ] ; then
        echo "$stmp"
      fi
    fi
  fi
}

# #########################################
# AlbumSet
# Set the actual Album List* is working on
function AlbumSet()
{
  if [ -n "$1" ] ; then
    # Is this a legal Shortcut?
    local stmp="$(AlbumName "$1")"
    if [ -n "$stmp" ] ; then
      # Album exists.
      AlbumActual="$1"
      # Show actual status:
      echo "ASET=$1"
      # If we are at the moment in using Album for the List, then immediatly
      # reread Content of List:
      if [ $ListType -eq 2 ] ; then
        ListCreate
      fi
    else
      # Wrong Album, unset variable:
      echod "AlbumSet" "Unset AlbumActual"
      AlbumActual="1"
    fi
  else
    echod "AlbumSet" "Parameter needed."
  fi
}

# #########################################
# AlbumGet
# Get the actual Album List* is working on
function AlbumGet()
{
  echo "AGET=$AlbumActual"
}

# #########################################
# AlbumInclude
# put the UUID into the album
# Parameter:
# 1: From: UUID
# 2: To: Album shortcut
function AlbumInclude()
{
  local stmpFrom="$1"
  local stmpTo="$2"
  if [ ${#stmpTo} -eq 1 ] ; then
    # Is it a valid album?
    local stmp="$(AlbumName $stmpTo)"
    if [ -z "$stmp" ] ; then
      echod "AlbumInclude" "'$stmpTo' is no valid album shortcut."
    else
      # we have a valid album, go on:
      local filenametmp="$ALBUMPREFIX$stmpTo$ALBUMPOSTFIX"
      echod "AlbumInclude" "'$stmpFrom' --> '$stmpTo' '$filenametmp'"
      # Maybe, the album is valid, but the albumfile is not yet created. Would
      # create an error with grep! Therefore:
      touch "$filenametmp"
      # Only include if not yet inside:
      stmp="$(grep "^$stmpFrom$" "$filenametmp")"
      if [ "$stmp" = "$stmpFrom" ] ; then
        echod "AlbumInclude" "Image still exists in album file. Nothing to do."
      else
        echo "$stmpFrom" >> "$filenametmp"
      fi
    fi
  fi
}

# #########################################
# AlbumExclude
# Delete the UUID from the album
# Parameter:
# 1: From: UUID
# 2: To: Album shortcut
function AlbumExclude()
{
  local stmpFrom="$1"
  local stmpTo="$2"
  if [ ${#stmpTo} -eq 1 ] ; then
    # Is it a valid album?
    local stmp="$(AlbumName $stmpTo)"
    if [ -z "$stmp" ] ; then
      echod "AlbumExclude" "'$stmpTo' is no valid album shortcut."
    else
      # we have a valid album, go on:
      local filenametmp="$ALBUMPREFIX$stmpTo$ALBUMPOSTFIX"
      echod "AlbumExclude" "'$stmpFrom' --> '$stmpTo' '$filenametmp'"
      touch "$filenametmp"
      # Only exclude if it is inside:
      stmp="$(grep "^$stmpFrom$" "$filenametmp")"
      if [ "$stmp" = "$stmpFrom" ] ; then
        # It is inside, remove:
        # Something like: sed -i 's/$stmpFrom//' "$filenametmp"
        # On MAC: sed -i "" s/6A3034AD-73BB-479A-8B91-BAE416909570// album_T.csv
        sed -i "" s/$stmpFrom// "$filenametmp"
      else
        echod "AlbumExclude" "Image does not exists in album file. Nothing to do."
      fi
    fi
  fi
}

# #########################################
# ExportFile
# Export the actual file to the export folder.
# Parameter:
#    1: image-UUID
function ExportFile()
{
  #cp "$THUMBNAILFOLDER/$1" "$EXPORTFOLDER"
  # TODO Nicht thumbnails, sondern originalbilder kopieren.
  # We do not copy the files directly, we create a copy script. 
  # The advantage: Maybe, some files are stored on disks not always on.
  # Get from UUID the correct file:
  tmpFile=$(grep $1 "$UUIDFILE" | cut -d ";" -f 2 - )
  # Maybe this is the first time we write into the script! First line must be special command:
  if [ ! -f "$EXPORTBASHSCRIPT" ] ; then
    echo "#!/bin/bash" > "$EXPORTBASHSCRIPT"
    chmod u+x "$EXPORTBASHSCRIPT"
  fi
  # Add to export-bash-script the original files:
  echo "cp \"$tmpFile\" \"$EXPORTFOLDER/\"" >> "$EXPORTBASHSCRIPT"
  # Vielleicht doch nur eine einfache Liste ausgeben und dann mit einem Script schauen, auf welche Originals man direkt kommt.
  # Dieses Script könnte mit dem "EXPORT" Dialog aus der Titelleiste aufgerufen werden.
  # Das EXPORTBASHSCRIPT wurde noch nicht getestet!
  # Derzeit enthält $1 nur die Bild-UUID - Zuordnung erfolgt über UUIDFILE (filenames.csv): UUID ; Full Path with File Name
  # Umrechnungs-Funktion könnte showFilePath lauten. Input UUID, Output Full Path with File Name 
}

 #########################################
# showHelp()
# Parameter
#    -
# Return Value
#    -
# Show help.
function showHelp()
{
      echo "$PROG_SCRIPTNAME Program Parameter:"
      echo "    -V     : Show Program Version"
      echo "    -h     : Show this help"
      echo ""
      echo "Interface: Four character command code. Some commands have arguments:"
      echo "QUIT       Quit program"
      echo "ECHO text  Print text to stdout"
      echo "VERS       Print program name and version number to stdout."
      echo "DEBU=ON | OFF Switch debug output on and off. With debug on, the javascript will not work."
      echo "TEST       Some test outputs."
      echo "SHOW       Print the UUID to stdout."
      echo "FILE       Print the image file name to stdout."
      echo "OPEN       Shows the picture under MAC OS X"
      echo "GIVE       Print the actual position in filelist to stdout."
      echo "ALBU       Print the Album Name to a given Album Shortcut to stdout."
      echo "...        More commands available."
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

# No "Starting..." message: Normally, we are running as server.

# Check for program parameters:
if [ $# -eq 1 ] ; then
    if [ "$1" = "-V" ] ; then
        showVersion ; exit;
    elif [ "$1" = "-h" ] ; then
        showHelp ; exit;
    else
        echo "[$PROG_NAME:ERROR] Program parameter unknown. Exit." ; exit;
    fi
fi


# Debug WebSockets:
#DebugCounter

# Init
# We are a webserver service, therefore:
ECHODEBUG="0"
# Prepare List*:
ListInit
ListCreate

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
      showVersion
    fi

    if [ "$CMD" = "DEBU" ] ; then
      if [ "$DATA" = "ON" ] ; then
        ECHODEBUG="1"
        echod "Main" "Debug output switched on."
      else
        ECHODEBUG="0"
      fi
    fi

    if [ "$CMD" = "TEST" ] ; then
      DebugTest
    fi

    if [ "$CMD" = "HELP" ] ; then
      showHelp
    fi

    # List* Commands:
    if [ "$CMD" = "LIST" ] ; then
      # Is the "Refresh". This command is only necessary if html_collect_pictures
      # runs parallel.
      # Or if you switch between List and Album!
      ListCreate
    fi

    if [ "$CMD" = "POS1" ] ; then
      ListPos=0
    fi

    if [ "$CMD" = "NEXT" ] ; then
      ListPos=$(expr $ListPos + 1)
      if [ $ListPos -ge $ListLast ] ; then
        if [ $ListWrap -eq 1 ] ; then
          # We have to wrap! Make same as CMD=POS1
          ListPos=0
        else
          ListPos=$(expr $ListLast - 1)
        fi
      fi
    fi

    if [ "$CMD" = "PREV" ] ; then
      ListPos=$(expr $ListPos - 1)
      if [ $ListPos -lt 0 ] ; then
        if [ $ListWrap -eq 1 ] ; then
          # We have to wrap! Make same as CMD=LAST
          ListPos=$(expr $ListLast - 1)
        else
          # We do not wrap-around. Therefore stop at zero:
          ListPos=0
        fi
      fi
    fi

    if [ "$CMD" = "LAST" ] ; then
      ListPos=$(expr $ListLast - 1)
    fi

    if [ "$CMD" = "GIVE" ] ; then
      # COMMAND=GIVE
      echo "GIVE=$ListPos"
    fi

    if [ "$CMD" = "GOTO" ] ; then
      ListGoto "$DATA"
    fi

    if [ "$CMD" = "WRAP" ] ; then
      if [ "$DATA" = "ON" ] ; then
        ListWrap=1
        echod "Main" "List wrap-around is switched on."
      else
        ListWrap=0
        echod "Main" "List wrap-around is switched off."
      fi
    fi

    if [ "$CMD" = "SHOW" ] ; then
      # Print the UUID on stdout:
      echo "SHOW=${ListFileNames[$ListPos]}"
    fi

    if [ "$CMD" = "FALB" ] ; then
      # Print the album shortcuts from the filename on stdout:
      AlbumFile "${ListFileNames[$ListPos]}"
    fi

    if [ "$CMD" = "FILE" ] ; then
      # Print the filename on stdout:
      echo "FILE=$(ListFile)"
    fi

    if [ "$CMD" = "OPEN" ] ; then
      # Show the file on screen.
      open "$(ListFile)"
    fi

    if [ "$CMD" = "EXPO" ] ; then
      # Export the file
      # ExportFile "$(ListFile)" # Version for exporting Thumbnails
      ExportFile "$(ListFileExport)" # Version for exporting Originals via bash Script
    fi

    # Switch between different Cases:
    if [ "$CMD" = "SWIT" ] ; then
      ListSwitch "$DATA"
    fi

    # Album* Commands for ALBUMFILE:
    if [ "$CMD" = "ALBU" ] ; then
      # Print the albumname on stdout:
      # e.g. AlbumName "C"
      AlbumName "$DATA"
    fi

    if [ "$CMD" = "ALBL" ] ; then
      # Print the album shortcut:
      # e.g. AlbumLetter "Cicero"
      AlbumLetter "$DATA"
    fi

    if [ "$CMD" = "ALBA" ] ; then
      # Print all albumnames on stdout:
      AlbumAll
    fi

    if [ "$CMD" = "ALBS" ] ; then
      # Print all used shortcuts on stdout:
      AlbumShort
    fi

    if [ "$CMD" = "ALBJ" ] ; then
      # Print all albumnames with shortcuts on stdout:
      AlbumJSON
    fi

    if [ "$CMD" = "ALBC" ] ; then
      # Create or change one Album Name
      # e.g. AlbumCreate "C;Cäsar"
      AlbumCreate "$DATA"
      echo "ALBC=$DATA"
    fi

    if [ "$CMD" = "ALBD" ] ; then
      # Delete one shortcut:
      # e.g. AlbumDelete "C"
      AlbumDelete "$DATA"
      echo "ALBD=$DATA"
    fi

    # Album* Commands for the collection of album files:
    if [ "$CMD" = "AINC" ] ; then
      # Insert the actual UUID into the album.
      # e.g. AlbumInclude "$UUID" "C"
      AlbumInclude "${ListFileNames[$ListPos]}" "$DATA"
    fi

    if [ "$CMD" = "AEXC" ] ; then
      # Exclude the actual UUID from the album.
      # e.g. AlbumExclude "$UUID" "C"
      AlbumExclude "${ListFileNames[$ListPos]}" "$DATA"
    fi

    if [ "$CMD" = "ASET" ] ; then
      # Set a global variable which define which album will be used with List*
      # commands.
      AlbumSet "$DATA"
    fi

    if [ "$CMD" = "AGET" ] ; then
      # Get the global variable which define which album will be used with List*
      # commands.
      AlbumGet
    fi

  fi
done

# No "Done." message: Normally, we are running as server.
