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

To scramble BIDS data you can run the command-line tool named ``scrambler``. At its base, this tool has an input and output argument, followed by a ``Data type`` subcommand. The meaning and usage of these arguments is explained in more detail in the following sections.

### scrambler

```
usage: scrambler [-h] bidsfolder outputfolder {stub,tsv,nii,json} ...

The general workflow to build up a scrambled BIDS dataset is by consecutively running `scrambler` for the datatype(s)
of your choice. For instance, you could first run `scrambler` to create a dummy dataset with only the file structure
and some basic files, and then run `scrambler` again to specifically add scrambled NIfTI data (see examples below).

positional arguments:
  bidsfolder           The BIDS (or BIDS-like) input directory with the original data
  outputfolder         The output directory with the scrambled pseudo data

options:
  -h, --help           show this help message and exit

Data type:
  {stub,tsv,nii,json}  Add -h, --help for more information
    stub               Saves a dummy bidsfolder skeleton in outputfolder
    tsv                Saves scrambled tsv files in outputfolder
    nii                Saves scrambled NIfTI files in outputfolder
    json               Saves scrambled json files in outputfolder

examples:
  scrambler data/bids data/pseudobids stub -h
  scrambler data/bids data/pseudobids nii -h
```

#### Data type: stub

```
usage: scrambler bidsfolder outputfolder stub [-h] [-s SELECT] [-d]

Creates a copy of the BIDS input directory in which all files are empty stubs. Exceptions to this are the
'dataset_description.json', 'README', 'CHANGES', 'LICENSE' and 'CITATION.cff' files, which are copied over
and updated if possible.

options:
  -h, --help            show this help message and exit
  -s SELECT, --select SELECT
                        A fullmatch regular expression pattern that is matched against the relative
                        path of the input data. Files that match are scrambled and saved in
                        outputfolder (default: .*)
  -d, --dryrun          Do not save anything, only print the output filenames in the terminal
                        (default: False)

examples:
  scrambler data/bids data/pseudobids stub
  scrambler data/bids data/pseudobids stub -s '.*\.(nii|json|tsv)'
  scrambler data/bids data/pseudobids stub -s '.*(?<!derivatives)'
  scrambler data/bids data/pseudobids stub -s '(?!sub.*scans.tsv|/func/).*'
```

#### Data type: tsv

```
usage: scrambler bidsfolder outputfolder tsv [-h] [-s SELECT] [-d] {permute} ...

Adds scrambled versions of the tsv files in the BIDS input directory to the BIDS output directory. If no scrambling
method is specified, the default behavior is to null all values.

positional arguments:
  {permute}             Scrambling method. Add -h, --help for more information
    permute             Randomly permute the column values of the tsv files

options:
  -h, --help            show this help message and exit
  -s SELECT, --select SELECT
                        A fullmatch regular expression pattern that is matched against the relative
                        path of the input data. Files that match are scrambled and saved in
                        outputfolder (default: .*)
  -d, --dryrun          Do not save anything, only print the output filenames in the terminal
                        (default: False)

examples:
  scrambler data/bids data/pseudobids tsv
  scrambler data/bids data/pseudobids tsv permute
  scrambler data/bids data/pseudobids tsv permute -s '.*_events.tsv' -p '.*'
  scrambler data/bids data/pseudobids tsv permute -s participants.tsv -p (participant_id|SAS.*)
```

#### Data type: nii

```
usage: scrambler bidsfolder outputfolder nii [-h] [-s SELECT] [-d] {blur,permute} ...

Adds scrambled versions of the NIfTI files in the BIDS input directory to the BIDS output directory. If no scrambling
method is specified, the default behavior is to null all image values.

positional arguments:
  {blur,permute}        Scrambling method. Add -h, --help for more information
    blur                Apply a 3D Gaussian smoothing filter
    permute             Perform random permutations along one or more image dimensions

options:
  -h, --help            show this help message and exit
  -s SELECT, --select SELECT
                        A fullmatch regular expression pattern that is matched against the relative
                        path of the input data. Files that match are scrambled and saved in
                        outputfolder (default: .*)
  -d, --dryrun          Do not save anything, only print the output filenames in the terminal
                        (default: False)

examples:
  scrambler data/bids data/pseudobids nii
  scrambler data/bids data/pseudobids nii blur -h
  scrambler data/bids data/pseudobids nii blur 20 -s 'sub-.*_T1w.nii.gz'
  scrambler data/bids data/pseudobids nii permute x z -i -s 'sub-.*_bold.nii'
```

#### Data type: json

```
usage: scrambler bidsfolder outputfolder json [-h] [-s SELECT] [-d] [-p PRESERVE]

Adds scrambled key-value versions of the json files in the BIDS input directory to the BIDS output directory. If no preserve
expression is specified, the default behavior is to null all values.

options:
  -h, --help            show this help message and exit
  -s SELECT, --select SELECT
                        A fullmatch regular expression pattern that is matched against the relative
                        path of the input data. Files that match are scrambled and saved in
                        outputfolder (default: .*)
  -d, --dryrun          Do not save anything, only print the output filenames in the terminal
                        (default: False)
  -p PRESERVE, --preserve PRESERVE
                        A fullmatch regular expression pattern that is matched against all keys in
                        the json files. The json values are copied over when a key matches positively
                        (default: None)

examples:
  scrambler data/bids data/pseudobids json
  scrambler data/bids data/pseudobids json participants.json -p '.*'
  scrambler data/bids data/pseudobids json 'sub-.*.json' -p '(?!AcquisitionTime|Date).*'
```

## Legal Aspects

This code is released under the GPLv3 license.

## Related tools

- https://github.com/PennLINC/CuBIDS
- https://peerherholz.github.io/BIDSonym/
- https://arx.deidentifier.org
