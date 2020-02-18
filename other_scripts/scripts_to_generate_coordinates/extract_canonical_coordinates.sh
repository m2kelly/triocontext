#!/bin/bash

# Script to extract all the coordinates from the canonical coding sequence (exons and introns).

zcat gencode.v19.annotation.gtf.gz | grep 'exon.*protein_coding.*protein_coding.*CCDS' | sed 's/;/\t/g' | cut -f1,4,5,7,9,13,14- | sed -r 's/gene_id\s"(ENSG\w+\.\w+)"\s+gene_name\s"(\w+\-?\w*\.?\w*)"\s+transcript_type.*ccdsid\s"(\w+\.?\w*)".*$/\1\t\2\t\3/' | awk '{print $1 "\t" $2-1 "\t" $3 "\t" $5 "\t" $6 "\t" $4 "\t" $7}' | sort -k1,1 -k2,2n | awk 'BEGIN{col1="ID1"; col2="ID2"} {if (col1 != $5) {col1 = $5; col2 = $7; print $0} else { if (col2 == $7) {print $0}}}' | cut -f1,2,3,4,5,6 | sort | uniq | sort -k1,1 -k2,2n > exons_CCDS.bed

while read line;do arr=($line); exons=`grep -w ${arr[0]} exons_CCDS.bed`;start=`echo "$exons" | head -1 | cut -f2`;end=`echo "$exons" | tail -1 | cut -f3`;chr=`echo "$exons" | head -1 | cut -f1`;subtractBed -a  <(echo -e "$chr\t$start\t$end") -b <(grep -w ${arr[0]} exons_CCDS.bed) | sed s/$/\\t${arr[0]}\\t${arr[1]}\\t${arr[2]}/;done <<< "`cat exons_CCDS.bed | cut -f 4-6 | sort -u`" | sortBed > introns_CCDS.bed

gzip exons_CCDS.bed
gzip introns_CCDS.bed
