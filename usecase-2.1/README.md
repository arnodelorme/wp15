# SIESTA WP15 use case 2.1

This implements a pipeline that analyses univariate tabular data.

## Input data

The participants.tsv file from a specific open-access dataset from OpenNeuro. In principle the pipeline should also work with many other participants.tsv files from BIDS datasets.

## Output data

A tsv-file containing the output of the computation, in this case the average age of the participants in the experiment.

## Software prerequisites

The R-software needs to be installed, specifically including the Rscript binary.

R-package dependency: optparse needs to be installed, and on the R-package library path. This is because the pipeline code is a bit over-engineered for now, but this is on purpose. For now, I have installed the package (because it may not be present at default for a lean R install), and point to it in the below example, by specifying the R_LIBS_SITE variable.

Deployment of the pipeline from the Linux command line is done using the following, assuming the working directory is at this level:

    R_LIBS_SITE=./packages/
    DATASET=./data/ds004148
    OUTFILE=./result/ds004148_output.tsv
    Rscript pipeline_20240328.R -f $DATASET -o $OUTFILE
