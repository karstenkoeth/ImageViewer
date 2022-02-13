# ImageViewer

Images will be collected from all places on the filesystem and displayed in the browser

## Architecture

`html_collect_pictures.sh` scans the filesystem. The main routine is located in
*main* and starts after comment *Is Picture*.
Line 751: Check for doubles: But here we check only, if we have exactly that file in that location in the database.
If the file is doubled in another source folder, we will not find it.

`image_viewer_startserver.sh` starts the server part.

`index.html` is the main client part and contains the ui elements. He starts the algorithm client part `websockets.js`.
The ui style is mostly defined in `global.css`.

## Dependencies

### In `html_collect_pictures.sh`

- `realpath` from gnu core utils
- `convert` from ImageMagick

### In `exif2html.sh`

- `exiftool`

## Folder Structure

In the source code `html_collect_pictures.sh` the most specifications are documented.

### Database

The databases are located in the folder `$HOME/Pictures/ImageViewer`.

#### Album Names

Relation between album shortcut (e.g. `N`) and album name (e.g. `Nature`)

Variable name: `ALBUMFILE`

Standard file name: `albumnames.csv`

#### Picture Information

Contains width and height with other picture information, e.g. `FULLFILENAME`.

Variable name: `DATABASEFILE`

Standard file name: `pictures.csv`

#### Picture File Names

Contains only `UUID` and `FULLFILENAME`

Variable name: `UUIDFILE`

Standard file name: `filenames.csv`

### Website

`$HOME/Sites/ImageViewer`

### Thumbnail Folder

This folder is located below the Website.

### Full HD Folder

This folder is located below the Website (or on an extra mass storage).

### Export Folder

`$HOME/tmp/ImageViewer/Export`

## Tests

### Find Double Images

One double image in the database is located at:

`/Users/koeth/tmp/test-dir/kristina-dobo-32213.jpg;kristina-dobo-32213.jpg;2018-02-08.22_44_15;4800;3264;File;`

`/Users/koeth/Pictures/Natur/kristina-dobo-32213.jpg;kristina-dobo-32213.jpg;2018-02-08.22_44_15;4800;3264;File;`

## TODO

Check for doubles also in different spaces.
Better Code: Check in a function.
After enhancement: Adapt here in Readme in *Architecture* the documentation.
Find doubles could run in background with low network load and low cpu load.
Before: Define main storage location.

How to deal with distributed storage solutions?

The main database is located in server "M" on disk "M".
This server makes fully automatically backups to disk "B"
Therefore, this server has to sync the database to other computers.
See picture "Network".
