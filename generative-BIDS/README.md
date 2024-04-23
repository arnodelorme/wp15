# SIESTA - work package 15 - Generative BIDS

The generative BIDS tools generate pseudo random BIDS datasets from existing BIDS datasets. The tools:

- Preserve user specified effects of interest
- Preserve statistical distributions
- Generate non-existing data that is not (or at least minimally) traceable / does not contain personal data

It requires some BIDS-specific tooling to make the input dataset properly anonymous, possibly by replacing it with pseudodata. That allows researchers to interact with pseudo datasets and code to implement and test their pipelines. The pipelines should run on the pseudo data just as it runs on the real input data.

## Software installation

The generative BIDS software runs on multiple platforms (e.g. Linux, MacOS, Windows) that have a Python 3 installation.

It is recommended (but not required) to first create a virtual environment.

```console
python -m venv venv
source venv/bin/activate
```

You can then install the generative BIDS tools using git (with authentication for wp15) and pip.

```console
git clone https://github.com/SIESTA-eu/wp15.git     # Or download the code yourself 
pip install wp15/generative-BIDS                    # Or use an alternative installer
```

## Usage

Currently there exist only a single tool named 'genbids'. Run ``genbids -h`` to see more information on the input arguments and output produced by this tool.

```console
usage: genbids [-h] [-c COVARIANCE [COVARIANCE ...]] [-i INCLUDE [INCLUDE ...]] inputdir outputdir

positional arguments:
  inputdir              The BIDS input-directory with the real data
  outputdir             The BIDS output-directory with generated pseudo data

options:
  -h, --help            show this help message and exit
  -c COVARIANCE [COVARIANCE ...], --covariance COVARIANCE [COVARIANCE ...]
                        A list of variable names between which the covariance structure is
                        preserved when generating the pseudo data (default: None)
  -i INCLUDE [INCLUDE ...], --include INCLUDE [INCLUDE ...]
                        A list of include pattern(s) that select the files in the BIDS
                        input-directory that are produced in the output directory
                        (default: ['*'])

examples:
  genbids bids pseudobids -c age sex height -i *.tsv *.json CHANGES README

author:
  Marcel Zwiers
```

## Legal Aspects
