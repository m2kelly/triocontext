#!/usr/bin/perl -w

# read meta Exons
# 0      1       2       3                       4       5
#chr1    934341  934812  ENSG00000188290.6       HES4    -
my %exons;
open(IN,"tmp/genes_metaExon.bed");
while(<IN>)
{
  chomp $_;
  my @s=split(/\t/, $_);
  push(@{$exons{$s[3]}}, $_);
}
close IN;

# read meta Introns 
my %introns;
open(IN,"tmp/genes_metaIntron.bed");
while(<IN>)
{
  chomp $_;
  my @s=split(/\t/, $_);
  push(@{$introns{$s[3]}}, $_);
}
close IN;

# read driver genes
#open(IN, "Drivers.ensg") or die "error in opening the driver list\n";
#my %drivers;
#while(<IN>)
#{
# my @s=split(/\s+/, $_);
# $drivers{$s[0]}=1;
#}

# read the genes which has no overlaps
open(IN, "tmp/genes_overlap.txt");
#0	 1		 2		 3	 4			 5	 6
#chr1    206808880       206857764       +       ENSG00000143479.11      DYRK3   1
while(<IN>)
{
 my @s=split(/\s+/, $_);
 my $geneID=(split(/\./, $s[4]))[0];

 # select non-overlapping genes and check if doesn't overlap driver gene, but contains both exonic and intronic region
#if($s[6]==1 && ! exists $drivers{$geneID} && exists $exons{$s[4]} && exists $introns{$s[4]}) #MODIFIED FROM FRIGOLA ET AL. DO NOT EXCLUDE CANCER DRIVER GENES
 if($s[6]==1 && exists $exons{$s[4]} && exists $introns{$s[4]})
 {
   foreach my $d (@{$exons{$s[4]}})
   {print $d,"\texon\n";}

   foreach my $d (@{$introns{$s[4]}})
   {print $d,"\tintron\n";}
 }
}
close IN;
