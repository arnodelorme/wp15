import numpy as np
import mne

def scrambler_nii(bidsfolder: str, outputfolder: str, select: str, method: str='', fwhm: float=0, dims: List[str]=(), independent: bool=False, radius: float=1, freqrange: List[float]=(0,0), amplitude: float=1, dryrun: bool=False, **_):

    # Defaults
    inputdir  = Path(bidsfolder).resolve()
    outputdir = Path(outputfolder).resolve()

    # Create pseudo-random out data for all files of each included data type
    inputfiles = [fpath for fpath in inputdir.rglob('*') if re.fullmatch(select, str(fpath.relative_to(inputdir))) and '.nii' in fpath.suffixes]
    for inputfile in tqdm(sorted(inputfiles), unit='file', colour='green', leave=False):

        # Currently only works for fif files
        raw = mne.io.read_raw_fif(inputfile, preload=True)

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
        def scrambler(data)
            return.np.random.permutation(data)
        raw.apply_function(scrambler)

        # Save the output data
        outputfile = outputdir/inputfile.relative_to(inputdir)
        tqdm.write(f"Saving: {outputfile}")
        if not dryrun:
            outputfile.parent.mkdir(parents=True, exist_ok=True)
            raw.save(fnameout)
