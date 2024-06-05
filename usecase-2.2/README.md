# SIESTA - work package 15 - use case 2.2

This implements the [MRIQC](https://mriqc.readthedocs.io/en/latest/) pipeline for obtaining standard QC measures from BIDS MRI datasets.

## Input data

The input dataset [[1]] contains structural T1-weighted MRI brain scans from 136 young individuals (87 females; age range from 18 to 35 years old) along with questionnaire-assessed measurements of trait-like chronotype, sleep quality and daytime sleepiness. The data is organized according to the BIDS standard (combined size of 1.18GB) and mostly useful to scientists interested in circadian rhythmicity, structural brain correlates of chronotypes in humans and the effects of sleeping habits and latitude on brain anatomy. The dataset is described in more detail in an accompanying publication [[2]].

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

## Pseudo data

The pseudo data consists of scrambled BIDS data that is organised according to the BIDS standard. The scrambled version of the data can be generated using:

```console
bidscrambler input scrambled stub
bidscrambler input scrambled tsv permute
```

## Output data

The output data consists of MRI QC parameters of each participant

```console
mkdir output
```

## Analysis pipeline

### Software installation

Running the analysis pipeline requires a working [Apptainer installation](https://apptainer.org/docs/admin/main/installation.html#installation-on-linux) (version >= 2.5). Next the MRIQC container needs to be build (NB: this requires root permission):

```console
sudo apptainer build mriqc-24.0.0.sif docker://nipreps/mriqc:24.0.0
```

### Legal aspects of the software

The apptainer software is licensed under [BSD-3-Clause](https://apptainer.org/docs/admin/main/license.html) and mriqc under [Apache-2.0](https://spdx.org/licenses/Apache-2.0.html).

### Executing the pipeline

Executing the pipeline from the Linux command-line to generate the output data is done using the following:

```console
mkdir mriqc output
apptainer run --cleanenv mriqc-24.0.0.sif input mriqc participant
apptainer run --cleanenv mriqc-24.0.0.sif input mriqc group

```

## Cleaning up

Cleaning up the input and output data is done using:

```console
rm -rf input scrambled output
```

## References

[1]: https://doi.org/10.18112/openneuro.ds003826.v3.0.1
[2]: https://doi.org/10.1080/09291016.2021.1990501
