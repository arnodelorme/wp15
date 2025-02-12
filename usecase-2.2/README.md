# SIESTA - work package 15 - use case 2.2

This implements the [MRIQC](https://mriqc.readthedocs.io/en/latest/) pipeline for obtaining standard QC measures from an MRI dataset.

The pipeline is expected to be executed on a Linux computer, although it might also work on macOS or Windows.

## Input data

The [input dataset](https://doi.org/10.18112/openneuro.ds003826.v3.0.1) contains structural T1-weighted MRI brain scans from 136 young individuals (87 females; age range from 18 to 35 years old) along with questionnaire-assessed measurements of trait-like chronotype, sleep quality and daytime sleepiness. The data is organized according to the BIDS standard (combined size of 1.18GB) and mostly useful to scientists interested in circadian rhythmicity, structural brain correlates of chronotypes in humans and the effects of sleeping habits and latitude on brain anatomy. The dataset is described in more detail in an [accompanying publication](https://doi.org/10.1080/09291016.2021.1990501).

Downloading the data with the [cli](https://docs.openneuro.org/packages/openneuro-cli.html) requires Node.js (version 18 or higher) to be installed. To install a specific (latest) version of Node.js you can [install nvm](https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-and-updating) and manage your node installation(s) from there:

```console
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm install node    # "node" is an alias for the latest version
```

If your node installation is up-to-date and working then make sure you have an openneuro account and in a new termminal run:

```console
npm install -g @openneuro/cli

openneuro login
openneuro download ds003826 input   # Choose snapshot 3.0.1
```

Tip: Use e.g. Node.js version 21.7.3 if you get errors from the openneuro client

### Data citation

Michal Rafal Zareba and Magdalena Fafrowicz and Tadeusz Marek and Ewa Beldzik and Halszka Oginska and Aleksandra Domagalik (2022). Structural (t1) images of 136 young healthy adults; study of effects of chronotype, sleep quality and daytime sleepiness on brain structure. OpenNeuro. [Dataset] doi: doi:10.18112/openneuro.ds003826.v3.0.1

### Legal aspects of the input data

The input dataset has been released under the [CC0](https://spdx.org/licenses/CC0-1.0.html) license.

## Output data

The output data consists of MRI QC parameters of each participant

The `whitelist.txt` file contains a complete list of the output data that is to be shared. 

```console
mkdir output
```

## Analysis pipeline

### Legal aspects of the software

The Apptainer software is licensed under [BSD-3-Clause](https://apptainer.org/docs/admin/main/license.html).

The MRIQC software is licensed under [Apache-2.0](https://spdx.org/licenses/Apache-2.0.html).

### Software installation

Running the analysis pipeline requires a working [Apptainer installation](https://apptainer.org/docs/admin/main/installation.html#installation-on-linux) (version >= 2.5). Next the [MRIQC](https://mriqc.readthedocs.io/en/latest/) container needs to be downloaded:

```console
apptainer pull mriqc-24.0.0.sif docker://nipreps/mriqc:24.0.0
```

### Executing the pipeline

Executing the pipeline from the Apptainer image is done like this:

```console
mkdir output
apptainer run --cleanenv mriqc-24.0.0.sif input output participant
apptainer run --cleanenv mriqc-24.0.0.sif input output group
```

## Cleaning up

Cleaning up the input and output data is done using:

```console
rm -rf input output
```

## Scrambled data

As in SIESTA the data is assumed to be sensitive, the analysis is conceived to be designed and implemented on a scrambled version of the dataset. Note that that is not needed here, as the original input and output data can be accessed directly. 

 A scrambled version of the data can be generated using [BIDScramble](https://github.com/SIESTA-eu/wp15/tree/main/BIDScramble).

```console
scramble input output stub
scramble input output json -p '(?!AcquisitionTime).*'
scramble input output nii permute y -i
```
