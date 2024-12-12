# SIESTA - work package 15 - use case 2.5

This implements an SPM analysis on fMRI data that was recorded from participans engaged in a visual task.

The pipeline is expected to be executed on a Linux computer and MATLAB R2020b.

## Input data

The input data is freely available from "OpenNeuro" with the Accession Number [ds004934](https://doi.org/10.18112/openneuro.ds004934.v1.0.0). The dataset includes 44 subjects who are divided into two experiments: 17 subjects undergo fMRIs dedicated to experiment 1, whereas 29 subjects undergo fMRIs dedicated to experiment 2.

The input data consists of about 1548 files with a combined size of 18.63G. The data can be downloaded using the Amazon [AWS command-line interface](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) or using [datalad](https://www.datalad.org/).

```console
mkdir input
aws s3 cp --recursive --no-sign-request s3://openneuro.org/ds004934/ input
```

To resume an partially complete download that was interrupted you can do

```console
aws s3 sync --no-sign-request s3://openneuro.org/ds004934/ input
```

### Data citation

The dataset itself can be cites with

- Shari Liu and Kirsten Lydic and Lingjie Mei and Rebecca Saxe (2024). fMRI dataset: Violations of psychological and physical expectations in human adult brains. OpenNeuro. [Dataset] [doi:10.18112/openneuro.ds004934.v1.0.0](https://doi.org/10.18112/openneuro.ds004934.v1.0.0).

The publication that describes the study in more detail is

- Liu, S., Lydic, K., Mei, L., & Saxe, R. (2024). Violations of physical and psychological expectations in the human adult brain. Imaging Neuroscience. [doi:10.1162/imag_a_00068](https://doi.org/10.1162/imag_a_00068).

### Legal aspects of the input data

The input dataset has been released under the [CC0](https://spdx.org/licenses/CC0-1.0.html) license.

## Output data

The to-be-shared data in the output folder has the following directory structure:

```console
|-- groupresults
|   |-- DOTS_run-001
|   |-- DOTS_run-002
|   |-- Motion_run-001
|   |-- Motion_run-002
|   |-- spWM_run-001
|   `-- spWM_run-002
```

Besides this, the output folder contains the per-subject intermediate (first-level) results. Those results are not to be shared and should not be on the whitelist

The `whitelist.txt` file contains a complete list of the output data that is to be shared.

## Analysis pipeline

### Legal aspects of the software

MATLAB is commercial software.

SPM is open source software that is released under the GPLv2 license.

The code that is specific to the analysis pipeline is shared under the CC0 license.

### Software installation

This requires the Github source repository, SPM and MATLAB software.

```console
git clone https://github.com/SIESTA-eu/wp15.git

cd wp15/usecase-2.5
wget https://github.com/spm/spm12/archive/refs/tags/r7771.zip
unzip r7771.zip
mv spm12-r7771 spm12
rm r7771.zip 
```

Alternatively, you can install the software in an Apptainer container image.

```console
cd wp15/usecase-2.5
apptainer build usecase-2.5.sif container.def
```

### Executing the pipeline

Executing the pipeline from the MATLAB command window is done like this:

```matlab
cd wp15/usecase-2.5
restoredefaultpath
addpath spm12
addpath spm12/config
addpath spm12/matlabbatch
addpath source

bidsapp inputdir outputdir participant
bidsapp inputdir outputdir group
```

Executing the pipeline from the Linux terminal is done using:

```console
cd wp15/usecase-2.5
matlab -batch "cd wp15/usecase-2.5; restoredefaultpath; addpath spm12 spm12/config spm12/matlabbatch source; bidsapp inputdir outputdir participant"
matlab -batch "cd wp15/usecase-2.5; restoredefaultpath; addpath spm12 spm12/config spm12/matlabbatch source; bidsapp inputdir outputdir group"
```

Executing the pipeline from the Apptainer image is done like this:

```console
apptainer run --env MLM_LICENSE_FILE=port@server usecase-2.5.sif inputdir outputdir participant
apptainer run --env MLM_LICENSE_FILE=port@server usecase-2.5.sif inputdir outputdir group
```

## Cleaning up

Cleaning up the input and output data is done using:

```console
rm -rf input
rm -rf output
```
