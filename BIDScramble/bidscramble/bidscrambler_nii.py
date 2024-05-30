#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Adds scrambled versions of the NIfTI files in the BIDS input directory to the BIDS output directory.
"""

import argparse
import textwrap
import numpy as np
import scipy as sp
import nibabel as nib
from pathlib import Path
from typing import List


def bidscrambler_nii(inputdir: str, outputdir: str, include: str, method: str, fwhm: float=0, dims: List[str]=(), independent: bool=False):

    # Defaults
    inputdir  = Path(inputdir).resolve()
    outputdir = Path(outputdir).resolve()

    # Create pseudo-random out data for all files of each included data type
    for inputfile in inputdir.rglob(include):

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
        outputfile.parent.mkdir(parents=True, exist_ok=True)
        outputimg = nib.Nifti1Image(data, inputimg.affine, inputimg.header)
        nib.save(outputimg, outputfile)


def main():
    """Console script entry point"""

    # Parse the input arguments and run main(args)
    class CustomFormatter(argparse.ArgumentDefaultsHelpFormatter, argparse.RawDescriptionHelpFormatter):
        pass

    parser = argparse.ArgumentParser(formatter_class=CustomFormatter, description=textwrap.dedent(__doc__),
                                     epilog='examples:\n'
                                            "  bidscrambler_nii bids pseudobids '*.nii*'\n"
                                            "  bidscrambler_nii bids pseudobids 'sub-*_T1w.nii.gz' blur -h\n"
                                            "  bidscrambler_nii bids pseudobids 'sub-*_T1w.nii.gz' blur 20\n"
                                            "  bidscrambler_nii bids pseudobids 'sub-*_bold.nii' permute x z'\n ")
    parser.add_argument('inputdir',         help='The input directory with the real data')
    parser.add_argument('outputdir',        help='The output directory with generated pseudo data')
    parser.add_argument('include',          help='A wildcard pattern for selecting input files to be included in the output directory')
    subparsers = parser.add_subparsers(dest='method', help='Scrambling methods (by default the output images are nulled). Add -h for more help')
    subparser = subparsers.add_parser('blur',      help='Apply a 3D Gaussian smoothing filter')
    subparser.add_argument('fwhm',          help='The FWHM (in mm) of the isotropic 3D Gaussian smoothing kernel', type=float)
    subparser = subparsers.add_parser('permute',   help='Perfom random permutations along one or more image dimensions')
    subparser.add_argument('dims',          help='The dimensions along which the image will be permuted', nargs='*', choices=['x','y','z','t'], default=['x','y'])
    subparser.add_argument('-i', '--independent', help='Make all permutations along a dimension independent', action='store_true')
    args = parser.parse_args()

    bidscrambler_nii(**vars(args))


if __name__ == "__main__":
    main()
