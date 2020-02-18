#!/usr/bin/perl -w

# this script will extract the genomic co-ordinates of all protein coding genes/transcripts from the gencode v19 file and annotate the exon position

use strict;
use Data::Dumper;

open(IN,"zgrep \"protein_coding.*protein_coding\" gencode.v19.annotation.gtf.gz |");
# for gene
#0	1	2	3	4	5	6	7	8
#chr1	HAVANA	gene	11869	14412	.	+	.	gene_id "ENSG00000223972.4"; transcript_id "ENSG00000223972.4"; gene_type "pseudogene"; gene_status "KNOWN"; gene_name "DDX11L1"; transcript_type "pseudogene"; transcript_status "KNOWN"; transcript_name "DDX11L1"; level 2; havana_gene "OTTHUMG00000000961.2";
my %genes;
my %transcripts;
my %gene_names;
while(<IN>)
{
 next, if($_=~/^#/);
 my @s=split(/\t/, $_);
 # parse the last column and save it in a hash variable
 $s[8]=~s/\"//g;
 my @f=split(/\;/, $s[8]);
 my $geneID=(split(/\s/, $f[0]))[1];
 my $transID=(split(/\s/, $f[1]))[2];
 my $exonNumb=(split(/\s/, $f[8]))[2];
 my $gene_name=(split(/\s/, $f[4]))[2];
 if($s[2]=~/gene/)
 {
  $s[3]--;
  $genes{$geneID} = "$s[0]\t$s[3]\t$s[4]\t$gene_name\t.\t$s[6]\t$geneID";
  $gene_names{$geneID}=$gene_name;
 }
 # extract exons
 if($s[2]=~/exon/)
 { 
  $s[3]--;
  push(@{$transcripts{$transID}}, "$s[0]\t$s[3]\t$s[4]\t$gene_name\t.\t$s[6]\t$transID\t$geneID\t$exonNumb");
 }
} 

# extract the gene start and end by 2kb to avoid bidirectional genes
open(ALL,">tmp/gene_coordinates_unsorted.bed");
open(ALL2,">tmp/gene_coordinates_extended2kb_unsorted.bed");

foreach my $gene1 (keys(%genes))
{
# print ALL $genes{$gene1},"\t",$gene1,"\t",$gene_names{$gene1},"\n"; 
 print ALL $genes{$gene1},"\n"; 
 my @s=split(/\t/, $genes{$gene1});
 $s[1]-=2000;
 $s[2]+=2000;
 print ALL2 join("\t", @s),"\n";
}
close ALL;
close ALL2;
`sort -k1,1 -k2,2n tmp/gene_coordinates_unsorted.bed >tmp/gene_coordinates.bed`;
`sort -k1,1 -k2,2n tmp/gene_coordinates_extended2kb_unsorted.bed >tmp/gene_coordinates_extended2kb.bed`;

# intersect genes to find the overlaps
`intersectBed -a tmp/gene_coordinates.bed -b tmp/gene_coordinates_extended2kb.bed -c >tmp/genes_overlap.txt`;

open(ALL,">tmp/gene_transcripts_v2_unsorted.bed");
foreach my $trans (keys(%transcripts))
{
 foreach my $exon (@{$transcripts{$trans}})
 {
  my $label="NULL";
  my @s=split(/\s/, $exon);
  if($s[$#s]==1)
  { $label="first"; }
  elsif($s[$#s]==scalar(@{$transcripts{$trans}}))
  { $label="last"; }
  else
  { $label="middle"; }
  print ALL $exon,"\t",$label,"\n"; 
 }
}
close ALL;
`sort -k1,1 -k2,2n tmp/gene_transcripts_v2_unsorted.bed >tmp/gene_transcripts_v2.bed`;

## apply filters to remove driver genes
# read driver genes
#open(IN, "Drivers.ensg") or die "error in opening the driver list\n";
my %genes_exclude;
#while(<IN>)
#{
# my @s=split(/\s+/, $_);
# $genes_exclude{$s[0]}=1;
#}

# read the genes which has no overlaps
open(IN, "tmp/genes_overlap.txt");
#0	1 	2	3	4	5	6
#chr1	69090	70008	OR4F5	.	+	ENSG00000186092.4	1
while(<IN>)
{
 my @s=split(/\s+/, $_);
 my $geneID=(split(/\./, $s[6]))[0];
 if($s[7] > 1)
 { $genes_exclude{$geneID}=1; }
}
close IN;

# read the transcript files and fileter the genes
open(IN, 'tmp/gene_transcripts_v2.bed');
my %exon_counts;
while(<IN>)
{
#0	1	2	3	4	5	6			7			8	9
#chr1	69090	70008	OR4F5	.	+	ENST00000335137.3	ENSG00000186092.4	1	first
 my @s=split(/\t/, $_);
 $exon_counts{$s[6]}+=1
}
close IN;

# read the transcript files and filter the genes that are not drivers and counts minimum 5 exons
open(IN, 'tmp/gene_transcripts_v2.bed');
open(OUT, ">genes_exon_coords_filtered.bed");
while(<IN>)
{
#0	1	2	3	4	5	6			7			8	9
#chr1	69090	70008	OR4F5	.	+	ENST00000335137.3	ENSG00000186092.4	1	first
 chomp $_;
 my @s=split(/\t/, $_);
 my $geneID=(split(/\./, $s[7]))[0];
 my $ecount=$exon_counts{$s[6]};
 if(!exists $genes_exclude{$geneID} && $ecount >=5)
 {
   # rename exon positions
   if($s[8]==2)
   {$s[9]="second";}
   elsif($s[8]==($ecount-1))
   {$s[9]="secondlast"}
   print OUT join("\t", @s),"\n";
 }
}
close IN;

`gzip -f -9 genes_exon_coords_filtered.bed`
