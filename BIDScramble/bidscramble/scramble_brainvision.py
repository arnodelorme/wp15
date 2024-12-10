#!/usr/bin/env python3

import numpy as np
import brainvision
from tqdm import tqdm
from pathlib import Path
from . import get_inputfiles

def scramble_brainvision(inputdir: str, outputdir: str, select: str, bidsvalidate: bool, method: str='null', dryrun: bool=False, **_):

    # Defaults
    inputdir  = Path(inputdir).resolve()
    outputdir = Path(outputdir).resolve()

    # Create pseudo-random out data for all files of each included data type
    inputfiles = get_inputfiles(inputdir, select, '*.vhdr', bidsvalidate)
    for inputfile in tqdm(inputfiles, unit='file', colour='green', leave=False):

        (vhdr, vmrk, data) = brainvision.read(inputfile)

        def do_permute(data):
            # scramble the samples in each channel
            rng = np.random.default_rng()
            for channel in range(data.shape[0]):
                data[channel] = rng.permutation(data[channel])
            return data

        def do_null(data):
            return data * 0

        # Apply the scrambling method
        if method == 'permute':
            data = do_permute(data)
        elif method == 'null':
            data = do_null(data)
        else:
            raise ValueError(f"Unknown brainvision-scramble method: {method}")

        # Save the output data
        outputfile = outputdir/inputfile.relative_to(inputdir)
        tqdm.write(f"Saving: {outputfile}")
        if not dryrun:
            outputfile.parent.mkdir(parents=True, exist_ok=True)
            brainvision.write(outputfile, vhdr, vmrk, data)
