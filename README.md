# ripe

ripe - Ringo Integrated Polarimetric Extractor, was a collection of scripts and tools used for polarimetric data reduction of observations taken with [RINGO2](https://telescope.livjm.ac.uk/TelInst/Inst/RINGO2/) and [RINGO3](https://telescope.livjm.ac.uk/TelInst/Inst/RINGO3/) polarimeters on the [Liverpool Telescope](https://telescope.livjm.ac.uk/). It was used during a PhD, and was maintainable and usable by the author only.

## Overview

The pipeline took FITS data from the telescope archive which had already been diabased, dark corrected and flat fielded. This was then analysed into a database and tools provided to calculate the polarisation, applying various corrections for instrumental polarisation and depolarisation.

The pipline uses the following technologies;
* Perl as the scripting language for calculation and calling of other routines
* Python for Calulcations of Moon Position and also for Monte Carlo analysis of errors
* [sExtractor](https://www.astromatic.net/software/sextractor) for photometric extraction
* [CFITSIO](https://heasarc.gsfc.nasa.gov/fitsio/) for basic tools to extract fits headers, but also to bin data for polarisation flat fielding.
* MySQL as a database for extracted information


## Key Files for understanding the Pipleline 

### [ripe.pm](https://github.com/blancmatter/ripe/blob/master/lib/ripe.pm)

### [ripe](https://github.com/blancmatter/ripe/blob/master/bin/ripe) 
This is the key file 
Editing ripe_README.md at master · blancmatter_ripe
