#!/usr/bin/perl -w

use strict;

#script to remove co-ordinates if it has N base in the sequence

open(IN, "zcat tmp/exon_seq.txt.gz |");
open(OUT, ">genes_middle_exon_coords.bed"); 
while(<IN>)
{
  chomp;
  if($_=~/^>/){
  my $header=$_;my $seq=<IN>;
  if($seq!~/N/)
  {
    my @s=split(/\|/, (split(":", $header))[0]);
    $s[0]=~s/^>//g;
    print OUT "chr$s[0]","\t",join("\t", @s[3..$#s]),"\n";
  }
 }	
}
close IN;
close OUT;
`gzip -f -9 genes_middle_exon_coords.bed`; 

open(IN, "zcat tmp/intron_seq.txt.gz |");
open(OUT, ">genes_intron_coords.bed");
while(<IN>)
{
  chomp;
  if($_=~/^>/){
  my $header=$_;my $seq=<IN>;
  if($seq!~/N/)
  {
    my @s=split(/\|/, (split(":", $header))[0]);
    $s[0]=~s/>//g;
    $s[1]+=2;$s[2]-=1;
    print OUT "chr",join("\t", @s[0..$#s]),"\n";
  }
 }	
}
close IN;
close OUT;
`gzip -9 -f genes_intron_coords.bed`;
