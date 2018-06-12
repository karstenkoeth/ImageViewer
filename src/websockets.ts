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
    wsLog('Send')
  }

  function wsImageVers()
  {
    ws.send('VERS');
    wsLog('VERS');
  }

  // ///////////////////////////////////////////////
  // Album

  // TODO: ALBS --> List all shortcuts into an array. Ask for every shortcut
  //                the albumname with ALBU=Shortcut.

  function AlbumSplit(content)
  {
    var slen=content.length;
    var stmp='';
    var pos=0;
    while ( pos<slen )
    {
      stmp=content.charAt(pos);
      if (stmp!=";")
      {
        // It Works
        // wsLog('Album Shortcut '+stmp);
        // Get AlbumName:
        ws.send('ALBU='+stmp)
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
  // Navigation

  function wsImagePos1()
  {
    ws.send('POS1');
    ws.send('FILE');
    ws.send('GIVE');
    ws.send('FALB');
    wsLog('POS1');
  }

  function wsImagePrev()
  {
    ws.send('PREV');
    ws.send('FILE');
    ws.send('GIVE');
    ws.send('FALB');
    wsLog('PREV');
  }

  function wsImageGoto()
  {
    ws.send('GOTO=358');
    ws.send('FILE');
    ws.send('GIVE');
    ws.send('FALB');
    wsLog('GOTO');
  }

  function wsImageNext()
  {
    ws.send('NEXT');
    ws.send('FILE');
    ws.send('GIVE');
    ws.send('FALB');
    wsLog('NEXT');
  }

  function wsImageLast()
  {
    ws.send('LAST');
    ws.send('FILE');
    ws.send('GIVE');
    ws.send('FALB');
    wsLog('LAST');
  }

  // ///////////////////////////////////////////////
  //
  // main
  //

  // ///////////////////////////////
  // Setup websocket with callbacks
  let serveripaddress = location.hostname;
  // Static variant:
  //let wsURL = 'ws://localhost:8080/';
  let wsURL = 'ws://'+serveripaddress+':8080/';
  // For Testing:
  //var wsURL = 'ws://echo.websocket.org';

  wsLog('CONNECTING ' + wsURL + ' ...')
  let ws = new WebSocket(wsURL);

  ws.onopen = function() {
    wsLog('CONNECTED');
    wsImageVers();
  };

  ws.onclose = function() {
    wsLog('DISCONNECT');
  };

  ws.onmessage = function(msg) {
    // Here, the output from image_viewer_server will be received.
    wsLog('MESSAGE: ' + msg.data);
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
      AlbumSplit(content);
    }
    if ( command == 'ALBU')
    {
      // ALBU - Print the Album Name to a given Album Shortcut
      // TODO: Irgendwie anzeigen. Und zwar die Albumnamen anzeigen, nicht die Shortcuts.
      wsLog('AlbumName: '+content);
    }
  };

  ws.onerror = function(msg)
  {
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
