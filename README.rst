README
======

This repository contains the code used for generating the data in the paper "Germline de novo mutation rates on exons versus introns in humans".

This study was conducted after Frigola et al (2017) paper "Reduced mutation rate in exons due to differential mismatch repair".

We employed the code shared by Frigola et al. (2017) as a basis of our own code to ensure comparability of the main analysis. Therefore, the structure and documentation of this repository highly resembles its structure. However, it has been highly modified and brand-new code has been added as new analysis were made. 

We want to thank the Barcelona biomedical genomic lab for sharing the software code, specially to the authors involved in Frigola et al (2017). For more information check Frigola et al (2017) paper's repository at https://bitbucket.org/bbglab/intron_exon_mutrate

How to use
----------

The data was generated using a combination of Jupyter notebooks (using Python) and some external libraries and well as some bash and Perl scripts.

All notebooks are documented, so you can check which kind of data is needed to run them (and in which folder should it be) and what is the output that is generated. 

Before using
------------

First of all you need to get our repository:

.. code::

   git clone https://bitbucket.org/weghornlab/germline_intron_exon_mutrate.git

or 

download it from the `downloads page <https://bitbucket.org/weghornlab/germline_intron_exon_mutrate/downloads/>`_.

Directory structure
^^^^^^^^^^^^^^^^^^^

The **data** and **non_provided_data** folders contains external data used in our calculations.

In the **data** folder there is a ``README`` file that explains
what data is in each file and how we got it.

The **non_provided_data** folder is the one in which there is mutation data
that we are not sharing. See more information in the ``README`` file
located in that folder.

The **results** folder is used by the notebooks to write their output there.

The **figures** folder is used by some notebooks 
that generate plots to save the figures in there.


Installation
^^^^^^^^^^^^

For the Jupyter notebooks you need to have Python plus some other the packages.
If you are using conda, you can use the same environment as we used by 
generating the environment from the ``env.yml`` file:

.. code:: bash

   conda env create -f env.yml


Workflow
--------

1. 

2. 

3. 

4. 
