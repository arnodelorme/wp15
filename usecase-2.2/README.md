# SIESTA - work package 15 - use case 2.2

This implements ...

## Input data

The input data [[1]] consists of structural MRI and tabular data. The dataset is described in more detail in an accompanying publication [[2]].

The input data consists of 277 files with a combined size of 1.18GB.

Downloading the data with the [cli](https://docs.openneuro.org/packages/openneuro-cli.html) requires Node.js (version 18 or higher) to be installed. To install a specific (latest) version of Node.js it is adviced to first [install nvm](https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-and-updating) and manage your node installation from there:

```console
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm install node    # "node" is an alias for the latest version (replace e.g. with "22.2.0" if needed)
```

If your node installation is up-to-date and working then make sure you have an openneuro account and in a new termminal run:

```console
npm install -g @openneuro/cli

openneuro login
openneuro download ds003826 input
```

### Data citation

Michal Rafal Zareba and Magdalena Fafrowicz and Tadeusz Marek and Ewa Beldzik and Halszka Oginska and Aleksandra Domagalik (2022). Structural (t1) images of 136 young healthy adults; study of effects of chronotype, sleep quality and daytime sleepiness on brain structure. OpenNeuro. [Dataset] doi: doi:10.18112/openneuro.ds003826.v3.0.1

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
rm -rf input
rm -rf output
```

## References

[1]: https://doi.org/10.18112/openneuro.ds003826.v3.0.1
[2]: https://doi.org/10.1080/09291016.2021.1990501
