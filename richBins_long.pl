#----------------------------------------------------------#
#	@AUTHOR		Helena Reyes Gopar
#	@NAME		richBins_long.pl
#	@DATE		september 2013
#	@VERSION	1.0.0
#----------------------------------------------------------#

=pod

=head1 NAME
richBins_long.pl

=head1 AUTHOR
hreyes	Helena Reyes Gopar

=head1 DATE
3 September, 2013

=head1 VERSION
1.0.0

=head1 DESCRIPTION
This parser
bla bla bla

=head1 PARAMETERS

=over 4

=item B<-i>		Input ChIP seq top scores file

=item B<-b>		Input bins file

=item B<-o>		Enrichment per bin Outfile

=item B<-l>   Enrichment per bin long format (positions and score)

=item B<-h>  This help message

=back

=cut

use strict;
use Getopt::Long;
# use List::MoreUtils qw(uniq);

my %opts = ();
GetOptions (\%opts, 'i=s', 'b=s', 'o=s', 'l=s', 'h|help');

#------------------No---Arguments---Functions-----------------------------------#

if(scalar(keys(%opts)) == 0) {
	print "usage:\richBins.pl [options]\n";
	print "-i\t\tInput ChIP seq topScores file\t\tMANDATORY\n";
	print "-b\t\tInput Bins file\t\t\t\tMANDATORY\n";
	print "-o\t\tOutput file (enrichment per bin file)\tMANDATORY\n";
	print "-l\t\tLong Output file (positions and score per bin)\tMANDATORY\n";
	print "-h | -help\tHelp\n";
	exit;
}

if($opts{'h'}) {
	&PrintHelp;
}

#-------------------Main---Code-------------------------------------------------#

#Flag variables
my $done;

#Information variables
my (@in, @scores);

open(BINS, $opts{'b'}) or die "Couldn't open bins file\n$!\n";
open (OUT, ">$opts{'o'}") or die "Couldn't open outfile\n$!\n";
open(LONG, ">$opts{'l'}") or die "Couldn't open long outfile\n$!\n";

while(<BINS>) {
	chomp;
	
	if(/^\d/) {
		@in = split(/\s/, $_);
		@scores = mapeo($in[1], $in[2], $in[3], $in[0]);
		$done = 1;
	}
	
	if($done) {
		print OUT "\n$in[0]";
		foreach(@scores) {
			chomp;
			print OUT "\t$_";
		}	
		@in = @scores = undef;
		undef $done;
	}
}

close BINS;
system("rm temp*");

close OUT;
close LONG;
print "Done!\n";

#-------------------Subroutines------------------------------------------------#

sub mapeo {
	# passed variables
	my($chr, $start, $end, $bin) = (@_[0], @_[1], @_[2], @_[3]);

	# local variables
	my @chip=(); 
	my @inBin =();
	
	my $file = "temp".$chr;
	unless(-e $file) {
		# ACHTUNG con cómo empiezan los bins file. Tal vez hay que concatenar 'chr'
		system("grep ".$chr." ".$opts{'i'}."  > temp".$chr); 
	}

	open(TEMP, "temp".$chr) or die "Couldn't find ChIP-seq file$!\n";

	while(<TEMP>) {
		chomp;
		@chip = split(/\s/, $_);
		if(($chip[1] >= $start) && ($chip[1] <= $end) && ($chip[2] >= $start) && ($chip[2] <= $end) ) {
			push(@inBin, $chip[3]);
			print LONG "$bin\t$chip[0]\t$chip[1]\t$chip[2]\t$chip[3]\n";
		}
	}
	
	$chr = $start = $end = undef;
	
	close TEMP;
	return(@inBin)
}

#---------------------Help---Function-----------------------------------#

sub PrintHelp {
	system "pod2text -c $0 ";
	exit()
}
