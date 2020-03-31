// ///////////////////////////////////////////////////////////////////////////
//
// Run with tsc, maybe with options: --pretty --removeComments --watch
// or see tsconfig.json file

// ///////////////////////////////////////////////////////////////////////////
//
// Versions
//
// 2020-01-26 0.01 kdk First version
// 2020-02-27 0.02 kdk reload added but not tested.

var HTML_UPDATER_VERSION = "0.02";
var HTML_UPDATER_SUBVERSION = "00";

// ///////////////////////////////////////////////////////////////////////////
// 
// Links
// 
// See bash script html_updater_server.sh

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

// //////////////////////////////////////
//
// Init the websocket:
// Parameter: Nothing
// Return:    Nothing
function InitWebSocket()
{
    // ///////////////////////////////
    // Setup websocket with callbacks
    let serveripaddress = location.hostname;
    if ( serveripaddress == '' )
    {
        // Static variant:
        //let wsURL = 'ws://localhost:8081/';
        serveripaddress='localhost';
    }
    let wsURL = 'ws://'+serveripaddress+':8081/';

    //wsLog('[html_updater] Version: ' + HTML_UPDATER_VERSION + '-' + HTML_UPDATER_SUBVERSION);
    //wsLog('[html_updater] Connecting to ' + wsURL + ' ...');
    hu_ws = new WebSocket(wsURL);
}

// ///////////////////////////////////////////////////////////////////////////
//
// main
//

// Start WebSocket
let hu_ws;
let hu_connected : boolean = false;
let hu_logging : boolean = false;
InitWebSocket();

hu_ws.onopen = function() 
{
    //wsLog('[html_updater] CONNECTED');
    hu_connected = true;
};

hu_ws.onclose = function() 
{
    //wsLog('[html_updater] DISCONNECTED');
    hu_connected = false;
    // TODO: reconnect, setInterval(), wsStart()
};

hu_ws.onerror = function(msg)
{
    // The following errors occured:
    // [object event] --> The server was down.
    //wsLog('[html_updater] ERROR: ' + msg);
};

hu_ws.onmessage = function(msg) 
{
    // Here, the output from image_viewer_server will be received.
    //wsLog('[html_updater] MESSAGE: ' + msg.data);
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
            //wsLog('[html_updater] MESSAGE: Server has quit.');
        }
    }
    if ( command == 'RELD')
    {
        //wsLog('[html_updater] MESSAGE: Reload files.')
        // See: https://www.w3schools.com/jsref/met_loc_reload.asp
        location.reload();
    }
    if ( command == 'MAKE')
    {
        //wsLog('[html_updater] MESSAGE: Make started.')
    }
};
