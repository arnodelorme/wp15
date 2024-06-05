import pandas as pd
import numpy as np
import re
from tqdm import tqdm
from pathlib import Path


def scrambler_tsv(bidsfolder: str, outputfolder: str, select: str, method: str, preserve: str, dryrun: bool=False, **_):

    # Defaults
    inputdir  = Path(bidsfolder).resolve()
    outputdir = Path(outputfolder).resolve()

    # Create pseudo-random out data for all files of each included data type
    for inputfile in tqdm(sorted(inputdir.rglob('*')), unit='file', colour='green', leave=False):

        if not re.fullmatch(select, str(inputfile.relative_to(inputdir))) or inputfile.is_dir():
            continue

        # Define the output target
        outputfile = outputdir/inputfile.relative_to(inputdir)

        # Load the (zipped) tsv data
        if '.tsv' in inputfile.suffixes:
            tsvdata = pd.read_csv(inputfile, sep='\t')
        else:
            continue

        # Permute columns that are not of interest (i.e. preserve the relation between columns of interest)
        if method == 'permute':
            for column in tsvdata.columns:
                if not re.fullmatch(preserve or '^$', column):
                    tsvdata[column] = np.random.permutation(tsvdata[column])
        else:
            tsvdata = pd.DataFrame(columns=tsvdata.columns, index=tsvdata.index)

        # Permute the rows
        tsvdata = tsvdata.sample(frac=1).reset_index(drop=True)

        # Save the output data
        tqdm.write(f"Saving: {outputfile}")
        if not dryrun:
            outputfile.parent.mkdir(parents=True, exist_ok=True)
            tsvdata.to_csv(outputfile, sep='\t', index=False, encoding='utf-8', na_rep='n/a')
