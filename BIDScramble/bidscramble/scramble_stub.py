import shutil
import json
import re
from tqdm import tqdm
from urllib.request import urlopen
from pathlib import Path
from . import get_inputfiles, __version__, __description__, __url__


def scramble_stub(inputdir: str, outputdir: str, select: str, bidsvalidate: bool, dryrun: bool=False, **_):

    # Defaults
    inputdir  = Path(inputdir).resolve()
    outputdir = Path(outputdir).resolve()

    # Ensure that the output directory exists
    if not outputdir.is_dir():
      outputdir.mkdir(parents=True, exist_ok=True)

    # Create placeholder output files for selected input files
    print(f"Creating BIDS stub data in: {outputdir}")
    inputfiles = get_inputfiles(inputdir, select, '*', bidsvalidate)        # NB: this skips empty directories
    inputdirs  = [folder for folder in inputdir.rglob('*') if re.fullmatch(select, str(folder.relative_to(inputdir))) and folder.is_dir()]
    for inputitem in tqdm(inputdirs + inputfiles, unit='file', colour='green', leave=False):
        outputitem = outputdir/inputitem.relative_to(inputdir)
        tqdm.write(f"--> {outputitem}")
        if inputitem.is_dir() and not dryrun:
            outputitem.mkdir(parents=True, exist_ok=True)
        elif not dryrun:
            outputitem.touch()

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
