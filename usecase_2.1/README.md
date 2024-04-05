This usecase implements a pipeline that analyses univariate tabular data.

Input data:
participants.tsv file from a specified BIDS-dataset. I added one such file to this usecase, but in principle it should work with any participants.tsv file.

Output data:
a tsv-file containing the output of the computation, in this case the average age of the participants of the experiment.

Software prerequisites:
the R-software needs to be installed, specifically including the Rscript binary.
R-package dependency: optparse needs to be installed, and on the R-package library path. This is because the pipeline code is  a bit over-engineered for now, but this is on purpose. For now, I have installed the package (because it may not be present at default for a lean R install), and point to it in the below example, by specifying the R_LIBS_SITE variable.

Deployment of the pipeline from the Linux command line (if present working directory is at this level):
R_LIBS_SITE=../Rpackages/
DATASET=./data/ds004148
OUTFILE=ds004148_output.tsv
Rscript pipeline_20240328.R -f $DATASET -o $OUTFILE
