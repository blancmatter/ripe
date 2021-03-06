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


## Key files for information

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
  * Creates a stack of all 8 files to one photometric file, using `imarith` from CFITSIO.
  * Calls source extractor to find all sources in the field and saves the locations.
  * Calls source extractor for each of the 8 frames, using the field locations for apertures from the full stack.
  * Parses in each of the 8 text files created to determine Souce RA, Dec, Xpix, Ypix, Value and Error, plus any error flags.
  * Adds the information of the Observation to the `obs` table the database as a single entry.
  * Adds the information of every source in the field as a seperate entry in the `photdata` table of the database.
* Cleans up the local directory


### [standfind2](bin/standfind2)

This script goes through the database and identifies all sources which are standard stars (Zero Polarised or Polarised) or any science objects (i.e. GRBs). The objexts were specified in their RA and Dec and type in the file [standards.lst](config/standards/standards.lst) and imported into the standards table of the database for comparison using [stand](bin/stand).

Once the sources are identified, this allows polarisation calculation to be sped up by only calculating the interesting sources (especially importnat when doing monte carlo error analysis), and also for pulling out data (i.e. average q value during a certain date range for zero polarised sources, giving a stokes zero point).


### [polcalc](bin/polcalc)

polcalc basically takes the photometric data in the database and calculates the polarisation using the equations in [Clarke & Neumayer, 2002](https://core.ac.uk/download/pdf/1414641.pdf). A version for RINGO3, [polcalc_r3](bin/polcalc_r3), extends the functionality to dealing with data for 3 instruments with different stokes zero points and instrumental depolarisation.

Polcalc has a number of switches to run in different modes that were investigated during the PhD. `$calibrate` gives the options for setting the zero point. `$calibrate=3` calls the function `get_zeropoints()` from [ripe.pm](lib/ripe.pm)

```
sub get_zeropoints {
	# range is number of days either side of observation for which to take the zpol value
	(my $mjd, my $camera, my $range) = ($_[0], $_[1], $_[2]);

	$averages = $DB_grb->prepare("SELECT count(p), avg(A1/S1), avg(B1/S1), avg(C1/S1), avg(D1/S1), avg(A2/S1), avg(B2/S1), avg(C2/S1), avg(D2/S1), stddev(A1/S1), stddev(B1/S1), stddev(C1/S1), stddev(D1/S1), stddev(A2/S1), stddev(B2/S1), stddev(C2/S1), stddev(D2/S1), max(mjd) - min(mjd) from photdata, obs where obs_id_link=obs_id and object like '%zpol%' and abs(mjd-?) < ? and camera=? and target='U'") ;

	$averages->execute($mjd, $range, $camera);



	($num, $A1, $B1, $C1, $D1, $A2, $B2, $C2, $D2, $A1_err, $B1_err, $C1_err, $D1_err, $A2_err, $B2_err, $C2_err, $D2_err, $mjd_range) = $averages->fetchrow_array();


	if ($num < 3) {
		$range += 1;
		if ($DEBUG) {print "DBG --> get_zeropoints: Number of sources is $num, recalling with range $range\n";}
		($q_zeropoint, $u_zeropoint, $q_zeropoint_err, $u_zeropint_error) = get_zeropoints($mjd, $camera, $range);

	}

	else {

	($q_zeropoint, $u_zeropoint, $q_zeropoint_err, $u_zeropint_error) = stokes_calc($A1, $B1, $C1, $D1, $A2, $B2, $C2, $D2, $A1_err, $B1_err, $C1_err, $D1_err, $A2_err, $B2_err, $C2_err, $D2_err);

	}

	if ($DEBUG) {print "$num, $q_zeropoint, $u_zeropoint, $q_zeropoint_err, $u_zeropint_error, $mjd_range\n";}

	return($q_zeropoint, $u_zeropoint, $q_zeropoint_err, $u_zeropint_error);


}

```

This routine is called with date, range and the camera (d, e, f, p) which specifies the band. It then prepares an SQL query that finds all the identified zero polarised sources (target='U') observed within the range of the date. If there are less than 3 sources identified it will add one day to the range and rerun until there are more than 3 sources. Once there are more than 3 sopurces, the function takes the 8 flux and error values from the photometry to calculate and send back the stokes zero points of the instrument. This function worked well in defining the zero points and is the general switch.

With the zeropint and the error, polcalc can then give a corrected q and u values, and adds the q and u zeropoint errors in quaderature to the existing error amount. 

There is then an `$ellipse_correction` option to modify the polarisation value based on the angle. This uses values of ellipticity (E) and angle (theta), which have been determined from analysing polarisation rings formed by viewing polarised standard sources at mutiple sky angles.

**Polcalc does not correct for instrumental depolarisation** This linear term was generally introduced when using `grabdat` and multiplying the polarisation value and error by a constant factor.


### [grabdat](bin/grabdat)

grabdat enables the user to pull requersted information from the database and use in tabular format as a `.dat` file which could then be used with a gnuplot template to automate fast plotting of data from the database. Essentially it just passes the command line argument (SQL query) to the database and writes the results to a text file, with the column IDs at the top. It creates a queries.log file of each command run whilst in a particular working directory.

The command [regrab](bin/regrab) will then delete all the `.dat` files and rerun the queries for that working directory. This allowed modifcations and tweeks to be made to data analysis and then data and plots to be updated again quickly.


### [trumpet](bin/trumpet)

This script shows an example of `grabdat` being used to obtain source magnitude vs measured polarisation from the field of a GRB. This shows the deterioration of polarimetric accuracy as a reduduction. See [This File](120119A.pdf) for an example of instrumental magnitude vs measured polarisation in the field of GRB 120119A.
