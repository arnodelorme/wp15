# BIDScramble

The BIDScramble tool generates scrambled or pseudo-random BIDS datasets from existing BIDS datasets, while preserving statistical distributions of user-specified variables and preserving user-specified effects of interest. The output data of this tool is not (or at least minimally) traceable and does not contain personal data.

It requires some BIDS-specific tooling to make the input dataset properly anonymous, possibly by replacing it with scrambled. That allows researchers to interact with pseudo-random datasets and code to implement and test their pipelines. The pipelines should run on the scrambled data just as it runs on the real input data.

## Software installation

The BIDScramble software runs on multiple platforms (e.g. Linux, MacOS, Windows) that have a Python 3 installation.

It is recommended (but not required) to first create a virtual environment.

```console
python -m venv venv
source venv/bin/activate
```

You can then install the generative BIDS tools using git (with authentication for wp15) and pip.

```console
git clone https://github.com/SIESTA-eu/wp15.git     # Or download the code yourself
pip install wp15/BIDScramble                        # Or use an alternative installer
```

## Usage

Currently there exist only a single tool named 'bidscramble'. Run ``bidscramble -h`` to see more information on the input arguments and on the output produced by this tool.

```console
usage: bidscramble [-h] [-c COVARIANCE [COVARIANCE ...]] [-i INCLUDE [INCLUDE ...]] inputdir outputdir

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
  bidscramble bids pseudobids -c age sex height -i *.tsv *.json CHANGES README

author:
  Marcel Zwiers
```

## Legal Aspects

This code is released under the GPLv3 license.

## Related tools

- https://peerherholz.github.io/BIDSonym/
- https://arx.deidentifier.org
