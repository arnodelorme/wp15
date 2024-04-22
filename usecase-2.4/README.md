# SIESTA - work package 15 - use case 2.4

This implements the Event-Related Potential [(ERP)](https://en.wikipedia.org/wiki/Event-related_potential) analysis of 'classical' [ElectroEncephalography](https://en.wikipedia.org/wiki/Electroencephalography) research paradigms. This represents a very common type of biomedical data.  The data are simple enough, allow automated data processing, and follow BIDS.

There are two versions: ``2.4.A`` and ``2.4.B``. Version ``2.4.A`` is fully automated, testing whether this can be run on anonymized data. Version ``2.4.B`` requires user interaction at the input level, minimizing what information is given to users given a research question at the output level.

## Input data

The BIDS input data is a freely available online resource named ERP CORE (https://doi.org/10.18115/D5JW4R), consisting of optimized paradigms, experiment control scripts, example data from 40 neurotypical adults, data processing pipelines and analysis scripts, and a broad set of results for 7 widely used ERP components: N170, mismatch negativity (MMN), N2pc, N400, P3, lateralized readiness potential (LRP), and error-related negativity (ERN). Included in this dataset are:

1. Raw data files for all 7 ERP components from 40 participants, located in subject folders 001-040
2. The event code schemes for all experiment paradigms
3. The task stimuli used for eliciting N170, MMN, and N400, located in the stimuli folder
4. Demographic information for all 40 participants ("participants.tsv &.json")

The data can be downloaded from [ERPCore BIDS dataset](https://osf.io/9f5w7/files/osfstorage).

### Legal aspects of the input data

Those data are openly ([CC-BY-4.0](https://spdx.org/licenses/CC-BY-4.0.html)) and freely available.

## Output data

The output data will consist of ...

## Analysis pipeline

### Software requirements

[Matlab](https://www.mathworks.com) with the [EGGLAB](https://sccn.ucsd.edu/eeglab) external toolbox and the [LIMO MEEG master version](https://github.com/LIMO-EEG-Toolbox/limo_tools/tree/master) plugin.   
  
**Installation**:  EEGLAB mus be added to the path, this can be done in the matlab command line with ``pathtool`` or with ``addpath(genpath(path_to_EEGLAB_folder))``. Similarly, LIMO tools must be placed inside the EEGLAB plugin folder as illustrated below.

EEGLAB  
├── Contents.m  
├── eeglablicense.txt  
├── eeglab.m  
├── eeglab.prj  
├── functions  
├── plugins  
│ &nbsp; &nbsp; &nbsp; └── limo_tools   
├── README.md  
├── sample_data  
├── sample_locs  
└── tutorial_scripts

### Legal aspects of the required software

...

### Executing the pipeline

Executing the pipeline from the Linux command line: 

```console
matlab -nojvm -nodisplay -nosplash -r "ERP_Core_WB('source', 'destination'); exit"
```

Executing the pipeline from the matlab command window: 

```matlab
ERP_Core_WB(source, destination)
```

Where `source` is the path to the BIDS dataset and `destination` is the path to the output folder

> **Note**: to execute from the Linux terminal, the matlab function must be in the matlab path or the terminal is located in the folder where the ERP_Core_WB.m function is.

### Cleaning up

Cleaning up the input and output data is done using:

```console
rm -rf source
rm -rf destination
```

## References

[1]: https://www.example.com
[2]: https://www.markdownguide.org/cheat-sheet/
