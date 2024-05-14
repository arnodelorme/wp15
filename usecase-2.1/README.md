# SIESTA - work package 15 - use case 2.1

This implements an analysis of univariate tabular data. Specifically, it computes the mean age over a group of participants.

## Input data

The input data [[1]] dataset contains resting (eyes closed, eyes open) and cognitive (subtraction, music, memory) state EEG recordings with 60 participants during three experimental sessions together with sleep, emotion, mental health, and mind-wandering related measures. The data is described in more detail in an accompanying paper [[2]].

The analysis pipeline demonstrated here only uses the tabular data that is included in the dataset. The tabular data contains biometric information, i.e. indirect personal identifiers (age and height). The pipeline should also work with many other BIDS datasets from OpenNeuro [[3]].

The complete input data consists of 5585 files with a combined size of 30.67GB. The analysis only requires a few of those files to be downloaded.

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

### Data citation

Yulin Wang and Wei Duan and Debo Dong and Lihong Ding and Xu Lei (2022). A test-retest resting and cognitive state EEG dataset. OpenNeuro. [Dataset] doi: doi:10.18112/openneuro.ds004148.v1.0.1

### Legal aspects of the input data

The input dataset has been released under the [CC0](https://spdx.org/licenses/CC0-1.0.html) license.

## Pseudo data

A scrambled version of the data can be generated using [bidscramble](https://github.com/SIESTA-eu/wp15/tree/main/BIDScramble). See `bidscramble -h` for more information.

```console
mkdir scrambled
bidscramble input scrambled -c age sex -i '*.tsv' '*.json' CHANGES README
```

## Output data

The output data will consist of a tsv file with the average age of the participants.

```console
mkdir output
```

## Analysis pipeline

### Software installation

The R-software can be installed on a Linux, MacOS or Windows computer, specifically including the `Rscript` binary. The `optparse` package is ideally installed and on the path. If the `optparse` package is not available, it will be downloaded and installed in a temporary directory.

### Legal aspects of the software

The R-package and the optparse package are licensed under GPL-2 or GPL-3.

## Executing the pipeline

Executing the pipeline from the Linux command-line is done with the real input data like this:

```console
DATASET=./input/participants.tsv
OUTFILE=./output/results.tsv
Rscript pipeline_20240328.R -f $DATASET -o $OUTFILE
```

or with the the scrambled version of the data like this:

```console
DATASET=./scrambled/participants.tsv
OUTFILE=./output/results.tsv
Rscript pipeline_20240328.R -f $DATASET -o $OUTFILE
```

## Cleaning up

Cleaning up the input and output data can be done using:

```console
rm -rf input scrambled output
```

## References

[1]: https://doi.org/10.18112/openneuro.ds004148.v1.0.1
[2]: https://doi.org/10.1038/s41597-022-01607-9
[3]: https://openneuro.org
