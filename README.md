Hangprinter ![Hangprinter logo](./hangprinter_logo_blue_50.png)
===========

Welcome to the Hangprinter repository!

This branch contains Hangprinter version 4.
Breaking changes might occur from time to time.

For more general information about the Hangprinter Project, refer to [hangprinter.org](https://hangprinter.org).

Documentation
----------------
Start here: [hangprinter.org/doc/v4](https://hangprinter.org/doc/v4/).

Getting the source files
-----------------------
Install Git, then clone with submodules so the BOSL2 OpenSCAD library is included:

```sh
git clone --recurse-submodules https://gitlab.com/tobben/hangprinter.git
cd hangprinter
```

If you already cloned without `--recurse-submodules`, run this inside the repository:

```sh
git submodule update --init --recursive
```

`make setup` runs the same command. It downloads the library version recorded in
this repository and needs an internet connection the first time. After pulling
updates or switching branches, run it again to keep the library in sync.

GitLab/GitHub source ZIP downloads omit submodules. Use the Git clone above for
editing CAD. The models expect BOSL2 at `src/lib/BOSL2/`; installing it only in
OpenSCAD's global library directory won't fill that path.

Opening and building CAD
------------------------
Install OpenSCAD 2021.01 or later. Open a `.scad` file from `src/` in OpenSCAD,
preview it, then render and export it as STL. The RefWinch models live in
`src/refwinch/`, including `conventional_winch.scad`.

For command-line builds, install GNU Make and put `openscad` on your PATH.
On macOS, the Makefile uses `/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD`.
Run these commands from the repository root:

```sh
make check-deps
make spool.stl
```

The STL is written to `stl/spool.stl`. To use another OpenSCAD installation,
pass its executable path, for example:

```sh
make check-deps OPENSCAD_BIN=/path/to/openscad
make spool.stl OPENSCAD_BIN=/path/to/openscad
```

Models in subdirectories use the matching output path, for example
`make stl/refwinch/conventional_winch.stl`.

If OpenSCAD says it can't open `BOSL2/std.scad`, or reports unknown BOSL2
functions or modules, run `git submodule update --init --recursive` and preview
the model again. `make` checks for the library and required programs before building.


Using letter sized paper for the layout?
-------------------------
You can specify that in a make-call:
```
make layout_letter.pdf
```

Layout PDFs also require CairoSVG (the `cairosvg` command), sed, and Ghostscript
(the `gs` command). Check them with `make check-layout-deps`.
`make all` builds both the STLs and the A4 layout PDF, so it needs these programs too.

Contributing Improvements
-------------------------
We're super grateful for merge request.
Please submit to this repo on Gitlab.

The second best option for contributing improvements is to make an issue on Gitlab.

Lead Dev
---------------------------------
[tobben](https://torbjornludvigsen.com).

Campaign
---------------------------------
[Github Sponsors](https://github.com/sponsors/tobbelobb/)

Merchandise
---------------------------------
[Spreadshirt link for Sweden](https://shop.spreadshirt.se/hangprinter-merchandise/).
[Spreadshirt link for US](https://shop.spreadshirt.com/hangprinter-merchandise/).

Credits
-------
See [contributors](https://gitlab.com/tobben/hangprinter/graphs/version_4) for committer stats.
Note that almost all ideas implemented by the commits have come up in conversations among fellow Reprappers.
Thanks!

List sorted alphabetically.
