# SIESTA - work package 15 - use case 2.4

This implements the [Event-Related Potential](https://en.wikipedia.org/wiki/Event-related_potential) (ERP) analysis of 'classical' [ElectroEncephalography](https://en.wikipedia.org/wiki/Electroencephalography) research paradigms. This represents a very common type of biomedical data. The data are simple enough, allow automated data processing, and follows the BIDS standard.

The pipeline is expected to be executed on a Linux computer, although it might also work on macOS or Windows.

## Input data

The input data is a freely available online resource named ["ERP CORE"](https://doi.org/10.18115/D5JW4R), consisting of optimized paradigms, experiment control scripts, example data from 40 neurotypical adults, data processing pipelines and analysis scripts, and a broad set of results for 7 widely used ERP components: N170, mismatch negativity (MMN), N2pc, N400, P3, lateralized readiness potential (LRP), and error-related negativity (ERN).

The input data consists of about 2000 files with a combined size of 24.1GB.

Included in this dataset are:

1. Raw data files for all 7 ERP components from 40 participants
2. The event code schemes for all experiment paradigms
3. The task stimuli used for eliciting N170, MMN, and N400, located in the stimuli folder
4. Demographic information for all 40 participants ("participants.tsv & participants.json")

The data can be downloaded from [ERPCore BIDS dataset](https://osf.io/9f5w7/files/osfstorage) or by installing and running the [osfclient](https://github.com/osfclient/osfclient). The osfclient downloads the data an order of magnitude faster, is more stable for long downloads, and ensures that the directory structure is preserved.

```console
python -m venv venv
source venv/bin/activate
pip install osfclient
osf -p 9f5w7 clone download
mv download/osfstorage/ERP_CORE_BIDS_Raw_Files ./input
rm -rf download
```

### Data citation

Emily S. Kappenman, Jaclyn L. Farrens, Wendy Zhang, Andrew X. Stewart, Steven J. Luck (2021). ERP CORE: An open resource for human event-related potential research. NeuroImage. doi:j.neuroimage.2020.117465

### Legal aspects of the input data

The input dataset has been released under the [CC-BY-4.0](https://spdx.org/licenses/CC-BY-4.0.html) license.

## Output data

The output data that is to be shared consists of folders and files that represent group-level aggregated data. Many more individual-subject files are generated but these should not be shared with the researcher.

The `whitelist.txt` file contains a complete list of the output data that is to be shared. 

```console
cd wp15/usecase-2.4
mkdir output
```

## Analysis pipeline

### Legal aspects of the software

MATLAB is commercial software.

EEGLAB is open source and released under the 2-clause BSD license.

LIMO MEEG is open-source software released under the MIT License.

FieldTrip is open source software and released under the GPLv3 license.

The code that is specific to the analysis pipeline is shared under the CC0 license.

### Software installation

This requires the GitHub wp15 repository, [MATLAB](https://www.mathworks.com) with the [EEGLAB](https://sccn.ucsd.edu/eeglab) external toolbox. Once EEGLAB is installed, the [LIMO MEEG master version](https://github.com/LIMO-EEG-Toolbox/limo_tools/tree/master) plugin needs to be installed inside the EEGLAB plugin folder as shown below.

There are also a number of additional EEGLAB plugins/dependencies (bids-matlab-tools, zapline-plus, bva-io, clean_rawdata, Firfilt, PICARD, ICLabel and Fieldtrip-lite). Some come by default with EEGLAB, but the code below ensures they are all there.

```console
git clone https://github.com/SIESTA-eu/wp15.git
cd wp15/usecase-2.4

wget https://github.com/sccn/eeglab/archive/refs/tags/2024.2.1.zip
unzip 2024.2.1.zip
mv eeglab-2024.2.1 eeglab
rm 2024.2.1.zip

git clone -b v4.0 --depth 1 https://github.com/LIMO-EEG-Toolbox/limo_tools.git
mv limo_tools           eeglab/plugins/limo_tools

wget https://sccn.ucsd.edu/eeglab/plugins/fieldtrip-lite-20240111.zip
wget https://sccn.ucsd.edu/eeglab/plugins/bva-io1.73.zip
wget https://sccn.ucsd.edu/eeglab/plugins/firfilt2.8.zip
wget https://sccn.ucsd.edu/eeglab/plugins/ICLabel1.6.zip
wget https://sccn.ucsd.edu/eeglab/plugins/clean_rawdata2.91.zip
wget https://sccn.ucsd.edu/eeglab/plugins/zapline-plus1.2.1.zip
wget https://sccn.ucsd.edu/eeglab/plugins/picard-matlab.zip
wget https://sccn.ucsd.edu/eeglab/plugins/bids-matlab-tools8.0.zip

unzip fieldtrip-lite-20240111.zip 
unzip bva-io1.73.zip 
unzip firfilt2.8.zip 
unzip ICLabel1.6.zip 
unzip clean_rawdata2.91.zip 
unzip zapline-plus1.2.1.zip 
unzip picard-matlab.zip 
unzip bids-matlab-tools8.0.zip 

rm *.zip

mv fieldtrip-20240111   eeglab/plugins/Fieldtrip-lite20240111
mv bva-io               eeglab/plugins/bva-io1.73
mv firfilt              eeglab/plugins/firfilt2.8
mv ICLabel              eeglab/plugins/ICLabel1.6
mv clean_rawdata        eeglab/plugins/clean_rawdata2.91
mv zapline-plus-1.2.1   eeglab/plugins/apline-plus1.2.1
mv picard-matlab        eeglab/plugins/PICARD1.0
mv bids-matlab-tools    eeglab/plugins/bids-matlab-tools8.0
```

Once all is installed, it should look like this

```console
├── README.md (this file)
├── work
│   ├── bidsapp.m
│   ├── ERP_Core_WB.m
│   ├── ERP_Core_WB_install.m
│   └── ERP_Core_eeglab2brainvision.m
├── eeglab
│   ├── [..]
│   ├── eeglab.m
│   ├── eeglab.prj
│   ├── functions
│   ├── plugins
│   |   └── bids-matlab-tools8.0
│   |   └── bva-io1.73
│   |   └── clean_rawdata2.91
│   |   └── Fieldtrip-lite20240111
│   |   └── firfilt2.8
│   |   └── ICLabel1.6
│   |   └── limo_tools
│   |   └── PICARD1.0
│   |   └── zapline-plus1.2.1
│   │   └── [..]
├── input
│   ├── CHANGES
│   ├── LICENSE
│   ├── [..]
│   ├── sub-001
│   ├── sub-002
│   ├── sub-003
│   └── [..]
└── output
```

Alternatively, you can install the software in an Apptainer container image.

```console
cd wp15/usecase-2.4
apptainer build pipeline.sif pipeline.def
cd ../..
```

### Executing the pipeline

Executing the pipeline from the MATLAB command window is done like this:

```matlab
cd wp15/usecase-2.4
restoredefaultpath
addpath eeglab
addpath work

bidsapp input output participant
bidsapp input output group
```

Executing the pipeline from the Linux terminal is done like this:

```console
cd wp15/usecase-2.4
matlab -batch "cd wp15/usecase-2.4; restoredefaultpath; addpath eeglab source; bidsapp input output participant"
matlab -batch "cd wp15/usecase-2.4; restoredefaultpath; addpath eeglab source; bidsapp input output group"
```

Executing the pipeline from the Apptainer image is done like this:

```console
cd wp15/usecase-2.4
apptainer run --env MLM_LICENSE_FILE=port@server pipeline.sif input output participant
apptainer run --env MLM_LICENSE_FILE=port@server pipeline.sif input output group
```

It may be neccessay to use the `--bind` option to map the external and internal directories with input and output data.

## Cleaning up

Cleaning up the input and output data is done using:

```console
cd wp15/usecase-2.4
rm -rf input output
```

## Scrambled data

As in SIESTA the data is assumed to be sensitive, the analysis is conceived to be designed and implemented on a scrambled version of the dataset. Note that that is not needed here, as the original input and output data can be accessed directly. 

 A scrambled version of the data can be generated using [BIDScramble](https://github.com/SIESTA-eu/wp15/tree/main/BIDScramble).

```console
scramble input output stub
scramble input output json -p '.*'
scramble input output brainvision
```
