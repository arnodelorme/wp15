# BIDScramble

The BIDScramble tool generates scrambled or pseudo-random BIDS datasets from existing BIDS datasets, while preserving statistical distributions of user-specified variables and preserving user-specified effects of interest. The output data of this tool is not (or at least minimally) traceable and does not contain personal data.

Having access to pseudo-random datasets allows researchers to interact with the data in detail and develop code to implement and test their pipelines. The pipelines should run on the scrambled data just as it runs on the real input data.

## Software installation

The BIDScramble software runs on multiple platforms (e.g. Linux, MacOS, Windows) that have a Python 3.8+ installation.

It is recommended (but not required) to first create a virtual environment.

```console
python -m venv venv
source venv/bin/activate
```

You can then install the BIDScramble tools using git (with authentication for wp15) and pip.

```console
git clone https://github.com/SIESTA-eu/wp15.git     # Or download the code yourself
pip install wp15/BIDScramble                        # Or use an alternative installer
```

## Usage

To scramble BIDS data you can run the command-line tool named ``scramble``. At its base, this tool has an input and output argument, followed by a ``Action`` subcommand. The meaning and usage of these arguments is explained in more detail in the following sections.

### scramble

```
usage: scramble [-h] bidsfolder outputfolder {stub,tsv,nii,json,swap} ...

The general workflow to build up a scrambled BIDS dataset is by consecutively running `scramble` for actions of
your choice. For instance, you could first run `scramble` with the `stub` action to create a dummy dataset with
only the file structure and some basic files, and then run `scramble` with the `nii` action  to specifically add
scrambled NIfTI data (see examples below). To combine different scrambling actions, simply re-run `scramble` using
the already scrambled data as input folder.

positional arguments:
  bidsfolder            The BIDS (or BIDS-like) input directory with the original data
  outputfolder          The output directory with the scrambled pseudo data

options:
  -h, --help            show this help message and exit

Action:
  {stub,tsv,nii,json,swap}
                        Add -h, --help for more information
    stub                Saves a dummy bidsfolder skeleton in outputfolder
    tsv                 Saves scrambled tsv files in outputfolder
    nii                 Saves scrambled NIfTI files in outputfolder
    json                Saves scrambled json files in outputfolder
    swap                Saves swapped file contents in outputfolder

examples:
  scramble data/bids data/pseudobids stub -h
  scramble data/bids data/pseudobids nii -h
```

#### Action: stub

```
usage: scramble bidsfolder outputfolder stub [-h] [-s PATTERN] [-d]

Creates a copy of the BIDS input directory in which all files are empty stubs. Exceptions to this are the
'dataset_description.json', 'README', 'CHANGES', 'LICENSE' and 'CITATION.cff' files, which are copied over and
updated if possible.

options:
  -h, --help            show this help message and exit
  -s PATTERN, --select PATTERN
                        A fullmatch regular expression pattern that is matched against the relative path of the
                        input data. Files that match are scrambled and saved in outputfolder (default: .*)
  -d, --dryrun          Do not save anything, only print the output filenames in the terminal (default: False)

examples:
  scramble data/bids data/pseudobids stub
  scramble data/bids data/pseudobids stub -s '.*\.(nii|json|tsv)'
  scramble data/bids data/pseudobids stub -s '.*(?<!derivatives)'
  scramble data/bids data/pseudobids stub -s '(?!sub.*scans.tsv|/func/).*'
```

#### Action: tsv

```
usage: scramble bidsfolder outputfolder tsv [-h] [-s PATTERN] [-d] {permute} ...

Adds scrambled versions of the tsv files in the BIDS input directory to the BIDS output directory. If no scrambling
method is specified, the default behavior is to null all values.

positional arguments:
  {permute}             Scrambling method. Add -h, --help for more information
    permute             Randomly permute the column values of the tsv files

options:
  -h, --help            show this help message and exit
  -s PATTERN, --select PATTERN
                        A fullmatch regular expression pattern that is matched against the relative path of the
                        input data. Files that match are scrambled and saved in outputfolder (default: .*)
  -d, --dryrun          Do not save anything, only print the output filenames in the terminal (default: False)

examples:
  scramble data/bids data/pseudobids tsv
  scramble data/bids data/pseudobids tsv permute
  scramble data/bids data/pseudobids tsv permute -s '.*_events.tsv' -p '.*'
  scramble data/bids data/pseudobids tsv permute -s participants.tsv -p (participant_id|SAS.*)
```

#### Action: nii

```
usage: scramble bidsfolder outputfolder nii [-h] [-s PATTERN] [-d] [-c [SPECS]]
                                             {blur,permute,diffuse,wobble} ...

Adds scrambled versions of the NIfTI files in the BIDS input directory to the BIDS output directory. If no
scrambling method is specified, the default behavior is to null all image values.

positional arguments:
  {blur,permute,diffuse,wobble}
                        Scrambling method. Add -h, --help for more information
    blur                Apply a 3D Gaussian smoothing filter
    permute             Perform random permutations along one or more image dimensions
    diffuse             Perform random permutations using a sliding 3D permutation kernel
    wobble              Deform the images using 3D random waveforms

options:
  -h, --help            show this help message and exit
  -s PATTERN, --select PATTERN
                        A fullmatch regular expression pattern that is matched against the relative path of the
                        input data. Files that match are scrambled and saved in outputfolder (default: .*)
  -d, --dryrun          Do not save anything, only print the output filenames in the terminal (default: False)
  -c [SPECS], --cluster [SPECS]
                        Use the DRMAA library to submit the scramble jobs to a high-performance compute (HPC)
                        cluster. You can add an opaque DRMAA argument with native specifications for your HPC
                        resource manager (NB: Use quotes and include at least one space character to prevent
                        premature parsing -- see examples) (default: None)

examples:
  scramble data/bids data/pseudobids nii
  scramble data/bids data/pseudobids nii diffuse -h
  scramble data/bids data/pseudobids nii diffuse 2 -s 'sub-.*_MP2RAGE.nii.gz' -c '--mem=5000 --time=0:20:00'
  scramble data/bids data/pseudobids nii wobble -a 2 -f 1 8 -s 'sub-.*_T1w.nii'
```

#### Action: json

```
usage: scramble bidsfolder outputfolder json [-h] [-s PATTERN] [-d] [-p PATTERN]

Adds scrambled key-value versions of the json files in the BIDS input directory to the BIDS output directory. If no
preserve expression is specified, the default behavior is to null all values.

options:
  -h, --help            show this help message and exit
  -s PATTERN, --select PATTERN
                        A fullmatch regular expression pattern that is matched against the relative path of the
                        input data. Files that match are scrambled and saved in outputfolder (default: .*)
  -d, --dryrun          Do not save anything, only print the output filenames in the terminal (default: False)
  -p PATTERN, --preserve PATTERN
                        A fullmatch regular expression pattern that is matched against all keys in the json
                        files. The json values are copied over when a key matches positively (default: None)

examples:
  scramble data/bids data/pseudobids json
  scramble data/bids data/pseudobids json participants.json -p '.*'
  scramble data/bids data/pseudobids json 'sub-.*.json' -p '(?!AcquisitionTime|Date).*'
```

#### Action: swap

```
usage: scramble bidsfolder outputfolder swap [-h] [-s PATTERN] [-d] [-g ENTITY [ENTITY ...]]

Randomly swappes the content of data files between a group of similar files in the BIDS input directory and save
them as output.

options:
  -h, --help            show this help message and exit
  -s PATTERN, --select PATTERN
                        A fullmatch regular expression pattern that is matched against the relative path of the
                        input data. Files that match are scrambled and saved in outputfolder (default: .*)
  -d, --dryrun          Do not save anything, only print the output filenames in the terminal (default: False)
  -g ENTITY [ENTITY ...], --grouping ENTITY [ENTITY ...]
                        A list of (full-name) BIDS entities that make up a group between which file contents are
                        swapped. See: https://bids-
                        specification.readthedocs.io/en/stable/appendices/entities.html (default: ['subject'])

examples:
  scramble data/bids data/pseudobids swap
  scramble data/bids data/pseudobids swap -s '.*\.(nii|json|tsv)'
  scramble data/bids data/pseudobids swap -s '.*(?<!derivatives)'
  scramble data/bids data/pseudobids swap -g subject session run
```

## Legal Aspects

This code is released under the GPLv3 license.

## Related tools

- https://github.com/PennLINC/CuBIDS
- https://peerherholz.github.io/BIDSonym/
- https://arx.deidentifier.org
