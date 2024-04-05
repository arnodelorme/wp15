This usecase implements a pipeline that analyses univariate tabular data.

Input data:
participants.tsv file from a specified BIDS-dataset. I added one such file to this usecase, but in principle it should work with any participants.tsv file.

Output data:
a tsv-file containing the output of the computation, in this case the average age of the participants of the experiment.

Software prerequisites:
the R-software needs to be installed, specifically including the Rscript binary.
R-library dependency: optparse needs to be installed (it's a bit over-engineered for now, but this is on purpose).

Deployment of the pipeline from the command line (if present working directory is at this level):
DATASET=./data/ds004148
OUTFILE=ds004148_output.tsv
Rscript pipeline_20240328.R -f $DATASET -o $OUTFILE
