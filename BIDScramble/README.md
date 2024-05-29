# BIDScramble

The BIDScramble tool generates scrambled or pseudo-random BIDS datasets from existing BIDS datasets, while preserving statistical distributions of user-specified variables and preserving user-specified effects of interest. The output data of this tool is not (or at least minimally) traceable and does not contain personal data.

It requires some BIDS-specific tooling to make the input dataset properly anonymous, possibly by replacing it with scrambled. That allows researchers to interact with pseudo-random datasets and code to implement and test their pipelines. The pipelines should run on the scrambled data just as it runs on the real input data.

## Software installation

The BIDScramble software runs on multiple platforms (e.g. Linux, MacOS, Windows) that have a Python 3.8+ installation.

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

Currently, there exist two scramble tools, i.e. `bidscrambler` and `bidscrambler_tsv`, that can be executed from a commandline terminal (run them with the `-h` flag for help):

### bidscrambler

```console
usage: bidscrambler [-h] inputdir outputdir

Creates a copy of the BIDS input directory in which all files are empty. Exceptions to this are the
'dataset_description.json', 'README', 'CHANGES', 'LICENSE' and 'CITATION.cff' files, which are copied
over and updated if they exist.

positional arguments:
  inputdir    The input-directory with the real data
  outputdir   The output-directory with empty pseudo data

options:
  -h, --help  show this help message and exit

examples:
  bidscrambler bids pseudobids

author:
  Marcel Zwiers
```

### bidscramble_tsv

```console
usage: bidscramble_tsv [-h] [-p PRESERVE [PRESERVE ...]] inputdir outputdir include [include ...]

Adds scrambled versions of the tsv files in the BIDS input directory to the BIDS output directory.

positional arguments:
  inputdir              The input-directory with the real data
  outputdir             The output-directory with generated pseudo data
  include               A list of wildcard patterns that select the files in the input-directory to be included in the output
                        directory

options:
  -h, --help            show this help message and exit
  -p PRESERVE [PRESERVE ...], --preserve PRESERVE [PRESERVE ...]
                        A list of tsv column names between which the relationship is preserved when generating the pseudo data.
                        Supports wildcard patterns (default: None)

examples:
  bidscrambler bids pseudobids '*.tsv'
  bidscrambler bids pseudobids participants.tsv -p participant_id 'SAS*'
  bidscrambler bids pseudobids 'partici*.tsv' -p '*' 

author:
  Marcel Zwiers
```

## Legal Aspects

This code is released under the GPLv3 license.

## Related tools

- https://peerherholz.github.io/BIDSonym/
- https://arx.deidentifier.org
