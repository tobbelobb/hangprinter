Hangprinter ![Hangprinter logo](https://vitana.se/opr3d/tbear/bilder/logo_blue_50.png)
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
The maintainers (me) are super grateful if you can structure your improvement into a pull request, and submit it to this repo.
See for example [this page](https://stackoverflow.com/questions/14680711/how-to-do-a-github-pull-request#14681796) for help with creating a pull request.

If your improvement can't be structured into a pull request, the second best option is to make an issue here on GitHub, or to contact us via the
[forum thread](https://reprap.org/forum/list.php?423).

Supporting This Project With Money
----------------------------------
Monthly donations can be set up via the [Bountysource Salt Campaign](https://salt.bountysource.com/teams/hangprinter).

Merchandise can be bought here: [Mechadise Sweden](http://spreadshirt.se/shops/hangprinter-merchandise).
And here: [Mechadise US](http://spreadshirt.com/shops/hangprinter-merchandise).

Bitcoin donations are accepted on: 1BwobkC5Tb7psWkzCugtcH21ufj6Lc9mgY
... or in QR format:<br />![BTC Donations QR code](https://hangprinter.org/images/BTC_donations.png)

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
