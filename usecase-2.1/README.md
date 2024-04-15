# SIESTA - work package 15 - use case 2.1

This implements a pipeline that analyses univariate tabular data. Specifically, it computes the mean age over a group of participants.

## Software installation

The R-software can be installed on a Linux, MacOS or Windows computer, specifically including the `Rscript` binary. The `optparse` package is ideally installed and on the path. If the `optparse` package is not available, it will be downloaded and installed in a temporary directory.

### Legal aspects

The R-package and the optparse package are licensed under GPL-2 | GPL-3. 

## Input data

The input data is formatted as BIDS and contained in the participants.tsv file from a specific open-access dataset [[1]]. The pipeline should also work with many other BIDS datasets from OpenNeuro [[2]].

```console
mkdir input
cd input
wget https://s3.amazonaws.com/openneuro.org/ds004148/participants.tsv
wget https://s3.amazonaws.com/openneuro.org/ds004148/participants.json
wget https://s3.amazonaws.com/openneuro.org/ds004148/dataset_description.json
wget https://s3.amazonaws.com/openneuro.org/ds004148/README
wget https://s3.amazonaws.com/openneuro.org/ds004148/CHANGES
cd ..
```

### Legal aspects

...

## Pseudo data

A pseudo (randomized) version of the data can be generated using [genbids](https://github.com/SIESTA-eu/wp15/tree/main/generative-BIDS). See `genbids -h` for more information.

```console
mkdir pseudo
genbids input pseudo -c age sex -i '*.tsv' '*.json' CHANGES README
```

## Output data

The output data will consist of a tsv file with the average age of the participants.

```console
mkdir -p output
```

## Executing the pipeline

Executing the pipeline from the command-line terminal is done with the real input data like this

```console
DATASET=./input/participants.tsv
OUTFILE=./output/results.tsv
Rscript pipeline_20240328.R -f $DATASET -o $OUTFILE
```

or with the the pseudo (randomized) version of the data like this

```console
DATASET=./pseudo/participants.tsv
OUTFILE=./output/results.tsv
Rscript pipeline_20240328.R -f $DATASET -o $OUTFILE
```

## Cleaning up

Cleaning up the input and output data can be done using:

```console
rm -rf input
rm -rf pseudo
rm -rf output
```

## References

[1]: https://doi.org/10.18112/openneuro.ds004148.v1.0.1
[2]: https://openneuro.org
