Hangprinter ![Hangprinter logo](./logo_blue_50.png)
===========

This is the working branch of the Hangprinter repository.
Breaking changes may occur from time to time.
The Hangprinter repo does not yet have a stable branch.
This branch will become our (first!) stable branch when stock Marlin v2 is ready to be included as the default Hangprinter firmware.

This document and this repo are solely about technical aspects of Hangprinter version 3.
For more general information about the Hangprinter Project, refer to [hangprinter.org](https://hangprinter.org).

Bill of Materials
----------------
You can help fund future development of this project by using the affiliate links below when sourcing vitamins.
A Google Spreadsheet version for a Smart Stepper-driven setup, up to date as of Oct 10 2018, is found here: [Google docs](https://docs.google.com/spreadsheets/d/1lOPZoF1P2OSdJcijZRVrwAEVFh3LLAnf6-s6k-hlbZU/edit?usp=sharing)

Assembly Instructions
---------------------
The documentation hosted in this repo is published at [hangprinter.org/doc/v3](https://hangprinter.org/doc/v3).

Using Nema23?
----------------
Then you need different sized motor brackets, extruder holders and motor gears.
To compile those do
```
make nema23
```
This compiles the files and puts them in the `openscad_stl_nema23/` directory.
It also creates the `layout_nema23.dxf` file.
To make a 2d-printable pdf of the layout, do
```
make layout_nema23_a4.pdf
```

Using letter sized paper?
-------------------------
You can wedge that into the make-calls, like
```
make layout_letter.pdf
```
The following works if you're using nema23:
```
make layout_nema23_letter.pdf
```

The pdf creation command has been tested on a Ubuntu 14.04 system
with Cairosvg v1.0.4, sed v4.2.2, and Ghostscript v9.10.

Contributing Improvements
-------------------------
Your design improvements will help the rest of the community if you build your machine according to the files and instructions found in this repo.
The maintainers (me) are super grateful if you can structure your improvement into a merge request, and submit it to this repo on Gitlab.

The second best option is to make an issue here on Gitlab.

Lead Dev
---------------------------------
[tobben](https://torbjornludvigsen.com).

Campaign
---------------------------------
[Bountysource](https://salt.bountysource.com/teams/hangprinter)

Merchandise
---------------------------------
[Spreadshirt link for Sweden](https://shop.spreadshirt.se/hangprinter-merchandise/).
[Spreadshirt link for US](https://shop.spreadshirt.com/hangprinter-merchandise/).

Credits
-------
See [contributors](https://gitlab.com/tobben/hangprinter/graphs/Openscad_version_3) for committer stats.
Note that almost all ideas implemented by the commits have come up in conversations among fellow Reprappers.
None mentioned, none forgotten, but you know who you are.
Thanks!

This repo also contains external code from many places. Some of them:
* [Greg Frost gears](http://www.thingiverse.com/thing:3575)
* [Marlin firmware](https://github.com/MarlinFirmware/Marlin)
* [scad-utils](https://github.com/openscad/scad-utils)

Currently donating $25 or more:
* [Brooks Talley](https://www.bountysource.com/people/62525-brooks-talley)
* [David Lang](https://www.bountysource.com/people/50149-david-lang)
* [Delloman](https://www.bountysource.com/people/56602-delloman)

Lists sorted alphabetically.
