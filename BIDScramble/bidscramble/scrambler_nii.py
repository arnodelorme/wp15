#!/usr/bin/env python3

import numpy as np
import scipy as sp
import nibabel as nib
import re
import time
from tqdm import tqdm
from pathlib import Path
from typing import List


def scrambler_nii(bidsfolder: str, outputfolder: str, select: str, method: str='', fwhm: float=0, dims: List[str]=(), independent: bool=False,
                  radius: float=1, freqrange: List[float]=(0,0), amplitude: float=1, cluster: bool=False, nativespec: str= '', dryrun: bool=False, **_):

    # Defaults
    inputdir  = Path(bidsfolder).resolve()
    outputdir = Path(outputfolder).resolve()

    # Create pseudo-random out data for all files of each included data type
    inputfiles = [fpath for fpath in inputdir.rglob('*') if re.fullmatch(select, str(fpath.relative_to(inputdir))) and '.nii' in fpath.suffixes]

    # Submit scrambler jobs on the DRMAA-enabled HPC
    if cluster:

        # Lazy import to avoid import errors on non-HPC systems
        from drmaa import Session as drmaasession
        import os

        with drmaasession() as pbatch:
            jobids                 = []
            jt                     = pbatch.createJobTemplate()
            jt.jobEnvironment      = os.environ
            jt.remoteCommand       = __file__
            jt.nativeSpecification = nativespec
            jt.joinFiles           = True

            for inputfile in inputfiles:
                subid         = inputfile.name.split('_')[0].split('-')[1]
                sesid         = inputfile.name.split('_')[1].split('-')[1] if '_ses-' in inputfile.name else ''
                jt.args       = [bidsfolder, outputfolder, inputfile, method, fwhm, dims, independent, radius, freqrange, amplitude, False, nativespec, dryrun]
                jt.jobName    = f"scrambler_nii_{subid}_{sesid}"
                jobids.append(pbatch.runJob(jt))

            watchjobs(pbatch, jobids)
            pbatch.deleteJobTemplate(jt)

        return

    # Scramble the included input files
    for inputfile in tqdm(sorted(inputfiles), unit='file', colour='green', leave=False):

        # Load the (zipped) nii data
        inputimg: nib.ni1.Nifti1Image = nib.load(inputfile)
        data   = inputimg.get_fdata()
        voxdim = inputimg.header['pixdim'][1:4]
        if data.ndim < 3 and method in ('diffuse', 'wobble'):
            tqdm.write(f"WARNING: {inputfile} only has {data.ndim} image dimensions (must be 3 or more), aborting '{method}' scrambling...")
            continue

        # Apply the scrambling method
        if method == 'permute':
            axis = dict([(d,n) for n,d in enumerate(['x','y','z','t','u','v','w'])])    # NB: Assumes data is oriented in a standard way (i.e. no dim-flips, no rotations > 45 deg)
            for dim in dims:
                if independent:
                    np.random.default_rng().permuted(data, axis=axis[dim], out=data)
                else:
                    np.random.default_rng().shuffle(data, axis=axis[dim])

        elif method == 'blur':
            sigma = list(abs(fwhm/voxdim/2.355)) + [0]*4         # No smoothing over any further dimensions such as time (Nifti supports up to 7 dimensions)
            data  = sp.ndimage.gaussian_filter(data, sigma[0:data.ndim], mode='nearest')

        elif method == 'diffuse':
            window = abs(np.int16(2 * radius / voxdim))     # Size of the sliding window
            step   = [int(d/4) or 1 for d in window]                            # Sliding step (NB: int >= 1): e.g. 1/4 of the size of the sliding window (to speed up)
            for x in range(0, data.shape[0] - window[0], step[0]):
                for y in range(0, data.shape[1] - window[1], step[1]):
                    for z in range(0, data.shape[2] - window[2], step[2]):
                        box = data[0+x:window[0]+x, 0+y:window[1]+y, 0+z:window[2]+z]
                        np.random.default_rng().permuted(box, out=box)
                        box = None
                        if x == data.shape[0] - window[0] - 1:                  # We are at the edge, permute the remaining part
                            box = data[-step[0]:, 0+y:window[1]+y, 0+z:window[2]+z]
                        if y == data.shape[1] - window[1] - 1:
                            box = data[0+x:window[0]+x, -step[1]:, 0+z:window[2]+z]
                        if y == data.shape[2] - window[2] - 1:
                            box = data[0+x:window[0]+x, 0+y:window[1]+y, -step[2]:]
                        if box is not None:
                            np.random.default_rng().permuted(box, out=box)

        elif method == 'reface':
            pass

        elif method == 'wobble':
            # Implementation ideas:
            # 1. Add random k-space phase gradients in a mid-range frequency band while using a sliding window in image space
            # 2. Use a random deformation/warp field (see e.g. https://antspy.readthedocs.io/en/latest/registration.html)
            # 3. Apply random wavy (tapered wrap-around?) translations (https://numpy.org/doc/stable/reference/generated/numpy.roll.html) in x, y and z (repeatedly if that is still reversible?)
            for dim in (0,1,2,1,0):
                for axis in [ax for ax in (0,1,2) if ax != dim]:
                    index  = np.arange(data.shape[dim], dtype=np.float64)
                    wobble = 0 * index
                    lowfreq, highfreq = abs(np.float64(freqrange) * voxdim[dim] / index[-1])
                    if highfreq > 0.5:
                        tqdm.write(f"WARNING: the high-frequency in {freqrange} is higher than the Nyquist / maximum possible frequency: {0.5*index[-1] / voxdim[dim]}")
                    for f in np.arange(0, 0.5, 1 / index[-1]):
                        if lowfreq <= f <= highfreq:
                            wobble += np.sin(2*np.pi * (f * index + np.random.rand()))
                    for i in index.astype(int):
                        slab = (slice(None),) * dim + (i,)   # https://stackoverflow.com/questions/42817508/get-the-i-th-slice-of-the-k-th-dimension-in-a-numpy-array
                        data[slab] = np.roll(data[slab], round(amplitude * wobble[i]), axis=axis if axis < dim else axis - 1)

        else:
            data = data * 0

        # Save the output data
        outputfile = outputdir/inputfile.relative_to(inputdir)
        tqdm.write(f"Saving: {outputfile}")
        if not dryrun:
            outputfile.parent.mkdir(parents=True, exist_ok=True)
            outputimg = nib.Nifti1Image(data, inputimg.affine, inputimg.header)
            nib.save(outputimg, outputfile)


def watchjobs(pbatch, jobids: list):
    """
    Shows tqdm progress bars for queued and running DRMAA jobs. Waits until all jobs have finished

    :param pbatch: The DRMAA session
    :param jobids: The job ids
    :return:
    """

    qbar = tqdm(total=len(jobids), desc='Queued ', unit='job', leave=False, bar_format='{l_bar}{bar}| {n_fmt}/{total_fmt} [{elapsed}]')
    rbar = tqdm(total=len(jobids), desc='Running', unit='job', leave=False, bar_format='{l_bar}{bar}| {n_fmt}/{total_fmt} [{elapsed}]', colour='green')
    done = 0
    while done < len(jobids):
        jobs   = [pbatch.jobStatus(jobid) for jobid in jobids]
        done   = sum([status in ('done', 'failed', 'undetermined') for status in jobs])
        qbar.n = sum([status == 'queued_active'                    for status in jobs])
        rbar.n = sum([status == 'running'                          for status in jobs])
        qbar.refresh(), rbar.refresh()
        time.sleep(2)
    qbar.close(), rbar.close()

    if any([pbatch.jobStatus(jobid)=='failed' for jobid in jobids]):
        tqdm.write('ERROR: One or more HPC jobs failed to run')


if __name__ == 'main':
    """drmaa usage"""

    import sys

    scrambler_nii(*sys.argv[1:])
