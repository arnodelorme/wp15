import pandas as pd
import numpy as np
import re
from tqdm import tqdm
from pathlib import Path


def scrambler_tsv(bidsfolder: str, outputfolder: str, select: str, method: str='', preserve: str='^$', dryrun: bool=False, **_):

    # Defaults
    inputdir  = Path(bidsfolder).resolve()
    outputdir = Path(outputfolder).resolve()

    # Create pseudo-random out data for all files of each included data type
    inputfiles = [fpath for fpath in inputdir.rglob('*') if re.fullmatch(select, str(fpath.relative_to(inputdir))) and '.tsv' in fpath.suffixes]
    for inputfile in tqdm(sorted(inputfiles), unit='file', colour='green', leave=False):

        # Load the (zipped) tsv data
        tsvdata = pd.read_csv(inputfile, sep='\t')

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
        outputfile = outputdir/inputfile.relative_to(inputdir)
        tqdm.write(f"Saving: {outputfile}")
        if not dryrun:
            outputfile.parent.mkdir(parents=True, exist_ok=True)
            tsvdata.to_csv(outputfile, sep='\t', index=False, encoding='utf-8', na_rep='n/a')
