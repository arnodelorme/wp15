# SIESTA - work package 15 - use case 2.4

This implements the Event-Related Potential [(ERP)](https://en.wikipedia.org/wiki/Event-related_potential) analysis of 'classical' [ElectroEncephalography](https://en.wikipedia.org/wiki/Electroencephalography) research paradigms. This represents a very common type of biomedical data. The data are simple enough, allow automated data processing, and follows the BIDS standard.

## Input data

The input data is a freely available online resource named "ERP CORE" [[1]], consisting of optimized paradigms, experiment control scripts, example data from 40 neurotypical adults, data processing pipelines and analysis scripts, and a broad set of results for 7 widely used ERP components: N170, mismatch negativity (MMN), N2pc, N400, P3, lateralized readiness potential (LRP), and error-related negativity (ERN).

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

## Pseudo data

A scrambled version of the data can be generated using ...

## Output data

The output will consist of only files and folders for group-level aggregated data. Many more individual-subject files are generated but should not be given as output. The output files corresponding to the aggregated data are listed in the `output_manifest.txt` file.

## Analysis pipeline

### Software Installation

This requires the GitHub wp15 repository, [MATLAB](https://www.mathworks.com) with the [EEGLAB](https://sccn.ucsd.edu/eeglab) external toolbox.
Once EEGLAB is installed, 
and the [LIMO MEEG master version](https://github.com/LIMO-EEG-Toolbox/limo_tools/tree/master) plugin. 

The LIMO tools must be placed inside the EEGLAB plugin folder as shown below.

```console
wget https://sccn.ucsd.edu/eeglab/currentversion/eeglab_current.zip
unzip eeglab_current.zip
git clone -b master https://github.com/LIMO-EEG-Toolbox/limo_tools.git
mv limo_tools eeglab2024.0/plugins/
git clone https://github.com/SIESTA-eu/wp15.git
mv wp15/usecase-2.4/2.4.A/ERP_Core_WB.m .
rm eeglab_current.zip
```

You should now have something like:

    README.md (this file)
    ERP_Core_WB.m
    input
    ├── CHANGES
    ├── LICENSE
    ├── [..]
    ├── sub-001
    ├── sub-002
    ├── sub-003
    └── [..]
    eeglab2024.0
    ├── [..]
    ├── eeglab.m
    ├── eeglab.prj
    ├── functions
    ├── plugins
    │   └── limo_tools
    └── [..]

There are also 6 additional EEGLAB plugins/dependencies to be installed (bids-matlab-tools, zapline-plus, clean_rawdata, PICARD, ICLabel and Fieldtrip-lite).
This is best to install those directly from within the matlab environment, ensuring all paths are set.

```console
matlab
```

Here edit the 1st line of code below with your path to EEGLAB and run the code in the MATLAB command window
```matlab
addpath('/usr/bin/matlab/eeglab'); eeglab('nogui')
plugin_askinstall('bids-matlab-tools',[],1);
plugin_askinstall('zapline-plus',[],1);
plugin_askinstall('clean_rawdata',[],1);
plugin_askinstall('picard', 'picard', 1);
plugin_askinstall('ICLabel', 'picard', 1);
plugin_askinstall('Fieldtrip-lite', 'Fieldtrip-lite', 1);
if ~exist('pop_importbids','file') || ...
        ~exist('pop_zapline_plus','file') || ...
        ~exist('picard','file') || ...
        ~exist('ft_prepare_neighbours','file') || ...
        ~exist('limo_eeg','file')
    error('1 or more of the necessary plugins is not found');
else
    disp('all plugins found')
    savepath
end
```

Once all is installed, the EEGLAB plugins directory should look likle this

    eeglab2024.0
    ├── [..]
    ├── eeglab.m
    ├── eeglab.prj
    ├── functions
    ├── plugins
    │   └── bids-matlab-tools8.0
    │   └── clean_rawdata2.91
    │   └── Fieldtrip-lite20240111
    │   └── ICLabel1.6
    │   └── limo_tools
    │   └── PICARD1.0
    │   └── zapline-plus1.2.1

### Legal aspects of the required software

MATLAB is commercial software.

EEGLAB is open source and released under the 2-clause BSD license.

LIMO MEEG is open-source software released under the MIT License.

FieldTrip is open source software and released under the GPLv3 license.

### Executing the pipeline

Executing the pipeline from the Linux command-line is done like this:

```console
matlab -nojvm -nodisplay -nosplash -r "restoredefaultpath; ERP_Core_WB_install; ERP_Core_WB('input', 'output'); exit"
```

Executing the pipeline from the MATLAB command window is done like this:

```matlab
restoredefaultpath;
ERP_Core_WB_install;
ERP_Core_WB(fullfile(pwd, 'input'), fullfile(pwd, 'output'))
```

where `input` is the input folder and `output` the output folder. The absolute paths need to be provided for the pipeline to run smoothly.

> **Note**: The MATLAB functions `ERP_Core_WB_install.m` and `ERP_Core_WB.m` must be in the MATLAB path or in the present working directory.

### Cleaning up

Cleaning up the input and output data is done using:

```console
rm -rf input
rm -rf output
```

## References

[1]: https://doi.org/10.18115/D5JW4R
