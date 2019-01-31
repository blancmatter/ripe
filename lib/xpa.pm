package xpa;

# Perl library to make xpa calls simpler





sub start_ds9 {
	
	system("ds9 &");
	sleep 5;
	#my $start = `ds9 &`;
}



sub open_file {
	# takes in obs_id from ripe database
	
	my $obs_id = $_[0];
	
	$obs_id .= 'F_1.fits';
	
	if (-e $obs_id) {
		system ("xpaset -p ds9 file $obs_id; xpaset -p ds9 scale zscale; xpaset -p ds9 zoom to fit"); 
	}
	
	else
	
	{
		print "Error --> XPA --> open_file: Tried to open $obs_id, but does not exist.\n";
		die;

	}
}


sub load_regions {
	# take in 2d array with xpix, ypix, and standardname
	@array = @_;
	
	for (my $i = 0; $i <= $#array; $i++) {
		
		system("echo 'circle $array[$i][0] $array[$i][1] 10' | xpaset ds9 regions");
		$array[$i][1] += 18;
		system("echo 'text $array[$i][0] $array[$i][1] # text={$array[$i][2]}' | xpaset ds9 regions");
	}
}


sub disp_region {
	
	@array = @_;

	system("echo 'circle $array[0] $array[1] 10' | xpaset ds9 regions");
	$array[1] += 18;
	system("echo 'text $array[0] $array[1] # text={$array[2]}' | xpaset ds9 regions");

}

sub get_keypress {

	$keypress = `xpaget ds9 imexam key coordinate image`;
	return($keypress);
	
}

1;