#----------------------------------------------------------#
#	@AUTHOR		Helena Reyes Gopar
#	@NAME		assign-bin-to-genes.pl
#	@DATE		september 2013
#	@VERSION	1.0.0
#-----------------------------------------------------------#

=pod

=head1 NAME
assign-bin-to-genes.pl

=head1 AUTHOR
hreyes	Helena Reyes Gopar

=head1 DATE
13 October, 2013

=head1 VERSION
1.0.0

=head1 DESCRIPTION
This parser receives a file with the positions of genes, a file with the positions of interaction bins, 
returns a file with the genes in each bin, and a file with each gene's affiliation

=head1 PARAMETERS

=over 4

=item B<-i>		Input genes file

=item B<-b>		Input bins file

=item B<-o>		Enrichment per bin Outfile

=item B<-l>		Enrichment per bin Outfile (long format)

=item B<-h>  	This help message

=back

=cut

use strict;
use Getopt::Long;
# use List::MoreUtils qw(uniq);

my %opts = ();
GetOptions (\%opts, 'i=s', 'b=s', 'o=s', 'l=s', 'h|help');

#------------------No---Arguments---Functions-----------------------------------#

if(scalar(keys(%opts)) == 0) {
	print "usage:\assign-bin-to-genes.pl\t\t\t[options]\n";
	print "-i\t\tInput genes file\t\t\t\tMANDATORY\n";
	print "-b\t\tInput Bins file\t\t\t\t\tMANDATORY\n";
	print "-o\t\tOutput file (enrichment per bin file)\t\tMANDATORY\n";
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
my (@in, @genes);

open(BINS, $opts{'b'}) or die "Couldn't open bins file\n$!\n";
open (OUT, ">$opts{'o'}") or die "Couldn't open outfile\n$!\n";
open(LONG, ">$opts{'l'}") or die "Couldn't open long outfile\n$!\n";

while(<BINS>) {
	chomp;
	
	if(/^\d/) {
		@in = split(/\s/, $_);
		@genes = mapeo($in[0], $in[1], $in[2], $in[3]);
		$done = 1;
	}
	
	if($done) {
		print OUT "\n$in[0]";
		foreach(@genes) {
			chomp;
			print OUT "\t$_";
		}	
		@in = @genes = undef;
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
	my($bin, $chr, $start, $end) = (@_[0], @_[1], @_[2], @_[3]);

	# local variables
	my @gen=();
	my @inBin=();
	
	my $file = "temp".$chr;
	unless(-e $file) {
		# ACHTUNG con cómo empiezan los bins file. Tal vez hay que concatenar 'chr' (o en bins file)
		system("grep ".$chr." ".$opts{'i'}."  > temp".$chr); 
	}

	open(TEMP, "temp".$chr) or die "Couldn't find ChIP-seq file$!\n";

	while(<TEMP>) {
		chomp;
		@gen = split(/\s/, $_);
		if(($gen[2] >= $start) && ($gen[2] <= $end) && ($gen[3] >= $start) && ($gen[3] <= $end) ) {
			push(@inBin, $gen[0]);
			print LONG "$bin\t$gen[0]\t$gen[1]\t$gen[2]\t$gen[3]\t$gen[4]\t$gen[5]\t$gen[6]\n";
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
