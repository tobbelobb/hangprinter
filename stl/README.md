Before building, follow the [source setup instructions](../README.md#getting-the-source-files)
to download BOSL2 and install OpenSCAD. A plain clone or source ZIP omits BOSL2.

Make individual stls on your own by
 * Opening up the scad-files with OpenSCAD GUI and exporting from there

Or with `make`
 * `make stl/<thefileyouwant.stl>`
 * `make <thefileyouwant.stl>`,

... which will both place the stl inside the `hangprinter/stl/` directory.

Make all the stls on your own by
 * `make all` (this will take a long time),
