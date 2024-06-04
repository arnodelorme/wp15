import re
import shutil
import json
from urllib.request import urlopen
from pathlib import Path
from . import __version__, __description__, __url__


def scrambler_stub(bidsfolder: str, outputfolder: str, include: str, **_):

    # Defaults
    inputdir  = Path(bidsfolder).resolve()
    outputdir = Path(outputfolder).resolve()
    outputdir.mkdir(parents=True, exist_ok=True)

    # Create placeholder output files for selected input files
    print(f"Creating BIDS stub data in: {outputdir}")
    for inputfile in inputdir.rglob('*'):
        if not re.match(include, str(inputfile.relative_to(inputdir))):
            continue
        elif inputfile.is_dir():
            (outputdir/inputfile.relative_to(inputdir)).mkdir(parents=True, exist_ok=True)
        else:
            (outputdir/inputfile.relative_to(inputdir)).parent.mkdir(parents=True, exist_ok=True)
            (outputdir/inputfile.relative_to(inputdir)).touch()

    # Create a dataset description file
    dataset_file = inputdir/'dataset_description.json'
    description  = {}
    if dataset_file.is_file():
        with dataset_file.open('r') as fid:
            description = json.load(fid)
    description['GeneratedBy'] = [{'Name':'BIDScramble', 'Version':__version__, 'Description:':__description__, 'CodeURL':__url__}]
    description['DatasetType'] = 'derivative'
    with (outputdir/dataset_file.name).open('w') as fid:
        json.dump(description, fid, indent=4)

    # Copy the modality agnostic root files if they exist
    for fname in [name for name in ('README','README.txt','README.md','README.rst','CHANGES','LICENSE','CITATION.cff') if (inputdir/name).is_file()]:
        shutil.copyfile(inputdir/fname, outputdir/fname)

    # Download the LICENSE file if it's not there
    license = description.get('License')
    if not (inputdir/'LICENSE').is_file() and license:
        response = urlopen('https://spdx.org/licenses/licenses.json')
        licenses = json.loads(response.read())['licenses']
        for item in licenses:
            if license in (item['name'], item['licenseId']):
                print(f"Adding a '{item['licenseId']}' SPDX license file")
                response = urlopen(item['detailsUrl'])
                license  = json.loads(response.read())['licenseText']
                (outputdir/'LICENSE').write_text(license)
                break
