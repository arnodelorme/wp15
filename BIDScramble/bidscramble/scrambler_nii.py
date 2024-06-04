import numpy as np
import scipy as sp
import nibabel as nib
import re
from tqdm import tqdm
from pathlib import Path
from typing import List


def scrambler_nii(bidsfolder: str, outputfolder: str, select: str, method: str, fwhm: float=0, dims: List[str]=(), independent: bool=False, dryrun: bool=False, **_):

    # Defaults
    inputdir  = Path(bidsfolder).resolve()
    outputdir = Path(outputfolder).resolve()

    # Create pseudo-random out data for all files of each included data type
    for inputfile in tqdm(sorted(inputdir.rglob('*')), unit='file', colour='green', leave=False):

        if not re.fullmatch(select, str(inputfile.relative_to(inputdir))) or inputfile.is_dir():
            continue

        # Define the output target
        outputfile = outputdir/inputfile.relative_to(inputdir)

        # Load the (zipped) nii data
        if '.nii' in inputfile.suffixes:
            inputimg = nib.load(inputfile)
        else:
            print(f"Skipping non-nii file: {outputfile}")
            continue

        # Apply the feature preservation method
        data = inputimg.get_fdata()
        if method == 'permute':
            axis = dict([(d,n) for n,d in enumerate(['x','y','z','t'])])        # NB: Assumes data is oriented in a standard way (i.e. no dim-flips, no rotations > 45 deg)
            for dim in dims:
                if independent:
                    np.random.default_rng().permuted(data, axis=axis[dim], out=data)
                else:
                    np.random.default_rng().shuffle(data, axis=axis[dim])
        elif method == 'blur':
            sigma = list(fwhm/inputimg.header['pixdim'][1:4]/2.355) + [0]*(data.ndim-3)     # No smoothing over any further dimensions such as time
            data = sp.ndimage.gaussian_filter(data, sigma)
        else:
            data = data * 0

        # Save the output data
        print(f"Saving: {outputfile}\n ")
        if not dryrun:
            outputfile.parent.mkdir(parents=True, exist_ok=True)
            outputimg = nib.Nifti1Image(data, inputimg.affine, inputimg.header)
            nib.save(outputimg, outputfile)
