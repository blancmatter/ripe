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
This is the perl module, where many functions are written which are called by many other perl scripts which load this file as a module. The most important of these is '''sub db_connect()''' which hardcodes the database login credentials and allows any perl module to connect to the database. If the database is empty, then this function creates the necessary tables for storage of the polarimetric data. See this function for the SQL description of the tables.

Further to this there are a number of different functions required for poalrimetric calculation on data within the database.

### [ripe](bin/ripe) 
This is the key file for initial extraction of data and entry into the database. It is intended to be run in the same directory as the files for reduction.

Usage;
```
ripe <tag>
```
where <tag> is a unique identifier for the data entry. This tag must be provided. This tag allows the same data to be entered into the database with different reduction paramters (aperture size, etc) and extracted based on the settings used.

In short it;
* Checks the files in the local directory and looks at observations, checking there are 8 files for each.
* Connects to the database.
* For each observation;
  * Extracts information from the fits headers.
  * Calculates the gain of the exposure (required for sourceExtractor).
  * Creates a stack of all 8 files to one photometric file.
  * Calls source extractor to find all sources in the field and saves the locations.
  * Calls source extractor for each of the 8 frames, using the field locations for apertures from the full stack.
  * Parses in each of the 8 text files created to determine Souce RA, Dec, Xpix, Ypix, Value and Error, plus any error flags.
  * Adds the information of the Observation to the `obs` table the database as a single entry.
  * Adds the information of every source in the field as a seperate entry in the `photdata` table of the database.
* Cleans up the local directory


### [polcalc]
