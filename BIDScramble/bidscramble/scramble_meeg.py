#!/usr/bin/env python3

import numpy as np
import re
import mne
from tqdm import tqdm
from pathlib import Path
from typing import List
from . import get_inputfiles

def scramble_meeg(bidsfolder: str, outputfolder: str, select: str, bidsvalidate: bool, method: str= '', fwhm: float=0, dims: List[str]=(), independent: bool=False, radius: float=1, freqrange: List[float]=(0, 0), amplitude: float=1, dryrun: bool=False, **_):

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

        # Currently only works for fif files
        if israw:
            obj = mne.io.read_raw_fif(inputfile, preload=True)
        elif isevoked:
            obj = mne.Evoked(inputfile)
        elif isepoched:
            # DON'T know what to do yet, so do nothing for now, will throw an error below I guess
            print('not good')


        # Apply the scrambling method
        # NOTE to self -> read about np.random.default_rng().

        #if method == 'permute':
        #    axis = dict([(d,n) for n,d in enumerate(['x','y','z','t','u','v','w'])])    # NB: Assumes data is oriented in a standard way (i.e. no dim-flips, no rotations > 45 deg)
        #    for dim in dims:
        #        if independent:
        #            np.random.default_rng().permuted(data, axis=axis[dim], out=data)
        #        else:
        #           np.random.default_rng().shuffle(data, axis=axis[dim])
        #
        #elif method == 'blur':
        # etc
        def scramble(data):
            return np.random.permutation(data)

        obj.apply_function(scramble)

        # Save the output data
        outputfile = outputdir/inputfile.relative_to(inputdir)
        tqdm.write(f"Saving: {outputfile}")
        if not dryrun:
            outputfile.parent.mkdir(parents=True, exist_ok=True)
            obj.save(outputfile, overwrite=True)
