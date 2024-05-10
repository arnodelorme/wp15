# SIESTA - work package 15 - use case 2.4

This implements the Event-Related Potential [(ERP)](https://en.wikipedia.org/wiki/Event-related_potential) analysis of 'classical' [ElectroEncephalography](https://en.wikipedia.org/wiki/Electroencephalography) research paradigms. This represents a very common type of biomedical data. The data are simple enough, allow automated data processing, and follow BIDS.

There are two versions: `2.4.A` and `2.4.B`. Version `2.4.A` is fully automated, testing whether this can be run on anonymized data. Version `2.4.B` requires user interaction at the input level, minimizing what information is given to users given a research question at the output level.

## Input data

The BIDS input data is a freely available online resource named ERP CORE (https://doi.org/10.18115/D5JW4R), consisting of optimized paradigms, experiment control scripts, example data from 40 neurotypical adults, data processing pipelines and analysis scripts, and a broad set of results for 7 widely used ERP components: N170, mismatch negativity (MMN), N2pc, N400, P3, lateralized readiness potential (LRP), and error-related negativity (ERN). Included in this dataset are:

1. Raw data files for all 7 ERP components from 40 participants, located in subject folders 001-040
2. The event code schemes for all experiment paradigms
3. The task stimuli used for eliciting N170, MMN, and N400, located in the stimuli folder
4. Demographic information for all 40 participants ("participants.tsv &.json")

The data can be downloaded from [ERPCore BIDS dataset](https://osf.io/9f5w7/files/osfstorage) or by installing and running the [OSF-client](https://github.com/osfclient/osfclient) (which downloads the data an order of magnitude faster):

```console
python -m venv venv
source venv/bin/activate
pip install osfclient
osf -p 9f5w7 clone usecase_2.4.A
mv usecase_2.4.A/osfstorage/ERP_CORE_BIDS_Raw_Files .
rm -rf usecase_2.4.A venv
```

### Data citation

Emily S. Kappenman, Jaclyn L. Farrens, Wendy Zhang, Andrew X. Stewart, Steven J. Luck (2021). ERP CORE: An open resource for human event-related potential research. NeuroImage. doi:j.neuroimage.2020.117465

### Legal aspects of the input data

Those data are openly ([CC-BY-4.0](https://spdx.org/licenses/CC-BY-4.0.html)) and freely available.

## Output data

The output data will consist of only folders and files for group-level (aggregated) data. Many more files are generated but should not be given as output.  All the files are listed in the [Output_group_level_files.txt](https://github.com/SIESTA-eu/wp15/blob/main/usecase-2.4/2.4.A/Output_group_level_files.txt) file as with a relative path to `ERP_CORE_usecase_2.4.A` path (see below Executing the pipeline).

## Analysis pipeline

### Software requirements

The GitHub WP15 repository, [MATLAB](https://www.mathworks.com) with the [EEGLAB](https://sccn.ucsd.edu/eeglab) external toolbox and the [LIMO MEEG master version](https://github.com/LIMO-EEG-Toolbox/limo_tools/tree/master) plugin.   
  
**Installation**: Download the usecase-2.4.A script, EEGLAB, and the LIMO tools. The latter must be placed inside the EEGLAB plugin folder as shown below.

```console
wget https://sccn.ucsd.edu/eeglab/currentversion/eeglab_current.zip
unzip eeglab_current.zip
git clone -b master https://github.com/LIMO-EEG-Toolbox/limo_tools.git
mv limo_tools eeglab2024.0/plugins/
git clone https://github.com/SIESTA-eu/wp15.git
mv wp15/usecase-2.4/2.4.A/ERP_Core_WB.m .
rm -rf eeglab_current.zip wp15  
```

You should now have something like:

    ERP_Core_WB.m  
    ERP_CORE_BIDS_Raw_Files
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

### Legal aspects of the required software

MATLAB is commercial software.

EEGLAB is open source and released under the 2-clause BSD license (the FieldTrip lite plugin is downloaded automatically; FieldTrip is open source software and released under the GPLv3 license).

LIMO MEEG is open-source software released under the MIT License.

###  
Executing the pipeline from the Linux command line:

```console
matlab -nojvm -nodisplay -nosplash -r "addpath('eeglab2024.0'); ERP_Core_WB('ERP_CORE_BIDS_Raw_Files', 'ERP_CORE_usecase_2.4.A'); exit"
```

Executing the pipeline from the MATLAB command window:

```matlab
addpath('eeglab2024.0')
ERP_Core_WB(fullfile(pwd, 'ERP_CORE_BIDS_Raw_Files'), fullfile(pwd, 'ERP_CORE_usecase_2.4.A'))
```

Where `ERP_CORE_BIDS_Raw_Files` is the input folder and `ERP_CORE_usecase_2.4.A` the output folder. The absolute paths need to be provided for the pipeline to run smoothly.

> **Note**: The MATLAB function must be in the MATLAB path or the terminal is located in the folder where the ERP_Core_WB.m function is.

### Cleaning up

Cleaning up the input and output data is done using:

```console
rm -rf ERP_CORE_BIDS_Raw_Files ERP_CORE_usecase_2.4.A eeglab2024.0 ERP_Core_WB.m
```

## References

[1]: https://www.example.com  
[2]: https://www.markdownguide.org/cheat-sheet/  
