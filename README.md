Hangprinter ![Hangprinter logo](./hangprinter_logo_blue_50.png)
===========

This is the version 4 dev branch of the Hangprinter repository.
Breaking changes occur all the time.
The Hangprinter repo does not yet have a stable branch, but the Openscad\_version\_3 branch is at least a bit less volatile than this one.

For more general information about the Hangprinter Project, refer to [hangprinter.org](https://hangprinter.org).

Bill of Materials
----------------
The BOM for the version 3 is found here: [Google docs](https://docs.google.com/spreadsheets/d/1lOPZoF1P2OSdJcijZRVrwAEVFh3LLAnf6-s6k-hlbZU/edit?usp=sharing).
The version 4 will use oDrives and BLDC motors instead of the steppers and Mechaduino/Smart Steppers.
It will also use DuetWifi instead of the Mega+RAMPS electronics.

Assembly Instructions
---------------------
Does not exist yet. Take a look at `layout_a4.pdf` though.

Using letter sized paper?
-------------------------
You can wedge that into the make-calls, like
```
make layout_letter.pdf
```

The pdf creation command requires Cairosvg, sed, and Ghostscript. Already installed on many standard GNU/Linux systems.

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
See [contributors](https://gitlab.com/tobben/hangprinter/graphs/version_4_dev) for committer stats.
Note that almost all ideas implemented by the commits have come up in conversations among fellow Reprappers.
None mentioned, none forgotten, but you know who you are.
Thanks!

This repo also contains external code from many places. Some of them:
* [droftarts' belt gear code](https://www.thingiverse.com/thing:16627)
* [Marlin firmware](https://github.com/MarlinFirmware/Marlin)

Currently donating $25 or more:
* [Brooks Talley](https://www.bountysource.com/people/62525-brooks-talley)
* [David Lang](https://www.bountysource.com/people/50149-david-lang)
* [Delloman](https://www.bountysource.com/people/56602-delloman)

Lists sorted alphabetically.
