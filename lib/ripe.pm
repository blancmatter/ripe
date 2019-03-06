package ripe;

# Set to local directory
$basepath=`pwd`;
chomp $basepath;
$ripedir = "/ripe";
$DEBUG = 0;

use DBI;
use DBD::mysql;
use Math::Trig;
use Math::Complex;
$pi = 3.141592;

#$database = "grbs";
#$database = "test";
$database = "standards";
#$database = "R3_stand";q

sub cleanup {
 # Clean up directory of all unwanted files

 #unlink glob "*.sex";
 #unlink glob "*.param";


}

sub calcpol {

	# Takes in array of a1, b1, c1, d1, a2, b2, c2, d2
	my $s1 = $_[0] + $_[1] + $_[2] + $_[3] + $_[4] + $_[5] + $_[6] + $_[7];
	my $s2 = $_[0] + $_[4] + $_[1] + $_[5];
	my $s3 =  $_[1] + $_[5] + $_[2] + $_[6];

	my $q = $pi * (0.5 - ($s3/$s1));
	my $u = $pi * (($s2/$s1) - 0.5);
	my $pol = sqrt(($q**2)+($u**2));
	return ($pol);


}



sub calc_S1 {
	# A number of tasks such as standfind, polcalc with moving zeropint mode etc require a value of S1 for each

	$DB_grb->do("UPDATE photdata SET S1 = A1 + A2 + B1 + B2 + C1 + C2 + D1 + D2, S2 = A1 + A2 + B1 + B2, S3 = B1 + B2 + C1 + C2  ");


}


sub db_connect {

#############################
# Details of free online db #
#############################
# Host: sql2.freemysqlhosting.net
# Database name: sql284896
# Database user: sql284896
# Database password: zD4!kZ1*
# Port number: 3306
##############################


  # CONFIG VARIABLES
  $platform = "mysql";

  # $user = "sql284896";
    $user = "ripe";
  # $pw = "zD4!kZ1*";
    $pw = "ripe";

  #DATA SOURCE NAME
  $dsn = "dbi:mysql:$database";  #:localhost:3306
#  $dsn = "dbi:mysql:sql284896:sql2.freemysqlhosting.net";  #:localhost:3306

  #Connect to db
  $DB_grb = DBI->connect($dsn, $user, $pw)
  or die "Cannot connect to database\n";

  #Events table
 # $DB_grb->do("
 # CREATE TABLE IF NOT EXISTS events (
 # grb_id VARCHAR(16),
 # t_trig INT(32),
 # moon_stat ENUM('U','D'),
 # moon_frac FLOAT(2,0),
 # moon_dist FLOAT(5,3),
 # moon_alt FLOAT(5,3),
 # xrt_ra_deg FLOAT(5,3),
 # xrt_dec_deg FLOAT(5,3),
 # primary KEY (grb_id))")
 # or die "Could not Create Table: $DBI::errstr";

  #Obs table
  $DB_grb->do("
  CREATE TABLE IF NOT EXISTS obs (
  obs_id VARCHAR(30),
  camera ENUM ('p', 'd', 'e', 'f'),
  tag VARCHAR(16),
  object VARCHAR(40),
  date VARCHAR(8),
  mjd FLOAT (10,3),
  wcs_ra FLOAT(8,4),
  wcs_dec FLOAT(8,4),
  alt FLOAT(8,4),
  az FLOAT(8,4),
  rotmount FLOAT(5,3),
  rotskypa FLOAT (6,3),
  ut_start VARCHAR(14),
  t_exp FLOAT(10,4),
  t_dur FLOAT(10,4),
  moon_alt INT(16),
  moon_dist INT(16),
  moon_frac FLOAT(4,2),
  numfrms INT(16),
  gain FLOAT(10,5),
  apsize INT(16),
  backsize INT(16),
  primary KEY (obs_id, tag))")
  or die "Could not Create Table: $DBI::errstr";

  # create phot table
  $DB_grb->do("
  CREATE TABLE IF NOT EXISTS photdata (
  id INT (16) primary key auto_increment,
  obs_id_link VARCHAR(22),
  tag_link VARCHAR(16),
  target CHAR(1),
  target_dist INTEGER,
  target_score INTEGER,
  xpix FLOAT(6,3),
  ypix FLOAT(6,3),
  ra FLOAT(8,5),
  decn FLOAT(8,5),
  A1 FLOAT(12,3),
  B1 FLOAT(12,3),
  C1 FLOAT(12,3),
  D1 FLOAT(12,3),
  A2 FLOAT(12,3),
  B2 FLOAT(12,3),
  C2 FLOAT(12,3),
  D2 FLOAT(12,3),
  A1_err FLOAT(12,3),
  B1_err FLOAT(12,3),
  C1_err FLOAT(12,3),
  D1_err FLOAT(12,3),
  A2_err FLOAT(12,3),
  B2_err FLOAT(12,3),
  C2_err FLOAT(12,3),
  D2_err FLOAT(12,3),
  flag INT(8),
  S1 FLOAT(13,3),
  S2 FLOAT(13,3),
  S3 FLOAT(13,3),
  q FLOAT(7,6),
  u FLOAT(7,6),
  q_err FLOAT(7,6),
  u_err FLOAT(7,6),
  p FLOAT(4,3),
  p_err_minus FLOAT(4,3),
  p_err_plus FLOAT(4,3),
  beta INT(16),
  beta_err INT(16))");

 # Standards table
 $DB_grb->do("
  CREATE TABLE IF NOT EXISTS standards (
  object_id VARCHAR(26),
  stand_ra FLOAT(8,5),
  stand_dec FLOAT(8,5),
  type CHAR(1),
  mag FLOAT(5,3),
  v_pol FLOAT (5,4),
  r_pol FLOAT (5,4),
  primary KEY (object_id, type))")
  or die "Could not Create Table: $DBI::errstr";

}

sub fitsdat {

  # Grab following FITS header data
  # parse to values and return following array



  ###############################
  # [0] OBJECT                  #
  # [1] DATE                    #
  # [2] Modified Julian Date    #
  # [3] RA (WCS Ref Pixel) (deg)#
  # [4] DEC (WCS ref Pixel)(deg)#
  # [5] ALTITUDE   (deg)        #
  # [6] AZIMUTH    (deg)        #
  # [7] ROTANGLE   (deg)        #
  # [8] ROTSKYPA   (deg)        #
  # [9] UTSTART    (ut sec)     #
  # [10] EXPTIME    (sec)       #
  # [11] DURATION  (sec)        #
  # [12] MOONALT (deg)          #
  # [13] MOONDIST (deg)         #
  # [14] MOONFRAC (percent)     #
  ###############################


  # TODO
  # UT start in seconds would be good.


    # Clear return array frrom previous runs
    undef @return;

    $obj = `modhead $_[0] object`;
    chomp $obj;
    ($null, $obj, $null) = split(/'/, $obj);
    push (@return, $obj);
    if ($DEBUG) { print "$obj\n";}

    $date = `modhead $_[0] date | sed 's/[^0-9]*//g' `;
    chomp $date;
    push (@return, $date);
    if ($DEBUG) { print "Date: $date\n";}

    $mjd = `modhead $_[0] mjd | sed 's/[^0-9.]*//g' `;
    chomp $mjd;
		$mjd = sprintf("%.2f", $mjd);
    push (@return, $mjd);
    if ($DEBUG) { print "MJD: $mjd\n";}

    $ra = `modhead $_[0] ra | sed 's/[^0-9:.]*//g'`;
    chomp $ra;
    if ($DEBUG) { print "RA: $ra\n";}
    $ra = ra2angle($ra);
    push (@return, $ra);
    if ($DEBUG) { print "RA: $ra\n";}

    $dec = `modhead $_[0] dec | sed 's/[^0-9:.+-]*//g'`;
    chomp $dec;
    $dec = dec2angle($dec);
    push (@return, $dec);
    if ($DEBUG) { print "Dec: $dec\n";}

    $alt = `modhead $_[0] altitude | sed 's/[^0-9.]*//g'`;
    chomp $alt;
    push (@return, $alt);
    if ($DEBUG) { print "Alt: $alt\n";}

    $az = `modhead $_[0] azimuth | sed 's/[^0-9.]*//g'`;
    chomp $az;
    push (@return, $az);
    if ($DEBUG) { print "Az: $az\n";}

    $rotmount = `modhead $_[0] rotangle | sed 's/[^0-9.+-]*//g'`;
    chomp $rotmount;
    push (@return, $rotmount);
    if ($DEBUG) { print "Rotmount: $rotmount\n";}

    $rotsky = `modhead $_[0] rotskypa | sed 's/[^0-9.+-]*//g'`;
    chomp $rotsky;
    push (@return, $rotsky);
    if ($DEBUG) { print "Rotsky: $rotsky\n";}

    $t_start = `modhead $_[0] utstart| sed 's/[^0-9:.]*//g'`;
    chomp $t_start;
    push (@return, $t_start);
    if ($DEBUG) { print "$t_start\n";}

    $t_exp = `modhead $_[0] exptime | sed 's/[^0-9.]*//g'`;
    chomp $t_exp;
    push (@return, $t_exp);
    if ($DEBUG) { print "$t_exp\n";}

    $t_dur = `modhead $_[0] duration | sed 's/[^0-9:.]*//g'`;
    chomp $t_dur;
		print "VALUE: t_dur is $t_dur\n";
    push (@return, $t_dur);
    if ($DEBUG) { print "$t_dur\n";}

    $moon_alt = `modhead $_[0] moonalt | sed 's/[^0-9:.+-]*//g'`;
    chomp $moon_alt;
    push (@return, $moon_alt);
    if ($DEBUG) { print "$moon_alt\n";}

    $moon_dist = `modhead $_[0] moondist | sed 's/[^0-9:.+-]*//g'`;
    chomp $moon_dist;
    push (@return, $moon_dist);
    if ($DEBUG) { print "$moon_dist\n";}

    $moon_frac = `modhead $_[0] moonfrac | sed 's/[^0-9:.+-]*//g'`;
    chomp $moon_frac;
    push (@return, $moon_frac);
    if ($DEBUG) { print "$moon_frac\n";}

    return (@return);


}

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

sub getgain {
  # Read the current gain value from the Source extractor config file
  $foundgain = `cat $ripedir/config/sex/ripe.sex | grep GAIN | sed 's/[^0-9.]*//g'`;
  chomp $foundgain;
  return ($foundgain);
}

sub get_calibrations {
	# Sub to return calibrations based on date from config file
	# INPUT --> date in format YYYYMMDD
	# RETURNS --> values of 8 inst pol calibrations


	$line = `cat $ripe::ripedir/config/instpol_r2.dat | grep '$_[0]\t'`;

	if (!$line) {
		print "Error: get_calibrations --> Line not found for date: $_[0]\n";
		return ();
	}

	($null, $A1_correction, $B1_correction, $C1_correction, $D1_correction, $A2_correction, $B2_correction, $C2_correction, $D2_correction) = split ('\t', $line);

	# check that the sum is close to 8
        $paritycheck = abs($A1_correction + $B1_correction + $C1_correction + $D1_correction + $A2_correction + $B2_correction + $C2_correction + $D2_correction - 8);


	if ($paritycheck >= 0.002) {
		print "Error: get_calibrations --> Parity check = $paritycheck for date: $_[0] in $ripe::ripedir/config/instpol_r2.dat\n";
		return ();
	}


	return ($A1_correction, $B1_correction, $C1_correction, $D1_correction, $A2_correction, $B2_correction, $C2_correction, $D2_correction);

}

sub jumble {
	if ($#_ != 7) {print "Error: jumble --> no of args not equal to 8\n"; die;}


	open FILE, "/home/disrail/ripe/config/combin.dat" or die;

	# set local variable for counter

	my $i = 0;

	while ($line = <FILE>) {

		chomp $line;
		($a, $b, $c, $d, $e, $f, $g, $h) = split(',',$line);
		if ($a != '#') {

			my $a1=$_[$a-1];
			my $b1=$_[$b-1];
			my $c1=$_[$c-1];
			my $d1=$_[$d-1];
			my $a2=$_[$e-1];
			my $b2=$_[$f-1];
			my $c2=$_[$g-1];
			my $d2=$_[$h-1];



			$pol[$i] = calcpol($a1, $b1, $c1, $d1, $a2, $b2, $c2, $d2) / 0.75;
			$i++;

		}
	}
	if ($DEBUG) {print "jumble --> Returning array of $#pol polarisations\n";}
	return (@pol);
}

sub moonstate {
	# used to recreate moon data in fits files
	# $_[0] is the filename

	if (-e $_[0]) {
		$date = `modhead $_[0] date | sed 's/[^0-9]*//g' `;
		chomp $date;
		substr($date,6,0)='-';
		substr($date,4,0)='-';
		if ($DEBUG) { print "Date: $date\n";}


		$ra = `modhead $_[0] ra | sed 's/[^0-9:.]*//g'`;
		chomp $ra;
		if ($DEBUG) { print "RA: $ra\n";}
		($ra_hr, $ra_min, $ra_sec) =  split (':',$ra);
		$ra = ($ra_hr * 15) + ($ra_min / 4) + ($ra_sec / 240);
		if ($DEBUG) { print "RA: $ra\n";}

		$dec = `modhead $_[0] dec | sed 's/[^0-9:.+-]*//g'`;
		chomp $dec;
		($dec_deg, $dec_min, $dec_sec) =  split (':',$dec);
		$dec = $dec_deg + ($dec_min / 60) + ($dec_sec / 3600);
		if ($DEBUG) { print "Dec: $dec\n";}

		$t_start = `modhead $_[0] utstart| sed 's/[^0-9:.]*//g'`;
		chomp $t_start;
		if ($DEBUG) { print "UT Start:$t_start\n";}

	}

	 else
	{
		print "Error: File $file does not exist\n";
		exit();
	}


	$moonstate = `moonephem "$date $t_start"`;
	print $moonstate;

	($moon_ra, $moon_dec, $moon_alt, $moon_frac) = split (' ',$moonstate);

	# Covert from hh:mm:ss and dd:mm:ss into degrees
	$moon_ra  = ripe::ra2angle($moon_ra);
	$moon_dec = ripe::dec2angle($moon_dec);
	$moon_alt = ripe::dec2angle($moon_alt);

	# Calculated for spherical co-ordinates, with all values converted to radians for the calculation then back again. It works! It's been tested.....
	$moon_dist = acos ((sin($dec / 360 * 2 * $pi) * sin($moon_dec / 360 * 2 * $pi)) + (cos($dec / 360 * 2 * $pi) * cos($moon_dec / 360 * 2 * $pi) * cos(($ra / 360 * 2 * $pi) - ($moon_ra / 360 * 2 * $pi)))) * 360 / 2 / $pi;

	#reduce to 3 decimal places
	$moon_dist = sprintf("%.2f", $moon_dist);
	$moon_alt = sprintf("%.2f", $moon_alt);
	$moon_frac = sprintf("%.2f", $moon_frac);




	if ($DEBUG) {
		print "Moon RA: $moon_ra\n";
		print "Moon Dec: $moon_dec\n";
		print "Moon Alt: $moon_alt\n";
		print "Moon Frac: $moon_frac\n";
		print "Moon Dist: $moon_dist\n";
	}

	$insert = `modhead $_[0] moonfrac $moon_frac; modhead $_[0] moondist $moon_dist; modhead $_[0] moonalt $moon_alt` ;

}

sub ra2angle {
    ($ra_hr, $ra_min, $ra_sec) =  split (':',$_[0]);
    $ra_deg = ($ra_hr * 15) + ($ra_min / 4) + ($ra_sec / 240);
    return ($ra_deg);
}

sub dec2angle {
    ($dec_deg, $dec_min, $dec_sec) =  split (':',$_[0]);
	if ($dec_deg < 0){
		$dec = ($dec_deg - ($dec_min / 60) - ($dec_sec / 3600));

	}
	else {
	$dec = ($dec_deg + ($dec_min / 60) + ($dec_sec / 3600));

	}

    return ($dec);

}

sub mc_old {
	#old implementation of mc error, which took 1 sigma limits of the asymmetrical distribution. Not really mc!
	$iterations = 1000;
	$q_val = $_[0];
	$u_val = $_[1];
	$q_err = $_[2];
	$u_err = $_[3];

	$p_val = sqrt(($q_val**2) + ($u_val**2));
	for ($i=0; $i<$iterations; $i+=1) {
		$q_array[$i] = randnorm($q_val, $q_err);
		$u_array[$i] = randnorm($u_val, $u_err);
		$p_array[$i] = sqrt (($q_array[$i]**2) + ($u_array[$i]**2));
		#print "$q_array[$i]\t$u_array[$i]\t$p_array[$i]\n";
	}

	@p_array_sort = sort @p_array;


	$p_err_lower = $p_val - $p_array_sort[0.1587 * $iterations];
	$p_err_upper = $p_array_sort[0.8413 * $iterations] - $p_val;


	return($p_val, $p_err_lower, $p_err_upper);
}

sub mcerror {
	# This calls Iain's ringoerror.py

	# Convert from stokes to percent
	$q_val = $_[0] * 100;
	$u_val = $_[1] * 100;
	$q_err = $_[2] * 100;
	$u_err = $_[3] * 100;


	$mcresult = `ringoerror.py $q_val $u_val $q_err $u_err`;
	#$debug = `ringoerror.py $q_val $u_val $q_err $u_err >> repy_bgd.txt`;


	($p_val, $p_val_corrected, $p_min, $p_max) = split(' ', $mcresult);

	if ($DEBUG) {
		print "$p_val, $p_val_corrected, $p_min, $p_max\n";
	}


	$p_err_lower = $p_val_corrected - $p_min;
	$p_err_upper = $p_max - $p_val_corrected;

	#If value determination failed due to low polarisations mixed with high errors then return impossible values as the error string
	if ($p_val_corrected == 0) {
		$p_val_corrected = 999;
		$p_err_lower = 999;
		$p_err_upper = 999
	}

	# Return from percent to values
	return(($p_val_corrected/100), ($p_err_lower/100), ($p_err_upper/100));

}

sub mc_angle {

	# Convert from stokes to percent, which is not neccessary for angle, but for unity with ringoerror.py
	$q_val = $_[0] * 100;
	$u_val = $_[1] * 100;
	$q_err = $_[2] * 100;
	$u_err = $_[3] * 100;


	$mcresult = `ringoangle.py $q_val $u_val $q_err $u_err`;

	($beta, $beta_corrected, $beta_min, $beta_max) = split(' ', $mcresult);

	if ($DEBUG) {
		print "$beta, $beta_corrected, $beta_min, $beta_max";
	}


	$angle_err_lower = $beta_corrected - $beta_min;
	$angle_err_upper = $beta_max - $beta_corrected;

	# Return from percent to values
	return($beta_corrected, $beta_err_lower, $beta_err_upper);



}

sub mcerror_doug {
	# This script creates multiple polarisation distributions within a parameter space  along the axis of polarisation, of upto 50% polarisation
	# q = -0.5 --> +0.5
	# u = -0.5 --> +0.5
	# Each distribution is checked against the errors on measured q and u values
	# If a distribution is valid, then it's most likely polarisation value is valid and the errors are extended to include this.




	$iterations = 1000;
	$p_min = 1;
	$p_max = 0;
	$q_val = $_[0];
	$u_val = $_[1];
	$q_err = $_[2];
	$u_err = $_[3];

	#print "$q_val\t$u_val\t$q_err\t$u_err\n";

	# The monte carlo runs along the axis of polarisation. We assume the polarisation angle is correct?
	$vector = $u_val / $q_val;

	$p_val = sqrt(($q_val**2) + ($u_val**2));


	for ($q_sim = 0; $q_sim <= 1; $q_sim += 0.01) {

		$u_sim = $q_sim * $vector;

		$p_sim = sqrt(($q_sim**2) + ($u_sim**2));


		for ($i=0; $i<$iterations; $i+=1) {
			$q_array[$i] = randnorm($q_sim, $q_err);
			$u_array[$i] = randnorm($u_sim, $u_err);
			$p_array[$i] = sqrt (($q_array[$i]**2) + ($u_array[$i]**2));

		}

		@p_array_sort = sort @p_array;
		$p_sim_lower = $p_sim - $p_array_sort[0.1587 * $iterations];
		$p_sim_upper = $p_array_sort[0.8413 * $iterations] - $p_sim;

		if ($p_array_sort[0.1587 * $iterations] < $p_val && $p_array_sort[0.8413 * $iterations] > $p_val) {
			if ($p_sim > $p_max) { $p_max = $p_sim;}
			if ($p_sim < $p_min) { $p_min = $p_sim;}


		}


	}
	if ($p_max == 0 && $p_min == 1) {
		# We never broke into the limits of 1 sigma in a MC distribution
		$p_min = 0;
	}

	# Fudge term for upper limits if not detected...
	if ($p_max < $p_val) {$p_max = $p_val + $q_err};

	$p_err_lower = $p_val - $p_min;
	$p_err_upper = $p_max - $p_val;
	return($p_val, $p_err_lower, $p_err_upper);

}

sub mcerror_drejc {
	# This script creates multiple polarisation distributions

	$q_val = $_[0];
	$u_val = $_[1];
	$q_err = $_[2];
	$u_err = $_[3];

	$output = `Drejc_MC_error.py $q_val $u_val $q_err $u_err`;
	($p_val, $p_err_lower, $p_err_upper) = split (' ',$output);


	return($p_val, $p_err_lower, $p_err_upper);

}

sub numfrms {
  # Read the current gain value from the Source extractor config file
  $numfrms = `listhead $_[0] | grep NUMF | sed 's/[^0-9]*//g'`;
  chomp $numfrms;
  return ($numfrms);
}

sub setgain {
  #takes a file and looks at the number of frames, then sets the gain value in source extractor
  $numfrms = `listhead $_[0] | grep NUMF | sed 's/[^0-9]*//g'`;
  $gain = $numfrms * 0.36;
  $shell = `cat $ripedir/config/sex/ripe.sex > $ripedir/config/sex/ripeold.sex`;
  $shell = `cat $ripedir/config/sex/ripeold.sex | sed '/GAIN/d' > $ripedir/config/sex/ripe.sex`;
  $shell = `echo 'GAIN             $gain' >> $ripedir/config/sex/ripe.sex`;
}

sub r3_trim {
	#Sub to ditch any detected sources in the vignetted region of RINGO3

	# Centre of 50% non vignetted region is x=256 y=306 and with radii 280 and 270 pixels respectively for e and f


	$delete_e = $DB_grb->prepare("delete p from photdata p left join obs o on o.obs_id = p.obs_id_link where camera='e' and sqrt((abs(p.xpix-256)*abs(p.xpix-256))+(abs(p.ypix-306)*abs(p.ypix-306))) > 260");

	$delete_f = $DB_grb->prepare("delete p from photdata p left join obs o on o.obs_id = p.obs_id_link where camera='f' and sqrt((abs(p.xpix-256)*abs(p.xpix-256))+(abs(p.ypix-306)*abs(p.ypix-306))) > 260");


	$delete_e->execute();
	$delete_f->execute();

}

sub randnorm {
	# Called multiple times will create a normal distribution of FWHM $_[1] centred on $_[0]
	$num = $_[0] + $_[1] * sqrt(-2 * log rand) * cos(2 * $pi * rand);
	return ($num);
}

sub sexcompanion {
	# Sexcompanion -> find companion source from another sextractor output file and return the line
	# Input --> xpix ypix companionfile

	open companionfile, $_[2] or die $!;
	while ($line = <companionfile>)  {
		($xpix, $ypix, $counts, $counts_err, $ra, $dec, $flag) = split(" ",$line);

		if ( abs($xpix - $_[0]) < 2 && abs($ypix - $_[1]) < 2) {
			return ( $xpix, $ypix, $counts, $counts_err, $ra, $dec, $flag);
		}
	}
	# if we don't find the source
	return ("notfound");

}

sub skyangle_correct {
	#Take the sky angle in the database and make it in the range 0 to 360
	# DEPRECIATED??? Just use Mod function "%"  in mysql i.e. (beta+rotskypa) % 180

	my $grab = $DB_grb->prepare('Select obs_id, rotskypa from obs');

	my $input = $DB_grb->prepare('UPDATE obs set rotskypa = ? where obs_id = ?');

	$grab->execute();
	while (@data = $grab->fetchrow_array()) {
		my $obs_id = $data[0];
		my $rotsky = $data[1];

		if ($debug) {print "$rotsky\n";}

		if ($rotsky < 0) {
			$rotsky += 360;
		}

		if ($rotsky > 180) {
			$rotsky -= 180;

		}
		$input->execute($rotsky, $obs_id);
	}
}

sub stokes_calc{

	if ($#_ != 15) {print "Error: stokes_calc\tNot the correct numbert of inputs"; die;}



	$a1 = $_[0];
	$b1 = $_[1];
	$c1 = $_[2];
	$d1 = $_[3];
	$a2 = $_[4];
	$b2 = $_[5];
	$c2 = $_[6];
	$d2 = $_[7];
	$a1_err = $_[8];
	$b1_err = $_[9];
	$c1_err = $_[10];
	$d1_err = $_[11];
	$a2_err = $_[12];
	$b2_err = $_[13];
	$c2_err = $_[14];
	$d2_err = $_[15];


	if ($DEBUG) {print "DBG --> stokes_calc:@_\n";}


	$s1 = $a1 + $a2 + $b1 + $b2 + $c1 + $c2 + $d1 + $d2;
	$s2 = $a1 + $a2 + $b1 + $b2;
	$s3 = $b1 + $b2 + $c1 + $c2;

	$s1_err = sqrt(($a1_err**2)+($a2_err**2)+($b1_err**2)+($b2_err**2)+($c1_err**2)+($c2_err**2)+($d1_err**2)+($d2_err**2));
	$s2_err = sqrt(($a1_err**2)+($a2_err**2)+($b1_err**2)+($b2_err**2));
	$s3_err = sqrt(($b1_err**2)+($b2_err**2)+($c1_err**2)+($c2_err**2));

	if ($DEBUG) {print "DBG --> stokes_calc:S1:$s1\nS2:$s2\nS3:$s3\n";}
	# calculate q and u
	my $q = $pi * (0.5 - ($s3/$s1));
	my $u = $pi * (($s2/$s1) - 0.5);

	my $q_err = $pi * sqrt( (($s3_err / $s1)**2) + (($s1_err * $s3 / ($s1**2))**2));
	my $u_err = $pi * sqrt( (($s2_err / $s1)**2) + (($s1_err * $s2 / ($s1**2))**2));

	return($q, $u, $q_err, $u_err);

}




sub field_correct {
	# Correct field for off axis polarisation by returning value of modification

	$xpix = $_[0];
	$ypix = $_[1];

	if ($xpix < 9) {$xpix = 9;}
	if ($xpix > 504) {$xpix = 504;}
	if ($ypix < 9) {$ypix = 9;}
	if ($ypix > 504) {$ypix = 504;}

	$sth = $ripe::DB_grb->prepare("SELECT p - 0.717669 from r2_sky.photdata where abs(xpix - $xpix) < 2.51 and abs(ypix - $ypix) < 2.51");

	$sth->execute();

	$mod_value = $sth->fetchrow_array();

	return ($mod_value);
}





sub photstack {
	# take in 8 RINGO2/3 images and create a stacked file for photometry
	# at the moment imarith is not working.......
	$do = `imarith $_[0] $_[1] add add1.fit`;
	$do = `imarith add1.fit $_[2] add add2.fit`;
	$do = `imarith add2.fit $_[3] add add3.fit`;
	$do = `imarith add3.fit $_[4] add add4.fit`;
	$do = `imarith add4.fit $_[5] add add5.fit`;
	$do = `imarith add5.fit $_[6] add add6.fit`;
	$do = `imarith add6.fit $_[7] add add7.fit`;

	$do = `mv add7.fit $_[8]`;
	#unlink glob "add*";
}

sub t_minus_tzero {
	# Take in two values of time in hh:mm:ss and calculate the time between them in seconds

	$t_zero = $_[0];
	$t_obs = $_[1];

	($tz_hr, $tz_min, $tz_sec) = split (':',$t_zero);
	($to_hr, $to_min, $to_sec) = split (':',$t_obs);



	$t_zero = ($tz_hr * 3600) + ($tz_min * 60) + $tz_sec;
	$t_obs = ($to_hr * 3600) + ($to_min * 60) + $to_sec;

	if ($DEBUG) {
		print "t_minus_tzero: t_zero = $t_zero seconds\n";
		print "t_minus_tzero: t_obs  = $t_obs seconds\n";
	}

	# Correct for bursts and observations that straddle different days by one.

	if ($tz_hr > $to_hr) {

		if ($DEBUG) { print "t_minus_tzero: Split days --> recalculating\n" }

		$t_zero -= 86400;

	}


	$t_minus_tzero = $t_obs - $t_zero;

	return ($t_minus_tzero);
}

sub test_sub {
	# a test sub for testing inputs, return etc
	@input = @_;

	# does number of elements in input array work??
	print "$#_\t@_\n";





}

#need Perl Module to end with 1
1;
