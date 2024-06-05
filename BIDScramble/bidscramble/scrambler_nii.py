import numpy as np
import scipy as sp
import nibabel as nib
import re
from tqdm import tqdm
from pathlib import Path
from typing import List


def scrambler_nii(bidsfolder: str, outputfolder: str, select: str, method: str='', fwhm: float=0, dims: List[str]=(), independent: bool=False, radius: float=1, dryrun: bool=False, **_):

    # Defaults
    inputdir  = Path(bidsfolder).resolve()
    outputdir = Path(outputfolder).resolve()

    # Create pseudo-random out data for all files of each included data type
    for inputfile in tqdm(sorted(inputdir.rglob('*')), unit='file', colour='green', leave=False):

        if not re.fullmatch(select, str(inputfile.relative_to(inputdir))) or '.nii' not in inputfile.suffixes:
            continue

        # Load the (zipped) nii data
        inputimg: nib.ni1.Nifti1Image = nib.load(inputfile)
        data = inputimg.get_fdata()

        # Apply the scrambling method
        if method == 'permute':
            axis = dict([(d,n) for n,d in enumerate(['x','y','z','t'])])    # NB: Assumes data is oriented in a standard way (i.e. no dim-flips, no rotations > 45 deg)
            for dim in dims:
                if independent:
                    np.random.default_rng().permuted(data, axis=axis[dim], out=data)
                else:
                    np.random.default_rng().shuffle(data, axis=axis[dim])

        elif method == 'blur':
            sigma = list(fwhm/inputimg.header['pixdim'][1:4]/2.355) + [0]*(data.ndim-3)     # No smoothing over any further dimensions such as time
            data  = sp.ndimage.gaussian_filter(data, sigma)

        elif method == 'diffuse':
            if data.ndim not in (3,4):
                tqdm.write(f"WARNING: {inputfile} is not a 3D/4D image, aborting diffusion filter...")
                continue
            window = np.int16(2 * radius / inputimg.header['pixdim'][1:4])  # Size of the sliding window
            step   = [int(d/4) or 1 for d in window]                        # Sliding step (NB: int >= 1): e.g. 1/4 of the size of the sliding window (to speed up)
            for x in range(0, data.shape[0] - window[0], step[0]):
                for y in range(0, data.shape[1] - window[1], step[1]):
                    for z in range(0, data.shape[2] - window[2], step[2]):
                        slab = data[0+x:window[0]+x, 0+y:window[1]+y, 0+z:window[2]+z]
                        np.random.default_rng().permuted(slab, out=slab)

        elif method == 'reface':
            pass

        elif method == 'wobble':
            # Implementation ideas:
            # 1. Add random k-space phase gradients in a mid-range frequency band while using a sliding window in image space
            # 2. Use a random deformation/warp field (see e.g. https://antspy.readthedocs.io/en/latest/registration.html)
            # 3. Apply random wavy (tapered wrap-around) translations (https://numpy.org/doc/stable/reference/generated/numpy.roll.html) in x, y and z (repeatedly if that is still reversible?)
            pass

        else:
            data = data * 0

        # Save the output data
        outputfile = outputdir/inputfile.relative_to(inputdir)
        tqdm.write(f"Saving: {outputfile}")
        if not dryrun:
            outputfile.parent.mkdir(parents=True, exist_ok=True)
            outputimg = nib.Nifti1Image(data, inputimg.affine, inputimg.header)
            nib.save(outputimg, outputfile)
