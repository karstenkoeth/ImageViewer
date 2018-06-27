// ///////////////////////////////////////////////////////////////////////////
//
// Run with tsc, maybe with options: --pretty --removeComments --watch
// or see tsconfig.json file

// ///////////////////////////////////////////////////////////////////////////
//
// Versions
//
// 2018-03-08 0.01 kdk First version
// 2018-05-22 0.10 kdk With license text
// 2018-06-26 0.11 kdk With IVAlbumsClick
// 2018-06-27 0.12 kdk With Content in ...Click

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

function IVShowAlbums(obj)
{
  //obj.style.width = "160px";
  obj.style.background = "black";
  //window.alert(obj.style.width());
  //window.alert(obj);
}

function IVUnShowAlbums(obj)
{
  //obj.style.width = "320px";
  obj.style.background = "white";
}

function IVAlbumsClick(obj)
{
  wsLog("AlbumClicked");
  let node = document.createElement("DIV");
  node.className = "IValbumsDiv";
  let nodenode = document.createElement("P");
  nodenode.className = "IValbumsText";
  node.appendChild(nodenode);
  let textnode = document.createTextNode("Mein BlaBlub");
  nodenode.appendChild(textnode);
  document.getElementById("IValbumsRoot").appendChild(node);
}
