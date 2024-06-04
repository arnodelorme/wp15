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

Currently, there exist three scrambler tools, i.e. `bidscrambler`, `bidscrambler_tsv` and `bidscrambler_json`, that can be executed from a commandline terminal (run them with the `-h` flag for help):

### bidscrambler

```
usage: bidscrambler [-h] [-p PATTERN] inputdir outputdir

Creates a copy of the BIDS input directory in which all files are empty stubs. Exceptions to this are the
'dataset_description.json', 'README', 'CHANGES', 'LICENSE' and 'CITATION.cff' files, which are copied over
and updated if they exist.

positional arguments:
  inputdir              The input directory with the real data
  outputdir             The output directory with empty pseudo data

options:
  -h, --help            show this help message and exit
  -p PATTERN, --pattern PATTERN
                        A regular expression pattern that is matched against the relative path of the input
                        data to be included as output data (default: .*)

examples:
  bidscrambler bids pseudobids
  bidscrambler bids pseudobids '.*\.(nii|json|tsv)'
  bidscrambler bids pseudobids (?!derivatives)
  bidscrambler bids pseudobids '.*(?!/(func|sub.*scans.tsv))
```

### bidscrambler_tsv

```
usage: bidscrambler_tsv [-h] [-p PRESERVE [PRESERVE ...]] inputdir outputdir include

Adds randomly permuted versions of the tsv files in the BIDS input directory to the BIDS output directory.

positional arguments:
  inputdir              The input directory with the real data
  outputdir             The output directory with generated pseudo data
  include               A wildcard pattern for selecting input files to be included in the output directory

options:
  -h, --help            show this help message and exit
  -p PRESERVE [PRESERVE ...], --preserve PRESERVE [PRESERVE ...]
                        A list of tsv column names between which the relationship is preserved when
                        generating the pseudo data. Supports wildcard patterns (default: None)

examples:
  bidscrambler_tsv bids pseudobids '*.tsv'
  bidscrambler_tsv bids pseudobids participants.tsv -p participant_id 'SAS*'
  bidscrambler_tsv bids pseudobids 'partici*.tsv' -p '*'
```

### bidscrambler_json

```
usage: bidscrambler_json [-h] [-p PRESERVE] inputdir outputdir include

Adds empty-value versions of the json files in the BIDS input directory to the BIDS output directory.

positional arguments:
  inputdir              The input directory with the real data
  outputdir             The output directory with generated pseudo data
  include               A wildcard pattern for selecting input files to be included in the output directory

options:
  -h, --help            show this help message and exit
  -p PRESERVE, --preserve PRESERVE
                        A regular expression pattern that is matched against all keys in the json input
                        files. Associated values are copied over to the output files when a key matches
                        positively, else the normal empty value is used (default: None)

examples:
  bidscrambler_json bids pseudobids '*.json'
  bidscrambler_json bids pseudobids participants.json -p '.*'
  bidscrambler_json bids pseudobids '*.json' -p (?!(AcquisitionTime|.*Date))
```

### bidscrambler_nii

```
usage: bidscrambler_nii [-h] inputdir outputdir include {blur,permute} ...

Adds scrambled versions of the NIfTI files in the BIDS input directory to the BIDS output directory.

positional arguments:
  inputdir        The input directory with the real data
  outputdir       The output directory with generated pseudo data
  include         A wildcard pattern for selecting input files to be included in the output directory
  {blur,permute}  Scrambling method (by default the output images are nulled). Add -h for more help
    blur          Apply a 3D Gaussian smoothing filter
    permute       Perfom random permutations along one or more image dimensions

options:
  -h, --help      show this help message and exit

examples:
  bidscrambler_nii bids pseudobids '*.nii*'
  bidscrambler_nii bids pseudobids 'sub-*_T1w.nii.gz' blur -h
  bidscrambler_nii bids pseudobids 'sub-*_T1w.nii.gz' blur 20
  bidscrambler_nii bids pseudobids 'sub-*_bold.nii' permute x z'
```

## Legal Aspects

This code is released under the GPLv3 license.

## Related tools

- https://github.com/PennLINC/CuBIDS
- https://peerherholz.github.io/BIDSonym/
- https://arx.deidentifier.org
