#! /usr/bin/perl -w

# subset_fa.pl
# take list of genes and pull out of fa
# Alan E. Yocca
# 2-19-18
# 10-16-19 add invert option

use strict;
use Getopt::Long;

my $usage = "\n$0\n" .
			"\t-i <input gene list>\n" .
			"\t-f <fa file>\n" .
			"\t-o <output>\n" .
			"\t--append <append to existing output>\n" .
			"\t--strip_header <keep only before first space>\n" .
			"\t--strip_character <default <space>>\n" .
				"\t\t<ensure to follow perl regex if necessary>\n" .
			"\t-s <optional, specify comma separated list of headers instead of file>\n" .
			"\t--std_out <optional, print to stdout instead of file>\n" .
			"\t\t<handy if using -s flag>\n" .
			"\t--invert <output all headers not specified>\n" .
			"\t\t<boolean>\n\n";

my $opt_i;
my $opt_f;
my $opt_o;
my @opt_s;
my $std_out;
my $invert='';
my $append='';
my $strip_header='';
my $strip_character = " ";

GetOptions ( "i=s" => \$opt_i,
  "f=s" => \$opt_f,
  "std_out" => \$std_out,
  "s=s" => \@opt_s,
  "o=s" => \$opt_o,
  "append" => \$append,
  "strip_header" => \$strip_header,
  "strip_character=s" => \$strip_character,
  "invert" => \$invert
) or die "$usage\n";

###Notes from earlier script if wanted to add this functionality
#allows for comma separation
@opt_s = split(/,/,join(',',@opt_s));
#@by_string = split(/,/,join(',',@by_string));

if ( (!(defined $opt_f)) ) {
  print "$usage";
  exit;
}

if ( (!(defined $opt_o)) && (!(defined $std_out)) ) {
  print "Must specify either output file OR std out\n";
  print "$usage";
  exit;
}

if ( ((defined $opt_o)) && ((defined $std_out)) ) {
  print "Must specify either output file OR std out\n";
  print "$usage";
  exit;
}

if ( (!(defined $opt_i)) && (!(defined $opt_s[0])) ) {
  print "Must specify either input gene list OR comma separated list\n";
  print "$usage";
  exit;
}

if ( ((defined $opt_i)) && ((defined $opt_s[0])) ) {
  print "Must specify either input gene list OR comma separated list\n";
  print "$usage";
  exit;
}

open (my $fasta_fh, '<', $opt_f) || die "Cannot open the fasta file: $opt_f\n\n";

my %genes;

if (defined $opt_i) {
	open (my $gene_list_fh, '<', $opt_i) || die "Cannot open the gene list: $opt_i\n\n";
	while (my $line = <$gene_list_fh>) {
		chomp $line;
		my @line = split(" ",$line);
		$genes{$line[0]} = 1;
	}
	close $gene_list_fh;
}
elsif (defined $opt_s[0]) {
	#string empty or only spaces
	if ($opt_s[0]  =~ /^ *$/) {
		print "Must list genes for -s\n";
		die "$usage";
	}
	foreach my $value (@opt_s) {
		$genes{$value} = 1;
	} 
}


my $loop = 0;
my $count = 0;
#I think the speed / readability hit
#greater than the hit of storing
#all output in a variable, then checking
#So: save output to variable
#if defined output print there,
#else, print stdout
my $output="";

while (my $line = <$fasta_fh>) {
	chomp $line;
	my @trans = split(">",$line);
	if ($trans[1]) {
		my @line = split($strip_character,$trans[1]);
		if ($invert) {
			$genes{$line[0]} = ($genes{$line[0]}) ? 0 : 1;
		}
		if ($genes{$line[0]}) {
#			if ($count == 0) {
				#print $out_fh "$line\n";
				#only need carrot for first one, because we redefined @line, but not $line
				$output .= ($strip_header) ? ">$line[0]\n" : "$line\n";
				$loop = 1;
				$count = $count + 1;
#			}
#			else {
#				#print $out_fh "\n$line\n";
#				$output = $output . "$line\n";
#				$loop = 1;
#				$count = $count + 1;
#			}
		}
		else {
			$loop = 0;
		}
	}
	else {
		if ($loop) {
			#print $out_fh "$line";
			$output = $output .  "$line\n";
		}
	}
}


if ($output eq "") {
	die "Could not find any gene matching target\n";
}
if (defined $opt_o) {
	if ($append){
		open (my $out_fh, '>>', $opt_o) || die "Cannot open output: $opt_o\n\n";
		print $out_fh "$output";
		close $out_fh;	
	}
	else {
		open (my $out_fh, '>', $opt_o) || die "Cannot open output: $opt_o\n\n";
		print $out_fh "$output";
		close $out_fh;
	}
	print "genes match line: $count\n";
	
}
elsif (defined $std_out) {
	print "$output";
}


close $fasta_fh;


exit;