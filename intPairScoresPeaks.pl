#----------------------------------------------------------#
#	@AUTHOR		Helena Reyes Gopar
#	@NAME		intPairScoresPeaks.pl
#	@DATE		august 2013
#	@VERSION	1.0.0
#-----------------------------------------------------------#

=pod

=head1 NAME
intPairScores.pl

=head1 AUTHOR
hreyes	Helena Reyes Gopar

=head1 DATE
June 11, 2013

=head1 VERSION
1.0.0

=head1 DESCRIPTION
This parser
1- receives a file with the interactig partners indicated (cbin1, cbin2) and retreives their mean scores in the hash.
2- the output is a table with three columns (interaction_number, score_bin1, score_bin2)


=head1 PARAMETERS

=over 4

=item B<-i>		Input interactions file

=item B<-s>		Input all scores file

=item B<-a>		Output interactions-binA file

=item B<-b>		Output interactions-binB file 

=item B<-h>  This help message

=back

=cut

use strict;
use Getopt::Long;

my %opts = ();
GetOptions (\%opts, 'i=s', 's=s', 'a=s', 'b=s', 'h|help');

#------------------No---Arguments---Functions-----------------------------------#

if(scalar(keys(%opts)) == 0) {
	print "usage:\tintParScores.pl [options]\n";
	print "-i\tInput interactions file\t\t\tMANDATORY\n";
	print "-s\tInput all scores file\t\t\tMANDATORY\n";
	print "-a\tOutput interactions-binA file\t\tMANDATORY\n";
	print "-b\tOutput interactions-binB file\t\tMANDATORY\n\n";
	print "-h | -help\tHelp\n";
	exit;
}

if($opts{'h'}) {
	&PrintHelp;
}

#-------------------Main---Code-------------------------------------------------#

#Flag variables
my $done_val;

#Information variables
my ($a, $b);
my (@bin_vals, @interactions);
my %aScores;

open(ALLSCORES, $opts{'s'}) or die "Couldn't open all scores file\n$!\n";

while(<ALLSCORES>) {
	chomp;
	
	if(/^\w/) {
		@bin_vals = split("\t", $_, 2);
		$aScores{$bin_vals[0]} = $bin_vals[1];
		$done_val;
	}
	
	if($done_val) {
		undef $done_val;
		undef @bin_vals;
	}
}

close ALLSCORES;
print "Done with the all-scores hash!\n";

#########

open (INTER, $opts{'i'}) or die "Couldn't open (interactions) infile\n$!\n";
open (INTA, ">$opts{'a'}") or die "Couldn't open (interaction-A) outfile\n$!\n"; 
open (INTB, ">$opts{'b'}") or die "Couldn't open (interacition-B) outfile\n$!\n"; 

while (<INTER>) {

	if (/^\d/) {
		
		@interactions = split("\t", $_);
		$a = "cbin".$interactions[0];
		$b = "cbin".$interactions[1];
		
		# print matrices 
		
		print INTA "$interactions[5]\t$aScores{$a}\n";
		print INTB "$interactions[5]\t$aScores{$b}\n";
		
		undef @interactions;
		$a = $b = undef;		
	}
}

close INTER;
close INTA;
close INTB;
print "DONE!\n";

#---------------------Help---Function-----------------------------------#

sub PrintHelp {
	system "pod2text -c $0 ";
	exit()
}
