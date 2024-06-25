import re
import shutil
import random
from tqdm import tqdm
from pathlib import Path
from bids import BIDSLayout


def scramble_swap(bidsfolder: str, outputfolder: str, select: str, grouping: list, dryrun: bool=False, **_):

    # Defaults
    inputdir  = Path(bidsfolder).resolve()
    layout    = BIDSLayout(inputdir, validate=False)
    outputdir = Path(outputfolder).resolve()

    # Use a tempdir to catch inplace editing
    print(f"Swapping BIDS data in: {outputdir}")
    if outputdir == inputdir:
        outputdir = outputdir/'tmpdir_swap'
    outputdir.mkdir(parents=True, exist_ok=True)

    # Swap all sets of inputfiles
    swapped    = []                 # Already swapped input files
    inputfiles = [fpath for fpath in inputdir.rglob('*') if re.fullmatch(select, str(fpath.relative_to(inputdir))) and fpath.is_file()]
    for inputfile in tqdm(sorted(inputfiles), unit='file', colour='green', leave=False):

        if inputfile in swapped:
            continue

        # Get the inputset and swap it
        entities = layout.parse_file_entities(inputfile)
        for entity in grouping:
            entities.pop(entity, None)
        inputset  = [Path(fname) for fname in layout.get(**entities, return_type='filename') if Path(fname) in inputfiles]
        outputset = random.sample(inputset, len(inputset))

        # Save the swapped output files
        for n, inputfile in enumerate(inputset):

            outputfile = outputdir/outputset[n].relative_to(inputdir)
            if not dryrun:
                outputfile.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(inputfile, outputfile)

            swapped.append(inputfile)

    # Move the tempdir files to the outputdir
    if outputdir.name == 'tmpdir_swap':
        for outputfile in [tmpfile for tmpfile in outputdir.rglob('*') if tmpfile.is_file()]:
            outputfile.replace(outputdir.parent/outputfile.relative_to(outputdir))
        shutil.rmtree(outputdir)
