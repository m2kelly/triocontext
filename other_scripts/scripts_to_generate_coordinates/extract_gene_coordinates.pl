#!/usr/bin/perl -w

# this script will extract the genomic co-ordinates of all protein coding genes/transcripts from the gencode v19 file

use strict;
use Data::Dumper;

# select only genes of type protein_coding and transcript of type protein_coding
open(IN,"zgrep \"protein_coding.*protein_coding\" gencode.v19.annotation.gtf.gz |");

# for gene
#0	1	2	3	4	5	6	7	8
#chr1	HAVANA	gene	11869	14412	.	+	.	gene_id "ENSG00000223972.4"; transcript_id "ENSG00000223972.4"; gene_type "pseudogene"; gene_status "KNOWN"; gene_name "DDX11L1"; transcript_type "pseudogene"; transcript_status "KNOWN"; transcript_name "DDX11L1"; level 2; havana_gene "OTTHUMG00000000961.2";

my %genes;
my %transcripts;
my %utrs;
my %gene_names;
while(<IN>)
{
 next, if($_=~/^#/);
 my @s=split(/\t/, $_);
 # parse the last column and save the gene/transcript/exon number details
 $s[8]=~s/\"//g;
 my @f=split(/\;/, $s[8]);
 my $geneID=(split(/\s/, $f[0]))[1]; # get gene_id
 my $transID=(split(/\s/, $f[1]))[2]; # transcript id
 my $exonNumb=(split(/\s/, $f[8]))[2]; # exon position
 my $gene_name=(split(/\s/, $f[4]))[2]; # gene name
 # gene level information
 if($s[2]=~/gene/)
 {
  $s[3]--;
  $genes{$geneID} = "$s[0]\t$s[3]\t$s[4]\t$s[6]"; # save the gene start and end position
  $gene_names{$geneID}=$gene_name;
 }
 # transcript level information
 # get exons only
 if($s[2]=~/exon/)
 { 
  $s[3]--;
  # save the exon start and end positions per transcript
  push(@{$transcripts{$transID}}, "$s[0]\t$s[3]\t$s[4]\t$s[6]\t$transID\t$geneID\t$gene_name\t$exonNumb");
 }
 # get UTRs
 if($s[2]=~/UTR/)
 { 
  $s[3]--;
  # save the exon start and end positions per transcript
  push(@{$utrs{$transID}}, "$s[0]\t$s[3]\t$s[4]\t$s[6]\t$transID\t$geneID\t$gene_name");
 }
} 

# output the gene level information in a file
open(ALL,">tmp/genes_coordinates.bed");
foreach my $gene1 (keys(%genes))
{
 print ALL $genes{$gene1},"\t",$gene1,"\t",$gene_names{$gene1},"\n"; 
}
close ALL;

# intersect genes to find their overlap with other genes
`intersectBed -a tmp/genes_coordinates.bed -b tmp/genes_coordinates.bed -c >tmp/genes_overlap.txt`;

# output the transcript level information
open(ALL,">tmp/genes_transcripts.bed");
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

# output the gene level information in a file
open(UTR,">tmp/genes_utr_regions.bed");
foreach my $trans (keys(%utrs))
{
 foreach my $utr (@{$utrs{$trans}})
 { print UTR $utr,"\n";}
}
close UTR;
