import re
import shutil
import json
from tqdm import tqdm
from urllib.request import urlopen
from pathlib import Path
from . import __version__, __description__, __url__


def scramble_stub(bidsfolder: str, outputfolder: str, select: str, dryrun: bool=False, **_):

    # Defaults
    inputdir  = Path(bidsfolder).resolve()
    outputdir = Path(outputfolder).resolve()
    outputdir.mkdir(parents=True, exist_ok=True)

    # Create placeholder output files for selected input files
    print(f"Creating BIDS stub data in: {outputdir}")
    for inputfile in tqdm(sorted(inputdir.rglob('*')), unit='file', colour='green', leave=False):

        if not re.fullmatch(select, str(inputfile.relative_to(inputdir))):
            continue

        outputfile = outputdir/inputfile.relative_to(inputdir)
        tqdm.write(f"--> {outputfile}")
        if inputfile.is_dir() and not dryrun:
            outputfile.mkdir(parents=True, exist_ok=True)
        elif not dryrun:
            outputfile.parent.mkdir(parents=True, exist_ok=True)
            outputfile.touch()

    # Create a dataset description file
    dataset_file = inputdir/'dataset_description.json'
    description  = {}
    if dataset_file.is_file():
        with dataset_file.open('r') as fid:
            description = json.load(fid)
    description['GeneratedBy'] = [{'Name':'BIDScramble', 'Version':__version__, 'Description:':__description__, 'CodeURL':__url__}]
    description['DatasetType'] = 'derivative'
    print(f"Writing: {dataset_file.name} -> {outputdir}")
    if not dryrun:
        with (outputdir/dataset_file.name).open('w') as fid:
            json.dump(description, fid, indent=4)

    # Copy the modality agnostic root files if they exist
    for fname in [name for name in ('README','README.txt','README.md','README.rst','CHANGES','LICENSE','CITATION.cff') if (inputdir/name).is_file()]:
        print(f"Copying: {fname} -> {outputdir}")
        if not dryrun:
            shutil.copyfile(inputdir/fname, outputdir/fname)

    # Download the LICENSE file if it's not there
    license = description.get('License')
    if not (inputdir/'LICENSE').is_file() and license:
        response = urlopen('https://spdx.org/licenses/licenses.json')
        licenses = json.loads(response.read())['licenses']
        for item in licenses:
            if license in (item['name'], item['licenseId']):
                print(f"Downloading a '{item['licenseId']}' SPDX license file -> {outputdir}")
                response = urlopen(item['detailsUrl'])
                license  = json.loads(response.read())['licenseText']
                if not dryrun:
                    (outputdir/'LICENSE').write_text(license)
                break
