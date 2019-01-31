#!/usr/bin/perl

$pi = 3.141;

for ($i=0; $i<100000; $i+=1) {
$nums[$i] = randnorm(0.04, 0.01);
}
 




# Perl script to test monte carlo analysis of q and u stokes vectors and asymmetric errors of polarisation
$sample_size = 100000;

$q_val = 0.04;
$q_err = 0.01;


@q_array = ndist();

$q_average = average(\@q_array);
$q_stddev = stddev(\@q_array);


map { $_ -= $q_average } @q_array;



map { $_ *= ($q_err/$q_stddev) } @q_array;


map { $_ += $q_val } @q_array;

 







for ($i=0; $i<$sample_size; $i+=1) {
print "$q_array[$i]\t$nums[$i]\n";
}
exit();
$polarisation = (($q_val ** 2) + ($u_val ** 2)) ** 0.5;
print "Polarisation = $polarisation + ($pol[0.84 * $sample_size] - $polarisation) - ($polarisation - $pol[0.16 * $sample_size])\n";
#print "Lower error: $pol[0.16 * $sample_size]\n";
#print "Upper error: $pol[0.84 * $sample_size]\n";





sub randnorm {
    $num = $_[0] + $_[1] * sqrt(-2 * log rand) * cos(2 * $pi * rand);
    return ($num);
}