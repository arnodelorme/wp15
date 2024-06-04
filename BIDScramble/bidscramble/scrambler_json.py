import json
import re
from pathlib import Path


def clearvalues(data: dict, preserve: str):

    for key, value in data.items():
        if re.match(preserve, str(key)):
            continue
        elif isinstance(value, dict):
            clearvalues(value, preserve)
        else:
            data[key] = type(value)()


def scrambler_json(bidsfolder: str, outputfolder: str, include: str, preserve: str, **_):

    # Defaults
    inputdir  = Path(bidsfolder).resolve()
    outputdir = Path(outputfolder).resolve()

    # Create pseudo-random out data for all files of each included data type
    for inputfile in inputdir.rglob('*'):

        if not re.match(include, str(inputfile.relative_to(inputdir))) or inputfile.is_dir():
            continue

        # Define the output target
        outputfile = outputdir/inputfile.relative_to(inputdir)
        outputfile.parent.mkdir(parents=True, exist_ok=True)

        # Load the json data
        if inputfile.suffix == '.json':
            with open(inputfile, 'r') as f:
                jsondata = json.load(f)
        else:
            print(f"Skipping non-json file: {outputfile}")
            continue

        # Clear values that are not of interest
        clearvalues(jsondata, preserve)

        # Save the output data
        print(f"Saving: {outputfile}\n ")
        outputfile.parent.mkdir(parents=True, exist_ok=True)
        with outputfile.open('w') as fid:
            json.dump(jsondata, fid, indent=4)
