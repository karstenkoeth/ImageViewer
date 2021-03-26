# ImageViewer
Images will be collected from all places on the filesystem and displayed in the browser

# Architecture
*html_collect_pictures.sh* scans the filesystem.

*image_viewer_startserver.sh* starts the server part. 

*index.html* is the main client part and contains the ui elements. He starts the algorithm client part *websockets.js*.
The ui style is mostly defined in *global.css*.
