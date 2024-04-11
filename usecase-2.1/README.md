# SIESTA - work package 15 - use case 2.1

This implements a pipeline that analyses univariate tabular data.

## Input data

The input data is contained in the participants.tsv file from a specific open-access dataset [[1]]. The pipeline should also work with many other BIDS datasets from OpenNeuro [[2]].

    mkdir input
    cd input/
    wget https://s3.amazonaws.com/openneuro.org/ds004148/participants.tsv
    wget https://s3.amazonaws.com/openneuro.org/ds004148/participants.json
    wget https://s3.amazonaws.com/openneuro.org/ds004148/dataset_desctription.json
    wget https://s3.amazonaws.com/openneuro.org/ds004148/README
    wget https://s3.amazonaws.com/openneuro.org/ds004148/CHANGES
    cd ..

## Output data

The output will consist of a tsv file with the average age of the participants.

    mkdir -p output
    date -Iseconds >> output/pipeline.log

### Software prerequisites

The R-software needs to be installed, specifically including the `Rscript` binary. The `optparse` package is ideally installed and on the path. If the `optparse` package is not available, it will be downloaded and installed in a temporary directory.

## Running the pipeline

Executing the pipeline from the Linux command-line is done using the following:

    DATASET=./input/participants.tsv
    OUTFILE=./output/results.tsv
    Rscript pipeline_20240328.R -f $DATASET -o $OUTFILE

## Cleaning up

Cleaning up the input and output data is done using:

    rm -rf input
    rm -rf output

## References

[1]: https://doi.org/10.18112/openneuro.ds004148.v1.0.1
[2]: https://openneuro.org
