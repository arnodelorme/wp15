#!/usr/bin/env python3

import numpy as np
import scipy as sp
import nibabel as nib
import re
import time
import os
import sys
import ast
from tqdm import tqdm
from pathlib import Path
from typing import List


def scrambler_nii(bidsfolder: str, outputfolder: str, select: str, method: str='', fwhm: float=0, dims: List[str]=(), independent: bool=False,
                  radius: float=1, freqrange: List[float]=(0,0), amplitude: float=1, cluster: str='', dryrun: bool=False, **_):

    # Defaults
    inputdir  = Path(bidsfolder).resolve()
    outputdir = Path(outputfolder).resolve()

    # Create pseudo-random out data for all files of each included data type
    inputfiles = [fpath for fpath in inputdir.rglob('*') if re.fullmatch(select, str(fpath.relative_to(inputdir))) and '.nii' in fpath.suffixes]
    if not inputfiles:
        print(f"No files found in {inputdir} using '{select}'")
        return
    else:
        print(f"Processing {len(inputfiles)} input files")

    # Submit scrambler jobs on the DRMAA-enabled HPC
    if cluster:

        # Lazy import to avoid import errors on non-HPC systems
        from drmaa import Session as drmaasession

        with drmaasession() as pbatch:
            jobids                  = []
            job                     = pbatch.createJobTemplate()
            job.jobEnvironment      = os.environ
            job.remoteCommand       = 'python'      # Call `python -m __name__` because `__file__` is not executable (NB: calling the scrambler parent instead of self would be much more complicated)
            job.nativeSpecification = drmaa_nativespec(cluster, pbatch)
            job.joinFiles           = True
            (outputdir/'logs').mkdir(exist_ok=True, parents=True)

            for inputfile in inputfiles:
                subid          = inputfile.name.split('_')[0].split('-')[1]
                sesid          = inputfile.name.split('_')[1].split('-')[1] if '_ses-' in inputfile.name else ''
                job.args       = ['-m', __name__, bidsfolder, outputfolder, inputfile.relative_to(inputdir), method, fwhm, dims, independent, radius, freqrange, amplitude, '', dryrun]
                job.jobName    = f"scrambler_nii_{subid}_{sesid}"
                job.outputPath = f"{os.getenv('HOSTNAME')}:{outputdir/'logs'/job.jobName}.out"
                jobids.append(pbatch.runJob(job))

            watchjobs(pbatch, jobids)
            pbatch.deleteJobTemplate(job)

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
            window = abs(np.int16(2 * radius / voxdim))                     # Size of the sliding window
            step   = [int(d/2) or 1 for d in window]                        # Sliding step (NB: int >= 1): e.g. 1/4 of the size of the sliding window (to speed up)
            tqdm.write(f"window: {window}\nstep: {step}")
            for x in range(0, data.shape[0] - window[0], step[0]):
                for y in range(0, data.shape[1] - window[1], step[1]):
                    for z in range(0, data.shape[2] - window[2], step[2]):
                        box = data[0+x:window[0]+x, 0+y:window[1]+y, 0+z:window[2]+z]
                        np.random.default_rng().permuted(box, out=box)
                        box = None
                        if x == data.shape[0] - window[0] - 1:              # We are at the edge, permute the remaining part
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


def drmaa_nativespec(specs: str, session) -> str:
    """
    Converts (CLI default) native Torque walltime and memory specifications to the DRMAA implementation (currently only Slurm is supported)

    :param specs:   Native Torque walltime and memory specifications, e.g. '-l walltime=00:10:00,mem=2gb' from argparse CLI
    :param session: The DRMAA session
    :return:        The converted native specifications
    """

    jobmanager: str = session.drmaaImplementation

    if '-l ' in specs and 'pbs' not in jobmanager.lower():

        if 'slurm' in jobmanager.lower():
            specs = (specs.replace('-l ', '')
                          .replace(',', ' ')
                          .replace('walltime', '--time')
                          .replace('mem', '--mem')
                          .replace('gb','000'))
        else:
            print(f"WARNING: Default `--cluster` native specifications are not (yet) provided for {jobmanager}. Please add them to your command if you get DRMAA errors")
            specs = ''

    return specs.strip()


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
    print(f"Finished processing all {len(jobids)} jobs")

    failedjobs = [jobid for jobid in jobids if pbatch.jobStatus(jobid)=='failed']
    if failedjobs:
        print(f"ERROR: {len(failedjobs)} HPC jobs failed to run:\n{failedjobs}\nThis may well be due to an underspecified `--cluster` input option (e.g. not enough memory)")


if __name__ == '__main__':
    """drmaa usage: python -m __name__ args"""

    args = sys.argv[1:]
    """ Non-str scrambler_nii() arguments indices (zero-based) that are passed as strings:
    4  fwhm: float
    5  dims: List[str]=()
    6  independent: bool=False
    7  radius: float=1
    8  freqrange: List[float]=(0,0)
    9  amplitude: float=1
    11 dryrun: bool=False
    """
    for n in list(range(4, 10)) + [11]:
        args[n] = ast.literal_eval(args[n])
    print('Running scrambler_nii with args:', args)

    scrambler_nii(*args)
