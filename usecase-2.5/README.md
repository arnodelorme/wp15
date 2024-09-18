# SIESTA - work package 15 - use case 2.5

This implements ...

The pipeline is expected to be executed on a Linux computer.

## Input data

The input data is a freely available online resource named "OpenNeuro". More specifically, the suject database has [ds003020](https://openneuro.org/datasets/ds003020/versions/2.2.0) as Openneuro Accession Number. The input data consists of about 992 files with a combined size of 123.01GB. More specifically, the subject database includes 8 subjects. Each patient undergoes 16 sessions, each involving bold fMRI. The data can be downloaded using [datalab](https://www.datalad.org/). In order to be able to use [datalab](https://www.datalad.org/), a recent version of [git]( https://git-scm.com/downloads) is required.

````
/usr/bin/python3.8 -m venv siesta
source siesta/bin/activate
python -m pip install datalad
python -m pip install datalad-installer
datalad-installer git-annex -m datalad/git-annex:release --install-dir siesta
mv siesta/usr/lib/* siesta/lib/.
mv siesta/usr/bin/* siesta/bin/.
git clone https://github.com/OpenNeuroDatasets/ds003020.git input
#git clone https://github.com/OpenNeuroDatasets/ds004488.git ds004488
cd input 
datalad get sub-*
````

### Data citation

[Tang, J., LeBel, A., Jain, S. et al. Semantic reconstruction of continuous language from non-invasive brain recordings. Nat Neurosci 26, 858–866 (2023).](https://doi.org/10.1038/s41593-023-01304-9)

### Legal aspects of the input data

The input dataset has been released under the [CC0](https://spdx.org/licenses/CC0-1.0.html) license.

## Output data

The output data that is to be shared consists of folders and files that represent group-level aggregated data. 

The `whitelist.txt` file contains a complete list of the output data that is to be shared. 

## Analysis pipeline

### Software installation

This requires the Github wp15 repository, MATLAB and the Github spm12.zip file. 

### Legal aspects of the software

MATLAB is commercial software.

SPM is open source software and released under the GPLv2 license.

_Licenses for other software that is used are to be specified here._

### Executing the pipeline

Executing the pipeline is done by ...

## Cleaning up

Cleaning up the input and output data is done using ...
