import pandas as pd
import numpy as np
import re
from pathlib import Path


def scrambler_tsv(bidsfolder: str, outputfolder: str, include: str, preserve: str, **_):

    # Defaults
    inputdir  = Path(bidsfolder).resolve()
    outputdir = Path(outputfolder).resolve()

    # Create pseudo-random out data for all files of each included data type
    for inputfile in inputdir.rglob('*'):

        if not re.match(include, str(inputfile.relative_to(inputdir))) or inputfile.is_dir():
            continue

        # Define the output target
        outputfile = outputdir/inputfile.relative_to(inputdir)

        # Load the (zipped) tsv data
        if '.tsv' in inputfile.suffixes:
            tsvdata = pd.read_csv(inputfile, sep='\t')
        else:
            print(f"Skipping non-tsv file: {outputfile}")
            continue

        # Permute columns that are not of interest (i.e. preserve the relation between columns of interest)
        for column in tsvdata.columns:
            if not re.match(preserve, column):
                tsvdata[column] = np.random.permutation(tsvdata[column])

        # Permute the rows
        tsvdata = tsvdata.sample(frac=1).reset_index(drop=True)

        # Save the output data
        print(f"Saving: {outputfile}\n ")
        outputfile.parent.mkdir(parents=True, exist_ok=True)
        tsvdata.to_csv(outputfile, sep='\t', index=False, encoding='utf-8', na_rep='n/a')
