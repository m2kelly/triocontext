.. _data:


Data
====

Beside the code, some data has been provided so that 
you can recompute part of the analysis.
Please, note that not all the data required to
run the full analysis is provided.


Download
--------

You can download the data from our 
`downloads page <https://bitbucket.org/bbglab/intron_exon_mutrate/downloads/>`_
or using:

.. code::

   wget  https://bitbucket.org/bbglab/intron_exon_mutrate/downloads/data.tar.xz

The file should be uncrompressed in this directory:

.. code::

   tar -xJf data.tar.xz

Content
-------

The data that we provide is:

kmer.txt
   Files that contains the counts of 1-mers, 3-mers, 5-mers,... from the whole genome or from a  which will be used for normalization. 
   They are generated in **Direct_signatures** notebook


nucleosome_coords.bed
   The file can be obtained downloadind *wgEncodeSydhNsomeGm12878Sig.bigWig* from 
   `UCSC <http://hgdownload.cse.ucsc.edu/goldenpath/hg19/encodeDCC/wgEncodeSydhNsome/>`_.

   Then, using the `bwtool <https://github.com/CRG-Barcelona/bwtool/wiki>`_ 
   developed by the CRG, the local max for nucleosome peak region can be extracted: 

   .. code:: bash

      bwtool find local-extrema -maxima -min-sep=150 wgEncodeSydhNsomeGm12878Sig.bigWig nucleosome_coords.bed

mapability
----------

This folder contains a set of files used in the **sequences_filtering** notebook.


ucsc_blacklist.bed.gz
   Blacklisted regions. 
   The file was obtained from the `UCSC genombe browse <http://genome.ucsc.edu/cgi-bin/hgFileUi?db=hg19&g=wgEncodeMapability>`_:

   .. code:: bash

      wget http://hgdownload.cse.ucsc.edu/goldenpath/hg19/encodeDCC/wgEncodeMapability/wgEncodeDukeMapabilityRegionsExcludable.bed.gz
      wget http://hgdownload.cse.ucsc.edu/goldenpath/hg19/encodeDCC/wgEncodeMapability/wgEncodeDacMapabilityConsensusExcludable.bed.gz
      # merged the two list using mergeBed with the following
      zcat wgEncodeDukeMapabilityRegionsExcludable.bed.gz wgEncodeDacMapabilityConsensusExcludable.bed.gz | sort -k1,1 -k2,2n | mergeBed -i stdin | gzip -c >ucsc_blacklist_bed.gz


hg19_low_complexity_regions.gz
   Low complexity regions.
   This information has been obtained from the UCSC table browser.  
   
   In the `table browser <https://genome.ucsc.edu/cgi-bin/hgTables>`_ select the following items,
   
   - assemble: hg19
   - group: Repeats
   - track: RepeatMasker 
   - table: rmsk 
   - region: genome
   - filter: click on "create". After "repClass does", paste in: 'Low_complexity' (to get this value click on "describe table schema" on the main table browser page for the table you are interested in.)   

    Click "submit".
    
    - output format: BED format
    

wgEncodeCrgMapabilityAlign36mer_score1.bed.gz
    Regions without alignability problems.
    The file was obtaining by executing:

    .. code:: bash

       wget http://hgdownload.cse.ucsc.edu/goldenPath/hg19/encodeDCC/wgEncodeMapability/wgEncodeCrgMapabilityAlign36mer.bigWig
       # conver to bed format
       bigWigToBedGraph wgEncodeCrgMapabilityAlign36mer.bigWig wgEncodeCrgMapabilityAlign36mer.bed
       gzip -9 wgEncodeCrgMapabilityAlign36mer.bed
       # get region that are uniquely mapable (with two mismatches allowed)
       zcat wgEncodeCrgMapabilityAlign36mer.bed.gz | awk '$4==1' | gzip -c >wgEncodeCrgMapabilityAlign36mer_score1.bed.gz
  

consequence
-----------

This folder contains a tabix file with consequence type of exonic mutations.
It was obtained using the Ensembl Variant Effect Predictor (VEP, v. 70). 


coordinates
-----------


This folder contains 3 bed files with coordinates.

genes_intron_coords.bed.gz
   Coordinates of the introns

genes_middle_exon_coords.bed.gz
   Coordinates of the middle exons 

gene_exon_coords_filtered.bed.gz
   Coordinates of all exons with their position annotated with respect to TSS. This file is used mainly for the analysis shown in Fig. 1.

The scripts that were used to generate the above coordinates can be found in `other_scripts/scripts_to_generate_coordinates`_ Unlike Frigola et al. (2017), the coordinates include cancer driver genes but not genes in sexual chromosomes. The files genes_middle_exon_coords.bed.gz and genes_intron_coords.bed.gz were used for further filters such as mappability, low complexity, and low sequence coverage as mentioned in the **sequences_filtering** notebook. 
