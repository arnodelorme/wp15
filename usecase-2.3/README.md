# SIESTA - work package 15 - use case 2.3

This implements an Event-Related Field (ERF) analysis on [Magnetoencephalography](https://en.wikipedia.org/wiki/Magnetoencephalography) (MEG) data.

The pipeline is expected to be executed on a Linux computer, although it might also work on macOS or Windows.

## Input data

The [input dataset](https://doi.org/10.18112/openneuro.ds000117.v1.0.6) is a multi-subject, multi-modal neuroimaging dataset that is described in detail in the accompanying [data publication](https://doi.org/10.1038/sdata.2015.1). It includes structural and functional MRI, MEG, and EEG data that was recorded during an experimental task on face processing.

The input data consists of 1671 files with a combined size of 84.82GB and can be downloaded using [datalad](https://www.datalad.org). In order to be able to use datalad, a sufficiently recent version of git is required. The older CentOS nodes on the DCCN cluster, running git version 1.8.3.1 could not do the job. The newer AlmaLinux nodes run git version 2.39.3. This worked.

```console
python -m venv venv
source venv/bin/activate
python -m pip install datalad
python -m pip install datalad-installer

datalad-installer git-annex -m datalad/git-annex:release --install-dir venv
mv venv/usr/lib/* venv/lib/.
mv venv/usr/bin/* venv/bin/.

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


## Output data

The output data consists of single-subject data that might be considered personal, and group-averaged aggregated data.

```console
mkdir output
```

## Analysis pipeline

### Software installation

This requires the GitHub wp15 repository, MATLAB and FieldTrip at commit [a0bd813](https://github.com/fieldtrip/fieldtrip/pull/2416/commits/a0bd8132fef7929264393b8c13f87a3b68cf6255) as part of PR [2461](https://github.com/fieldtrip/fieldtrip/pull/2416) or later. This pertains to any version of the code under the release [tag 20240614](https://github.com/fieldtrip/fieldtrip/releases/tag/20240614) or younger.

```console
git clone https://github.com/SIESTA-eu/wp15.git
wget https://github.com/fieldtrip/fieldtrip/archive/refs/tags/20240614.zip
unzip 20240614.zip
mv fieldtrip-20240614 fieldtrip
rm 20240614.zip
```

### Legal aspects of the software

MATLAB is commercial software and requires a license.

FieldTrip is open source and released under the GPLv3 license.

### Executing the pipeline

Executing the pipeline from the Linux command-line is done using the following:

Executing the pipeline from the MATLAB command window is done like this:

```console
restoredefaultpath;
addpath('fieldtrip');
addpath('wp15/usecase-2.3');
analyze_all_subjects
analyze_group
```

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

## Scrambled data

As in SIESTA the data is assumed to be sensitive, the analysis is conceived to be designed and implemented on a scrambled version of the dataset. Note that that is not needed here, as the original input and output data can be accessed directly.

 A scrambled version of the data can be generated using [BIDScramble](https://github.com/SIESTA-eu/wp15/tree/main/BIDScramble).

```console
scramble input scrambled stub
[WIP]
```
