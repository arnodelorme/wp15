# SIESTA - work package 15 - use case 2.3

This implements ...

## Input data

The [input dataset](https://doi.org/10.18112/openneuro.ds000117.v1.0.6) is a multi-subject, multi-modal neuroimaging dataset that is described in detail in the accompanying [data publication](https://doi.org/10.1038/sdata.2015.1). It includes structural and functional MRI, MEG, and EEG data that was recorded during an experimental task on face processing.

The input data consists of 1671 files with a combined size of 84.82GB and can be downloaded using [datalad](https://www.datalad.org).

```console
python -m venv venv
source venv/bin/activate
python -m pip install datalad

git clone https://github.com/OpenNeuroDatasets/ds000117.git input
cd input

# get the MEG data for all subjects
datalad get sub-*/ses-meg/meg/*

# get the anatomical MRI data for all subjects
datalad get sub-*/ses-mri/anat/*mprage_T1w.nii.gz
```

### Data citation

Wakeman, DG and Henson, RN (2024). Multisubject, multimodal face processing. OpenNeuro. [Dataset] doi: doi:10.18112/openneuro.ds000117.v1.0.6

### Legal aspects of the input data

The input dataset has been released under the [CC0](https://spdx.org/licenses/CC0-1.0.html) license.

## Pseudo data

The pseudo data consists of scrambled BIDS data that is organised according to the BIDS standard. The scrambled version of the data can be generated using:

```console
scrambler input scrambled stub
[WIP]
```

## Output data

The output data consists of single-subject data that might be considered personal, and group-averaged aggregated data.

```console
mkdir output
```

## Analysis pipeline

### Software installation

The analysis requires MATLAB and FieldTrip at commit [a0bd813](https://github.com/fieldtrip/fieldtrip/pull/2416/commits/a0bd8132fef7929264393b8c13f87a3b68cf6255) as part of PR [2461](https://github.com/fieldtrip/fieldtrip/pull/2416) or later.

### Legal aspects of the software

MATLAB is commercial software and requires a license.

FieldTrip is open source and released under the GPLv3 license.

### Executing the pipeline

Executing the pipeline from the Linux command-line is done using the following:

...

## Cleaning up

Cleaning up the input and output data is done using:

```console
source venv/bin/activate

# drop all downloaded data
cd input
datalad drop *
cd ..

# remove the input and output directory
rm -rf input
rm -rf output
```
