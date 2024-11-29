# SIESTA - work package 15 - use case 2.1

This implements an analysis of tabular data. Specifically, it computes the mean age, height and weight over a group of participants.

The pipeline is expected to be executed on a Linux computer, although it might also work on macOS or Windows.

## Input data

The [input dataset](https://doi.org/10.18112/openneuro.ds004148.v1.0.1) contains resting (eyes closed, eyes open) and cognitive (subtraction, music, memory) state EEG recordings with 60 participants during three experimental sessions together with sleep, emotion, mental health, and mind-wandering related measures. The data is described in more detail in an [accompanying paper](https://doi.org/10.1038/s41597-022-01607-9).

The analysis pipeline demonstrated here only uses the tabular data that is included in the BIDS dataset. The tabular data contains biometric information, i.e. indirect personal identifiers (age, height and weight, as well as outcomes from various questionnaires). With some minor modifications the pipeline should also work with many other BIDS datasets from [OpenNeuro](https://openneuro.org).

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

## Output data

The output data consist of a `results.tsv` file that contains the averaged age, height and weight of the participants.

The `whitelist.txt` file contains a complete list of the output data that is to be shared. 

```console
mkdir output
```

## Analysis pipeline

### Legal aspects of the software

The R-package and the optparse package are licensed under GPL-2 or GPL-3.

MATLAB is commercial software and requires a license.

The Apptainer software is licensed under [BSD-3-Clause](https://apptainer.org/docs/admin/main/license.html).

The code that is specific to the analysis pipeline is shared under the CC0 license.

### Installation of the R version

The R-software can be installed on a Linux, MacOS or Windows computer, specifically including the `Rscript` binary. The `optparse` package is ideally installed and on the path. If the `optparse` package is not available, it will be downloaded and installed in a temporary directory. Alternatively, it is possible to make an [Apptainer](https://apptainer.org) container with all analysis software and dependencies.

Alternatively, you can install the software in an Apptainer container image.

```console
cd wp15/usecase-2.1
apptainer build usecase-2.1.sif container-r.def
```

### Executing the R version of the pipeline

Executing the pipeline from the Linux terminal is done like this:

```console
cd wp15/usecase-2.1
Rscript source/pipeline.R --inputdir input --outputdir output  
```

Executing the pipeline from the R-based Apptainer image is done like this:

```console
mkdir output
apptainer run --no-home usecase-2.1.sif input output participant
apptainer run --no-home usecase-2.1.sif input output group
```

Note that this specific analysis pipeline does not have any computations at the participant level, but the participant step is included for completeness.

### Installation of the MATLAB version

The MATLAB version of the pipeline only requires a recent MATLAB version and the source directory to be on the MATLAB path.

Alternatively, you can install the software in an Apptainer container image.

```console
cd wp15/usecase-2.1
apptainer build usecase-2.1.sif container-matlab.def
```

### Executing the MATLAB version of the pipeline

Executing the pipeline from the Linux terminal is done like this:

```console
cd wp15/usecase-2.1
matlab -batch "restoredefaultpath; addpath source; bidsapp input output participant"
matlab -batch "restoredefaultpath; addpath source; bidsapp input output group"
```

Executing the pipeline from the MATLAB-based Apptainer image is done like this:

```console
mkdir output
apptainer run --no-home --env MLM_LICENSE_FILE=port@server usecase-2.1.sif input output participant
apptainer run --no-home --env MLM_LICENSE_FILE=port@server usecase-2.1.sif input output group
```

Note that this specific analysis pipeline does not have any computations at the participant level, but the participant step is included for completeness.

## Cleaning up

Cleaning up the input and output data can be done using:

```console
rm -rf input output
```

## Scrambled data

As in SIESTA the data is assumed to be sensitive, the analysis is conceived to be designed and implemented on a scrambled version of the dataset. Note that that is not needed here, as the original input and output data can be accessed directly. 

 A scrambled version of the data can be generated using [BIDScramble](https://github.com/SIESTA-eu/wp15/tree/main/BIDScramble).

```console
scramble input scrambled stub
scramble input scrambled tsv permute -s participants.tsv
scramble input scrambled json -p '.*' -s participants.json
```
