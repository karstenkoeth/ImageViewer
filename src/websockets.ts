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
// 2019-02-17 0.18 More key handling
// 2019-02-23 0.19 Can shut down the server ;-)
// 2019-02-25 0.20 With AlbumsList as standard

var WEBSOCKETS_VERSION = "0.20";
var WEBSOCKETS_SUBVERSION = "04";


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
    if ( logging == true )
    {
      document.getElementById('wslogoutput').textContent= msg + '\n' + text;
    }
  }

  function wsStart()
  {
    ws = new WebSocket(wsURL);
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
    wsLog('websockets ' + WEBSOCKETS_VERSION + '-' + WEBSOCKETS_SUBVERSION)
  }

  // ///////////////////////////////////////////////
  // Album

  // TODO: ALBS --> List all shortcuts into an array. Ask for every shortcut
  //                the albumname with ALBU=Shortcut.

  function AlbumsList(content)
  {
    // wsLog('B<-S All Albums: '+content);
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
    //wsLog('B<-S AlbumName: '+obj);
    //wsLog("B    AlbumsClick: Create new album element in DOM.");
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

  function IVAlbumsCreate(obj)
  {
    ws.send('ALBC='+obj);
    wsLog('B->S Create or change Album '+obj);
  }

  function ShowAlbums(obj)
  {
    let divnode = document.createElement("DIV");
    divnode.className = "IValbumsDiv";
    divnode.id = "IValbumsDivSA";

    let pnode = document.createElement("P");
    pnode.className = "IValbumsText";
    divnode.appendChild(pnode);

    // Test for Shortcut with Albumname (ALBJ Functionality):
    let str = obj;
    let sstr = str.split(":");
    let strshort = sstr[0];
    let strname = sstr[1];
    let struse;
    if ( strname.length > 0 )
    {
      // With Shortcut
      struse=strname;
      pnode.title=strshort;
      pnode.addEventListener("click", function(){
        // left mouse button click
        if ( actalbumobj != null )
        {
          // a album is set as active
          if ( actalbumobj == this )
          {
            // change to all album mode:
            wsLog('B->S Set All Album mode');
            ws.send('SWIT=L');
            // change to normal mode:
            this.style.backgroundColor="rgb(212, 231, 246)";
            actalbumobj=null;
            // We can stay by the actual image.
          }
          else
          {
            // change the other album to 'normal' mode:
            actalbumobj.style.backgroundColor="rgb(212, 231, 246)";
            // make this album the one and only:
            let tmpstr=this.title;
            wsLog('B->S Set Album to ' + tmpstr);
            ws.send('ASET=' + tmpstr);
            this.style.backgroundColor="rgb(137, 196, 244)";
            actalbumobj=this;
            // Goto first image in this album:
            wsImageGoto(0);
          }
        }
        else
        {
          // Change this album to 'actual' mode:
          let tmpstr=this.title;
          wsLog('B->S Set Album to ' + tmpstr);
          // Switch album mode on:
          ws.send('SWIT=A');
          // Set this album as actual:
          ws.send('ASET=' + tmpstr);
          this.style.backgroundColor="rgb(137, 196, 244)";
          actalbumobj=this;
          // Goto first image in this album:
          wsImageGoto(0);
       }
      });
      pnode.addEventListener("contextmenu", function(event){
        // right mouse button click
        event.preventDefault();
        let tmpstr=this.title;
        // Make shure we are not in the album we delete, therefore change to all album mode:
        wsLog('B->S Set All Album mode');
        ws.send('SWIT=L');
        wsLog('B->S Delete Album: '+tmpstr);
        ws.send('ALBD='+tmpstr);
        // Rebuild Album structure later by receiving "ALBD" ...
        return false;
      }, false);
    }
    else
    {
      // Without Shortcut
      struse=obj;
    }

    let tnode = document.createTextNode(struse);
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

  function wsAlbumsList()
  {
    ws.send('ALBJ');
    // wsLog('B->S ALBJ');
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
    //wsLog('B->S POS1');
  }

  function wsImagePrev()
  {
    IVAlbumsClean();
    ws.send('PREV');
    ws.send('FILE');
    ws.send('GIVE');
    ws.send('FALB');
    ws.send('SHOW');
    //wsLog('B->S PREV');
  }

  function wsImageGoto(number)
  {
    IVAlbumsClean();
    ws.send('GOTO='+number);
    ws.send('FILE');
    ws.send('GIVE');
    ws.send('FALB');
    ws.send('SHOW');
    //wsLog('B->S GOTO');
  }

  function wsImageNext()
  {
    IVAlbumsClean();
    ws.send('NEXT');
    ws.send('FILE');
    ws.send('GIVE');
    ws.send('FALB');
    ws.send('SHOW');
    //wsLog('B->S NEXT');
  }

  function wsImageLast()
  {
    IVAlbumsClean();
    ws.send('LAST');
    ws.send('FILE');
    ws.send('GIVE');
    ws.send('FALB');
    ws.send('SHOW');
    //wsLog('B->S LAST');
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

      if ( event.ctrlKey && ! event.altKey && ! event.metaKey )
      {
        // BEGIN Control Level /////////////////////////////////////////////////
        wsLog('B    Control Level');

        if ( myKey == 'a' )
        {
          ws.send('ALBA');
          wsLog('B->S ALBA');
        }
        if ( myKey == 'd' )
        {
          if ( logging == true)
          {
            logging = false;
            document.getElementById("IVProgrammersPoint").style.display = "none";
          }
          else
          {
            logging = true;
            document.getElementById("IVProgrammersPoint").style.display = loggingtmp;
          }
        }
        if ( myKey == 'e' )
        {
          ws.send('EXPO');
          wsLog('B->S EXPO Export the actual file...');
        }
        if ( myKey == 'g' )
        {
          // Get the global variable which define which album will be used with List* commands.
          ws.send('AGET');
        }
        if ( myKey == 'G' )
        {
          // Set the global variable which define which album will be used with List* commands.
          // "A" : List contains filenames from one album.
          // "L" : List contains filenames from all files.
          ws.send('SWIT=A');
          ws.send('ASET=' + actalbum);
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
        if ( myKey == 'j' )
        {
          wsAlbumsList();
        }
        if ( myKey == 'q' )
        {
          // Kill Server
          ws.send('QUIT');
          wsLog('B->S QUIT');
        }
        if ( myKey == 's' )
        {
          // Print all used shortcuts
          ws.send('ALBS');
          wsLog('B->S ALBS');
        }
        if ( myKey == 'v' )
        {
          // Debug: Show Version
          wsImageVers();
        }
        // END Control Level ///////////////////////////////////////////////////
      }

      if ( ! event.shiftKey && ! event.ctrlKey && ! event.altKey && ! event.metaKey )
      {
        if (  ( myKey == 'ArrowUp' ) || ( myKey == 'ArrowDown' ) || ( myKey == 'ArrowLeft' ) || ( myKey == 'ArrowRight' )  )
        {
          // BEGIN Arrow Level /////////////////////////////////////////////////
          if ( myKey == 'ArrowUp' )
          {
            wsImagePos1();
            //wsLog('UP');
          }
          if ( myKey == 'ArrowDown' )
          {
            wsImageLast();
            //wsLog('DOWN');
          }
          if ( myKey == 'ArrowLeft' )
          {
            wsImagePrev();
            //wsLog('LEFT');
          }
          if ( myKey == 'ArrowRight' )
          {
            wsImageNext();
            //wsLog('RIGHT');
          }
          // END Arrow Level ///////////////////////////////////////////////////
        } else {
          // BEGIN Album Level /////////////////////////////////////////////////
          //wsLog('B    Album Level');

          // The Server accepts only uppercase letters:
          let myShortcut = myKey.toUpperCase();
          //wsLog('B    ' + myShortcut + ' ' + albumshortcuts);
          if ( albumshortcuts.search(myShortcut) == -1 )
          {
            // Not found --> Include it in album:
            ws.send('AINC='+myShortcut);
            //wsLog('B->S AINC');
          } else {
            // It's in, so I will remove the image from album:
            ws.send('AEXC='+myShortcut);
            //wsLog('B->S AEXC');
          }
          // Update view:
          IVAlbumsClean();
          ws.send('FALB');

          // END Album Level ///////////////////////////////////////////////////

        }

      }

  }

  // ///////////////////////////////////////////////////////////////////////////
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
  let actalbum : string ="0";
  let actalbumobj = null;
  let imageuuid : string = "";
  let filename : string = "";
  let connected : boolean = false;
  let logging : boolean = false;
  var loggingtmp = document.getElementById("IVProgrammersPoint").style.display;

  // Register Keydown events:
  document.addEventListener("keydown", IVInterpretKey);

  // Start WebSocket
  wsLog('Version: ' + WEBSOCKETS_VERSION + '-' + WEBSOCKETS_SUBVERSION);
  wsLog('CONNECTING ' + wsURL + ' ...');
  let ws = new WebSocket(wsURL);

  // TODO
  // create timer: if "! connected" then try reconnect ...
  // setTimeout(function(),time);

  ws.onopen = function() {
    wsLog('CONNECTED');
    connected = true;
    wsImageVers();
    wsAlbumsList();
  };

  ws.onclose = function() {
    wsLog('DISCONNECT');
    connected = false;
    // TODO: reconnect, setInterval(), wsStart()
  };

  ws.onmessage = function(msg) {
    // Here, the output from image_viewer_server will be received.
    wsLog('B<-S MESSAGE: ' + msg.data);
    // Recognize Command:
    let str = msg.data;
    let sstr = str.split("=");
    let command = sstr[0];
    let content = sstr[1];
    // Do Command: /////////////////////////////////////////////////////////////
    if ( command == 'ACKN')
    {
      // at the moment, only one status is known:
      if ( content == 'Quit')
      {
        wsLog('B<-S Server has quit.');
      }
    }
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
      // TODO: Wie komme ich an die Informationen vom Kinder Fenster?
      //document.getElementById("IVTextInformationDate").textContent=filenameDate;
      wsLog(filenameDate);
      //document.getElementById("IVTextInformationTime").textContent=filenameTime;
      wsLog(filenameTime);
      //document.getElementById("IVTextInformationDim").textContent=filenameDimensions;
      wsLog(filenameDimensions);
      //document.getElementById("IVTextInformationCam").textContent=filenameCamera;
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
    if ( command == 'ALBJ')
    {
      // Print all used shortcuts and albumnames.
      AlbumsList(content);
    }
    if ( command == 'ALBS')
    {
      // Print all used shortcuts.
      wsLog('B<-S Shortcuts: ' + content);
    }
    if ( command == 'ASET')
    {
      // Print the global variable which define which album will be used with List* commands.
      wsLog('B<-S Album set: ' + content);
    }
    if ( command == 'AGET')
    {
      // Print the global variable which define which album will be used with List* commands.
      wsLog('B<-S Album get: ' + content);
    }
    if ( command == 'ALBC')
    {
      //
      wsLog('B<-S Album changed or created: ' + content);
      // Update UI:
      HideAlbums();
      wsAlbumsList();
    }
    if ( command == 'ALBD')
    {
      // Delete one Album
      wsLog('B<-S Album deleted: ' + content);
      // Update UI:
      HideAlbums();
      wsAlbumsList();
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
