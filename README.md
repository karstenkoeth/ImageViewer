# ImageViewer
Images will be collected from all places on the filesystem and displayed in the browser

# Architecture
`html_collect_pictures.sh` scans the filesystem. Main routine is located in 
*main* and starts after comment *Is Picture*.
Line 751: Check for doubles: But here we check only, if we have exactly that file in that location in the database.
If the file is doubled in another source folder, we will not find it.

`image_viewer_startserver.sh` starts the server part. 

`index.html` is the main client part and contains the ui elements. He starts the algorithm client part `websockets.js`.
The ui style is mostly defined in `global.css`.

## Folder Structure

### Database

`$HOME/Pictures/ImageViewer`

### Website

`$HOME/Sites/ImageViewer`

### Export Folder

`$HOME/tmp/ImageViewer/Export`

# Tests

## Find Double Images

One double image in the database is located at:

`/Users/koeth/tmp/test-dir/kristina-dobo-32213.jpg;kristina-dobo-32213.jpg;2018-02-08.22_44_15;4800;3264;File;`

`/Users/koeth/Pictures/Natur/kristina-dobo-32213.jpg;kristina-dobo-32213.jpg;2018-02-08.22_44_15;4800;3264;File;`

# TODO 

Check for doubles also in different spaces.
Better Code: Check in a function.
After enhancement: Adapt here in Readme in *Architecture* the documentation.
