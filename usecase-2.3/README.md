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

# get the MaxFiltered MEG data for all subjects
datalad get derivatives/meg_derivatives/sub-*/ses-meg/meg/*

# get the anatomical MRI data for all subjects
datalad get sub-*/ses-mri/anat/*mprage_T1w.nii.gz
```

### Data citation

Wakeman, DG and Henson, RN (2024). Multisubject, multimodal face processing. OpenNeuro. [Dataset] doi: doi:10.18112/openneuro.ds000117.v1.0.6

### Legal aspects of the input data

The input dataset has been released under the [CC0](https://spdx.org/licenses/CC0-1.0.html) license.


## Output data

The output data that is to be shared consists of folders and files that represent group-level aggregated data. Many more individual-subject files are generated but these should not be shared with the researcher.

The `whitelist.txt` file contains a complete list of the output data that is to be shared. 

```console
mkdir output
```

## Analysis pipeline

### Software installation

This requires the GitHub wp15 repository, MATLAB, and a recent FieldTrip version.

```console
git clone https://github.com/SIESTA-eu/wp15.git
wget wget https://github.com/fieldtrip/fieldtrip/archive/refs/heads/master.zip
unzip master.zip
mv fieldtrip-master fieldtrip
rm master.zip
```

Alternatively, you can install the software in an Apptainer container image.

```console
cd wp15/usecase-2.3
sudo apptainer build ../../pipeline.sif pipeline.def
cd ../..
```

### Legal aspects of the software

MATLAB is commercial software and requires a license.

FieldTrip is open source and released under the GPLv3 license.

The code that is specific to the analysis pipeline is shared under the CC0 license.

### Executing the pipeline

Executing the pipeline from the MATLAB command window is done like this:

```console
restoredefaultpath;
addpath('fieldtrip');
addpath('wp15/usecase-2.3');
analyze_participant input output
analyze_group input output
```

Executing the pipeline from the Apptainer image is done like this:

```console
apptainer run --no-home --env MLM_LICENSE_FILE=port@server pipeline.sif input output participant
apptainer run --no-home --env MLM_LICENSE_FILE=port@server pipeline.sif input output group
```

It may be neccessay to use the `--bind` option to map the external and internal directories with input and output data.

## Cleaning up

Cleaning up the input and output data is done using:

```console
source venv/bin/activate

# drop all downloaded data
cd input
datalad drop *
cd ..

# remove the input and output directory
rm -rf input output
```

## Scrambled data

As in SIESTA the data is assumed to be sensitive, the analysis is conceived to be designed and implemented on a scrambled version of the dataset. Note that that is not needed here, as the original input and output data can be accessed directly.

 A scrambled version of the data can be generated using [BIDScramble](https://github.com/SIESTA-eu/wp15/tree/main/BIDScramble).

```console
scramble input scrambled stub
scramble input scrambled json -p '.*'
scramble input scrambled fif -s 'sub-../.*_meg\.fif'
```
