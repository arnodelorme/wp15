#!/usr/bin/env python3

import numpy as np
import re
import mne
from tqdm import tqdm
from pathlib import Path
from . import get_inputfiles

def scramble_fif(bidsfolder: str, outputfolder: str, select: str, bidsvalidate: bool, method: str='', dryrun: bool=False, **_):

    # Defaults
    inputdir  = Path(bidsfolder).resolve()
    outputdir = Path(outputfolder).resolve()

    # Create pseudo-random out data for all files of each included data type
    inputfiles = get_inputfiles(inputdir, select, '*.fif', bidsvalidate)
    for inputfile in tqdm(inputfiles, unit='file', colour='green', leave=False):

        # Figure out which reader function to use, fif-files with time-series data come in 3 flavours
        fiffstuff = mne.io.show_fiff(inputfile)
        isevoked  = re.search('FIFFB_EVOKED', fiffstuff) != None
        isepoched = re.search('FIFFB_MNE_EPOCHS', fiffstuff) != None
        israw     = not isepoched and not isevoked

        # Read the data
        if israw:
            obj = mne.io.read_raw_fif(inputfile, preload=True)
        elif isevoked:
            obj = mne.Evoked(inputfile)
        elif isepoched:
            raise Exception('cannot read epoched FIF file')

        def do_permute(data):
            return np.random.permutation(data)

        def do_null(data):
            return data * 0

        # Apply the scrambling method
        if method == 'permute':
            obj.apply_function(do_permute)
        else:
            obj.apply_function(do_null)

        # Save the output data
        outputfile = outputdir/inputfile.relative_to(inputdir)
        tqdm.write(f"Saving: {outputfile}")
        if not dryrun:
            outputfile.parent.mkdir(parents=True, exist_ok=True)
            obj.save(outputfile, overwrite=True)
