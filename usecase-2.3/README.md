# SIESTA - work package 15 - use case 2.3

This implements ...

## Input data

The input data [[1]] is a multi-subject, multi-modal neuroimaging dataset that is described in detail in the accompanying data publication [[2]]. It includes structural and functional MRI, MEG, and EEG data that was recorded during an experimental task on face processing.

The input data consists of 1671 files with a combined size of 84.82GB and can be downloaded using datalad [[3]].

```console
python -m venv venv
source venv/bin/activate
python -m pip install datalad

git clone https://github.com/OpenNeuroDatasets/ds000117.git input
cd input

# get the MEG data for all subjects
datalad get sub-*/ses-meg/meg/*

# get the anatomical MRI data for all subjects
datalad get sub-*/ses-mri/anat/*
```

### Data citation

Wakeman, DG and Henson, RN (2024). Multisubject, multimodal face processing. OpenNeuro. [Dataset] doi: doi:10.18112/openneuro.ds000117.v1.0.6

### Legal aspects of the input data

The input dataset has been released under the [CC0](https://spdx.org/licenses/CC0-1.0.html) license.

## Pseudo data

A scrambled version of the data can be generated using ...

## Output data

The output data will consist of ...

```console
mkdir output
```

## Analysis pipeline

### Software requirements

...

### Legal aspects of the required software

...

### Executing the pipeline

Executing the pipeline from the Linux command-line is done using the following:

...

### Cleaning up

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

## References

[1]: https://doi.org/10.18112/openneuro.ds000117.v1.0.6
[2]: https://doi.org/10.1038/sdata.2015.1
[3]: https://www.datalad.org
