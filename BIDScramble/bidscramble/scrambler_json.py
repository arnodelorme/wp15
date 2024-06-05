import json
import re
from tqdm import tqdm
from pathlib import Path


def clearvalues(data: dict, preserve: str):

    for key, value in data.items():
        if re.fullmatch(preserve, str(key)):
            continue
        elif isinstance(value, dict):
            clearvalues(value, preserve)
        else:
            data[key] = type(value)()


def scrambler_json(bidsfolder: str, outputfolder: str, select: str='^$', preserve: str='^$', dryrun: bool=False, **_):

    # Defaults
    inputdir  = Path(bidsfolder).resolve()
    outputdir = Path(outputfolder).resolve()

    # Create pseudo-random out data for all files of each included data type
    for inputfile in tqdm(sorted(inputdir.rglob('*')), unit='file', colour='green', leave=False):

        if not re.fullmatch(select, str(inputfile.relative_to(inputdir))) or inputfile.suffix != '.json':
            continue

        # Load the json data
        with open(inputfile, 'r') as f:
            jsondata = json.load(f)

        # Clear values that are not of interest
        clearvalues(jsondata, preserve or '^$')

        # Save the output data
        outputfile = outputdir/inputfile.relative_to(inputdir)
        tqdm.write(f"Saving: {outputfile}")
        if not dryrun:
            outputfile.parent.mkdir(parents=True, exist_ok=True)
            with outputfile.open('w') as fid:
                json.dump(jsondata, fid, indent=4)
