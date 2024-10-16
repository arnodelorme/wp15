# SIESTA - work package 15 - use case 2.5

This implements ...

The pipeline is expected to be executed on a Linux computer and Matlab R2020b.

## Input data

The input data is a freely available online resource named "OpenNeuro". More specifically, the suject database has [ds004934](doi:10.18112/openneuro.ds004934.v1.0.0) as Openneuro Accession Number. The input data consists of about 1548 files with a combined size of 18.63G. More specifically, the subject database includes 44 subjects. These subjects are divided into two experiments: 17 subjects undergo fMRIs dedicated to experiment 1 whereas 29 subjects undergo fMRIs dedicated to experiment 2. The data can be downloaded using [datalab](https://www.datalad.org/). In order to be able to use [datalab](https://www.datalad.org/), a recent version of [git]( https://git-scm.com/downloads) is required.

````
#create siesta python environment
python -m venv siesta
#activate siesta python environment
source siesta/bin/activate
#install datalab 
python -m pip install datalad
python -m pip install datalad-installer
datalad-installer git-annex -m datalad/git-annex:release --install-dir siesta
#move lib and bin in the same directory
mv siesta/usr/lib/* siesta/lib/.
mv siesta/usr/bin/* siesta/bin/.
#get subjects using datalad
git clone https://github.com/OpenNeuroDatasets/ds003020.git input
cd input 
datalad get sub-*
datalad unlock sub-*
````
### Data citation

[Liu, S., Lydic, K., Mei, L., & Saxe, R. (in press). Violations of physical and psychological expectations in the human adult brain. Imaging Neuroscience.](https://doi.org/10.1162/imag_a_00068)

### Legal aspects of the input data
The input dataset has been released under the [CC0](https://spdx.org/licenses/CC0-1.0.html) license.

## Output data

The output data has the following architecture:
- 

The `whitelist.txt` file contains a complete list of the output data that is to be shared. 

## Analysis pipeline

After downloading the subject database, a modified SPM version and wp15 repository are installed.
- a modified SPM version (no user interactive sections)
````
cd
git clone https://github.com/OpenNeuroDatasets/ds003020.git input](https://github.com/Marque-CerCo/spm.git spm
````
- the source repository
````
cd
git clone source
````

### Software installation

This requires the Github source repository, SPM and MATLAB software. 

### Legal aspects of the software

MATLAB is commercial software.

SPM is open source software and released under the GPLv2 license.

_Licenses for other software that is used are to be specified here._

### Executing the pipeline

Executing the pipeline from the Linux command-line is done like this:
````
#execute matlab code
matlab -nodesktop -nodisplay -nosplash -noFigureWindows -r "workPackageCerCo; exit"
````

## Cleaning up

Cleaning up the input and output data is done using:
````
cd
sudo rm -r input
sudo rm -r output
````
