// ///////////////////////////////////////////////////////////////////////////
//
// Run with tsc, maybe with options: --pretty --removeComments --watch
// or see tsconfig.json file

// ///////////////////////////////////////////////////////////////////////////
//
// Versions
//
// 2018-03-11 0.01 kdk First version read from websockets
// 2018-03-11 0.02 kdk
// 2018-04-25 0.03 kdk
// 2018-04-26 0.04 With Navigation
// 2018-05-13 0.05 With Comments
// 2018-05-15 0.06 With more Comments
// 2018-05-22 0.10 With license text
// 2018-05-22 0.11 With automated server ip address
// 2018-06-12 0.12 With Album Name Parsing
// 2018-06-26 0.13 With fallback for serveripaddress
// 2018-07-22 0.14 With more comments, IVAlbumsClick, IVAlbumsClean
// 2019-01-21 0.15 With "B->S" for Logging messages
// 2019-01-22 0.16 With more Album functions
// 2019-01-24 0.17 Normal key handling for complete Page

var WEBSOCKETS_VERSION = "0.17";
var WEBSOCKETS_SUBVERSION = "10";


// ///////////////////////////////////////////////////////////////////////////
//
// MIT license (MIT)
//
// Copyright 2018 Karsten Köth
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

// ///////////////////////////////////////////////////////////////////////////
//
// Functions
//

  function wsLog(msg)
  {
    let text = document.getElementById('wslogoutput').textContent;
    document.getElementById('wslogoutput').textContent= msg + '\n' + text;
  }

  function wsDebugSend()
  {
    ws.send('kdk was here.');
    console.log('kdk: Send WebSocket');
    wsLog('B->S Send debug message.')
  }

  function wsImageVers()
  {
    ws.send('VERS');
    wsLog('B->S VERS');
  }

  // ///////////////////////////////////////////////
  // Album

  // TODO: ALBS --> List all shortcuts into an array. Ask for every shortcut
  //                the albumname with ALBU=Shortcut.

  function AlbumsList(content)
  {
    wsLog('B<-S All Albums: '+content);
    ShowAlbums(content);
  }

  // AlbumSplit
  // Splits the parameter in all single fields.
  // Semicolon separated list with one char long fields.
  // "content" contains something like "F;G;"
  function AlbumSplit(content)
  {
    wsLog('B<-S Album shortcuts: '+content);
    var slen=content.length;
    var stmp='';
    var pos=0;
    albumshortcuts=content;
    while ( pos<slen )
    {
      stmp=content.charAt(pos);
      if (stmp!=";")
      {
        // It Works
        // wsLog('Album Shortcut '+stmp);
        // Get AlbumName:
        ws.send('ALBU='+stmp)
        //wsLog('B->S ALBU')
      }
      pos++;
    }
  }

  // TODO: On an image, press a shortcut (if this is element from albumShortcuts):
  //   If shortcut not exists: Open dialog "create new albumname".
  //   Check, if image is part from album.
  //   If shortcut exists and image is part from album: Remove image from album (after security question.)
  //   If shortcut exists and image is not part from album: Add to album. AINC=shortcut

  // ///////////////////////////////////////////////

  function IVAlbumsClean()
  {
    let child;
    // Clean global variable:
    albumshortcuts = "";
    // Delete all elements in DOM:
    while (albumcount > 0)
    {
      child = document.getElementById("IValbumsDiv0");
      child.parentNode.removeChild(child);
      albumcount--;
      //wsLog('B    --');
    }
  }

  function IVAlbumsClick(obj)
  {
    wsLog('B<-S AlbumName: '+obj);
    wsLog("B    AlbumsClick: Create new album element in DOM.");
    let node = document.createElement("DIV");
    node.className = "IValbumsDiv";
    node.id = "IValbumsDiv0";
    let nodenode = document.createElement("P");
    nodenode.className = "IValbumsText";
    node.appendChild(nodenode);
    let textnode = document.createTextNode(obj);
    nodenode.appendChild(textnode);
    document.getElementById("IValbumsRoot").appendChild(node);
    albumcount++;
  }


  function ShowAlbums(obj)
  {
    let divnode = document.createElement("DIV");
    divnode.className = "IValbumsDiv";
    divnode.id = "IValbumsDivSA";

    let pnode = document.createElement("P");
    pnode.className = "IValbumsText";
    divnode.appendChild(pnode);

    let tnode = document.createTextNode(obj);
    pnode.appendChild(tnode);
    document.getElementById("IValbumsShow").appendChild(divnode);
    document.getElementById("IValbumsShow").style.visibility="visible";
    albumscount++;
  }

  function HideAlbums()
  {
    document.getElementById("IValbumsShow").style.visibility="hidden";

    let child;
    while (albumscount > 0)
    {
      child = document.getElementById("IValbumsDivSA");
      child.parentNode.removeChild(child);
      albumscount--;
      //wsLog('B    --');
    }
  }

  // ///////////////////////////////////////////////
  // Navigation

  function wsImagePos1()
  {
    // First: clear all labels:
    IVAlbumsClean();
    ws.send('POS1');
    ws.send('FILE');
    ws.send('GIVE');
    ws.send('FALB');
    ws.send('SHOW');
    wsLog('B->S POS1');
  }

  function wsImagePrev()
  {
    IVAlbumsClean();
    ws.send('PREV');
    ws.send('FILE');
    ws.send('GIVE');
    ws.send('FALB');
    ws.send('SHOW');
    wsLog('B->S PREV');
  }

  function wsImageGoto()
  {
    IVAlbumsClean();
    ws.send('GOTO=358');
    ws.send('FILE');
    ws.send('GIVE');
    ws.send('FALB');
    ws.send('SHOW');
    wsLog('B->S GOTO');
  }

  function wsImageNext()
  {
    IVAlbumsClean();
    ws.send('NEXT');
    ws.send('FILE');
    ws.send('GIVE');
    ws.send('FALB');
    ws.send('SHOW');
    wsLog('B->S NEXT');
  }

  function wsImageLast()
  {
    IVAlbumsClean();
    ws.send('LAST');
    ws.send('FILE');
    ws.send('GIVE');
    ws.send('FALB');
    ws.send('SHOW');
    wsLog('B->S LAST');
  }

  // ///////////////////////////////////////////////
  // Keyboard interaction
  //
  // https://www.w3schools.com/jsref/obj_keyboardevent.asp
  //
  // Modifiers:
  //
  // event.shiftKey
  // event.ctrlKey
  // event.altKey
  // event.metaKey
  //

  function IVInterpretKey(event)
  {
    let myKey = event.key;

    // if ( myKey == 'Control') It is only CTRL key without other normal keyes pressed.

      wsLog('B    Key: '+myKey);

      if ( ! event.shiftKey && event.ctrlKey && ! event.altKey && ! event.metaKey )
      {
        // BEGIN Control Level
        wsLog('B    Control Level');

        if ( myKey == 'a' )
        {
          ws.send('ALBA');
          wsLog('B->S ALBA');
        }
        if ( myKey == 'e' )
        {
          ws.send('EXPO');
          wsLog('B->S EXPO Export the actual file...');
        }
        if ( myKey == 'h' )
        {
          HideAlbums();
          wsLog('HideAlbums');
        }
        if ( myKey == 'i' )
        {
          ws.send('FILE');
          // wsLog('B->S FILE Print the filename.');
          wsLog('B<-S FILE ' + filename);
        }
        if ( myKey == 's' )
        {
          ws.send('ALBS');
          wsLog('B->S ALBS');
        }
        // END Control Level
      }

      if ( ! event.shiftKey && ! event.ctrlKey && ! event.altKey && ! event.metaKey )
      {
        if (  ( myKey == 'ArrowUp' ) || ( myKey == 'ArrowDown' ) || ( myKey == 'ArrowLeft' ) || ( myKey == 'ArrowRight' )  )
        {
          // BEGIN Arrow Level
          if ( myKey == 'ArrowUp' )
          {
            wsLog('UP');
          }
          if ( myKey == 'ArrowDown' )
          {
            wsLog('DOWN');
          }
          if ( myKey == 'ArrowLeft' )
          {
            wsImagePrev();
            wsLog('LEFT');
          }
          if ( myKey == 'ArrowRight' )
          {
            wsImageNext();
            wsLog('RIGHT');
          }
          // END Arrow Level
        } else {
           // BEGIN Album Level
          wsLog('B    Album Level');

          // The Server accepts only uppercase letters:
          let myShortcut = myKey.toUpperCase();
          wsLog('B    ' + myShortcut + ' ' + albumshortcuts);
          if ( albumshortcuts.search(myShortcut) == -1 )
          {
            // Not found --> Include it in album:
            ws.send('AINC='+myShortcut);
            wsLog('B->S AINC');
          } else {
            // It's in, so I will remove the image from album:
            ws.send('AEXC='+myShortcut);
            wsLog('B->S AEXC');
          }
          // Update view:
          IVAlbumsClean();
          ws.send('FALB');

          // END Album Level

        }

      }

  }

  // ///////////////////////////////////////////////
  //
  // main
  //

  // ///////////////////////////////
  // Setup websocket with callbacks
  let serveripaddress = location.hostname;
  if ( serveripaddress == '' )
  {
    // Static variant:
    //let wsURL = 'ws://localhost:8080/';
    serveripaddress='localhost';
  }
  let wsURL = 'ws://'+serveripaddress+':8080/';
  // For Testing:
  //var wsURL = 'ws://echo.websocket.org';

  let albumcount : number = 0;
  let albumscount : number = 0;
  let albumshortcuts : string = "";
  let imageuuid : string = "";
  let filename : string = "";
  let connected : boolean = false;

  // Register Keydown events:
  document.addEventListener("keydown", IVInterpretKey);

  // Start WebSocket
  wsLog('Version: ' + WEBSOCKETS_VERSION + '-' + WEBSOCKETS_SUBVERSION)
  wsLog('CONNECTING ' + wsURL + ' ...')
  let ws = new WebSocket(wsURL);

  // TODO
  // create timer: if "! connected" then try reconnect ...
  // setTimeout(function(),time);

  ws.onopen = function() {
    wsLog('CONNECTED');
    connected = true;
    wsImageVers();
  };

  ws.onclose = function() {
    wsLog('DISCONNECT');
    connected = false;
  };

  ws.onmessage = function(msg) {
    // Here, the output from image_viewer_server will be received.
    wsLog('B<-S MESSAGE: ' + msg.data);
    // Recognize Command:
    let str = msg.data;
    let sstr = str.split("=");
    let command = sstr[0];
    let content = sstr[1];
    // Do Command:
    if ( command == 'FILE')
    {
      // FILE - image file name
      let img = document.getElementById('IVImageMid');
      img.setAttribute('src', './Thumbnails/' + content);
      // $DATETIME.$UUID.$WIDTH"x"$HEIGHT.$CAMERA.THUMB.$FILENAME
      // 2011-04-07.15_57_58.F1EB38C4-78E3-4AA8-9148-9A10AD330053.5184x3456.Canon-EOS-60D.THUMB.IMG_0514.JPG.png
      filename=content;
      let sstr = filename.split(".");
      let filenameDate : string = sstr[0];
      let filenameTime : string = sstr[1];
      let filenameDimensions : string = sstr[3];
      let filenameCamera : string = sstr[4];
      wsLog(filenameDate);
      wsLog(filenameTime);
      wsLog(filenameDimensions);
      wsLog(filenameCamera);
    }
    if ( command == 'GIVE')
    {
      // GIVE - actual position in filelist
      document.getElementById('IVListPos').textContent=content;
    }
    if ( command == 'FALB')
    {
      // FALB - the album shortcuts the given UUID is in.
      // "content" contains something like "F;G;"
      // This function asks for every name and displays the name immediatly:
      AlbumSplit(content);
    }
    if ( command == 'ALBU')
    {
      // ALBU - Print the Album Name to a given Album Shortcut
      // TODO: Irgendwie anzeigen. Und zwar die Albumnamen anzeigen, nicht die Shortcuts.
      IVAlbumsClick(content);
    }
    if ( command == 'ALBA')
    {
      // Shows all defined Album Names.
      AlbumsList(content);
    }
    if ( command == 'ALBS')
    {
      // Print all used shortcuts.
      wsLog('B<-S Shortcuts: ' + content);
    }
    if ( command == 'SHOW')
    {
      // Show the UUID of the actual image:
      wsLog('B<-S SHOW: ' + content);
      imageuuid=content;
    }
  };

  ws.onerror = function(msg)
  {
    // The following errors occured:
    // [object event] --> The server was down.
    wsLog('ERROR: ' + msg);
  };

  // Sending String:
  // ws.send('kdk was here.' + '\n');
  // Das Senden klappt hier noch nicht:
  // "Failed to execute 'send' on 'WebSocket': Still in CONNECTING state."

  // ///////////////////////////////
  // Init Album things:

  // TODO
  // let albumShortcuts = Irgendein array
