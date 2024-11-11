# SIESTA - work package 15 - use case 2.5

This implements an SPM analysis on fMRI data that was recorded from participans engaged in a visual task.

The pipeline is expected to be executed on a Linux computer and MATLAB R2020b.

## Input data

The input data is freely available from "OpenNeuro" with the Accession Number [ds004934](https://doi.org/10.18112/openneuro.ds004934.v1.0.0). The input data consists of about 1548 files with a combined size of 18.63G. More specifically, the dataset includes 44 subjects. These subjects are divided into two experiments: 17 subjects undergo fMRIs dedicated to experiment 1 whereas 29 subjects undergo fMRIs dedicated to experiment 2. The data can be downloaded using [datalad](https://www.datalad.org/). In order to be able to use [datalad](https://www.datalad.org/), a recent version of [git]( https://git-scm.com/downloads) is required.

```console
# create siesta python environment
python -m venv siesta

# activate siesta python environment
source siesta/bin/activate

# install datalad 
pip install datalad
pip install datalad-installer
datalad-installer git-annex -m datalad/git-annex:release --install-dir siesta

# move lib and bin in the same directory
mv siesta/usr/lib/* siesta/lib/.
mv siesta/usr/bin/* siesta/bin/.

# get subjects using datalad
git clone https://github.com/OpenNeuroDatasets/ds004934.git input
cd input 
datalad get sub-*
datalad unlock sub-*
```

### Data citation

Shari Liu and Kirsten Lydic and Lingjie Mei and Rebecca Saxe (2024). fMRI dataset: Violations of psychological and physical expectations in human adult brains. OpenNeuro. [Dataset] [doi:10.18112/openneuro.ds004934.v1.0.0](https://doi.org/10.18112/openneuro.ds004934.v1.0.0).

The publication that describes the study in more detail is

Liu, S., Lydic, K., Mei, L., & Saxe, R. (2024). Violations of physical and psychological expectations in the human adult brain. Imaging Neuroscience. [doi:10.1162/imag_a_00068](https://doi.org/10.1162/imag_a_00068).

### Legal aspects of the input data

The input dataset has been released under the [CC0](https://spdx.org/licenses/CC0-1.0.html) license.

## Output data

The to-be-shared data in the output folder has the following architecture:

```console
|-- groupresults
|   |-- DOTS_run-001
|   |-- DOTS_run-002
|   |-- Motion_run-001
|   |-- Motion_run-002
|   |-- spWM_run-001
|   `-- spWM_run-002
```

Besides this, the output folder contains the per-subject intermediate (first-level) results.
Those results are not to be shared and should not be on the whitelist

The `whitelist.txt` file contains a complete list of the output data that is to be shared.

## Analysis pipeline

### Software installation

This requires the Github source repository, SPM and MATLAB software.

```console
git clone https://github.com/spm/spm12.git
git clone https://github.com/SIESTA-eu/wp15.git
```

### Legal aspects of the software

MATLAB is commercial software.

SPM is open source software that is released under the GPLv2 license.

The code that is specific to the analysis pipeline is shared under the CC0 license.

### Executing the pipeline

Executing the pipeline from the Linux command-line is done using:

```console
# execute matlab code
cd wp15/usecase-2.5/source/
matlab -nodesktop -nodisplay -nosplash -noFigureWindows -r "workPackageCerCo; exit"
```

## Cleaning up

Cleaning up the input and output data is done using:

```console
rm -rf input
rm -rf output
```
