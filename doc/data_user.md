# Data user

The data user is the researcher that aims to answer a specific research question using the data that is made available for analysis through the SIESTA platform. As the data is sensitive, the data itself is not directly available for download. The SIESTA platform allows the data user to interactively implement an analysis, which eventually is converted to an Apptainer and executed by the platforn owner on the data of behalf of the data user. 

## Developing and testing the analysis

T.b.d.

### Participant level

T.b.d.

### Group level

T.b.d.

## Storage requirements

The data user must specify to the platform owner what the storage requirements are for the analysis. How many file are created, how much storage does that require, what is the retention period of the intermediate data, and what data files comprise the final results that the data user needs.

The original dataset is not accessible to the data user and should be considered read-only. The analysis pipeline should not write any results to the original dataset. There is one output directory to hold the intermediate (scratch) results, the participant-level results, and the group-level results. It is up to the data user how to organize the data in the output directory.

## Computational requirements

The data user must specify to the platform owner what the computational requirements are for the analysis. Besides the amount of computational time and memory of the processes, the data user can specify whether the participant-level step in the analysis can be executed in parallel or not.

The analysis must be implemented as a containerized [BIDS application](https://doi.org/10.1371/journal.pcbi.1005209). For development and testing we recommend to use a Linux-based environment where the data user has full administrative rights to install software and dependencies. The steps for software and dependency installation must be transferred to a container definition file.

If the data user want to make use of MATLAB in the analysis, they should give the plarform owner access to the MATLAB license server and provide the `LM_LICENSE_FILE` environment variable.