#!/usr/bin/env python3

import numpy as np
import re
import mne
from tqdm import tqdm
from pathlib import Path
from . import get_inputfiles


def do_permute(data: np.ndarray) -> np.ndarray:
    # scramble the samples in each channel
    rng = np.random.default_rng()
    for channel in range(data.shape[0]):
        data[channel] = rng.permutation(data[channel])

    return data


def do_null(data: np.ndarray) -> np.ndarray:
    data *= 0

    return data


def scramble_fif(inputdir: str, outputdir: str, select: str, bidsvalidate: bool, method: str='null', dryrun: bool=False, **_):

    # Defaults
    inputdir  = Path(inputdir).resolve()
    outputdir = Path(outputdir).resolve()

    # Create pseudo-random out data for all files of each included data type
    inputfiles, _ = get_inputfiles(inputdir, select, '*.fif', bidsvalidate)
    for inputfile in tqdm(inputfiles, unit='file', colour='green', leave=False):

        # Figure out which reader function to use, fif-files with time-series data come in 3 flavours
        fiffstuff = mne.io.show_fiff(inputfile)
        isevoked  = re.search('FIFFB_EVOKED', fiffstuff) is not None
        isepoched = re.search('FIFFB_MNE_EPOCHS', fiffstuff) is not None
        israw     = not isepoched and not isevoked

        # Read the data
        if israw:
            obj = mne.io.read_raw_fif(inputfile, preload=True)
        elif isevoked:
            obj = mne.Evoked(inputfile)
        elif isepoched:
            raise Exception(f"cannot read epoched FIF file: {inputfile}")

        # Apply the scrambling method
        if method == 'permute':
            obj.apply_function(do_permute)

        elif method == 'null':
            obj.apply_function(do_null)

        else:
            raise ValueError(f"Unknown fif-scramble method: {method}")

        # Save the output data
        outputfile = outputdir/inputfile.relative_to(inputdir)
        tqdm.write(f"Saving: {outputfile}")
        if not dryrun:
            outputfile.parent.mkdir(parents=True, exist_ok=True)
            obj.save(outputfile, overwrite=True)
