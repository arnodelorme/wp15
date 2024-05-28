#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Creates a copy of the BIDS input directory in which all files are empty. Exceptions to this are the
'dataset_description.json', the 'README', 'CHANGES' and the 'LICENSE' files, which are copied over and
updated if they exist.
"""

import argparse
import textwrap
import shutil
import json
from urllib.request import urlopen
from pathlib import Path
from . import __version__, __description__, __url__


def bidscramble(inputdir: str, outputdir: str):

    # Defaults
    inputdir  = Path(inputdir).resolve()
    outputdir = Path(outputdir).resolve()
    outputdir.mkdir(parents=True, exist_ok=True)

    # Create placeholder output files for all input files
    for inputfile in inputdir.rglob('*'):
        if inputfile.is_dir():
            (outputdir/inputfile.relative_to(inputdir)).mkdir(parents=True, exist_ok=True)
        else:
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

    # Copy the README, CHANGES and LICENSE files if they exist
    for inputfile in (inputdir/'README', inputdir/'CHANGES', inputdir/'LICENSE'):
        if inputfile.is_file():
            shutil.copyfile(inputfile, outputdir/inputfile.name)

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


def main():
    """Console script entry point"""

    # Parse the input arguments and run main(args)
    class CustomFormatter(argparse.ArgumentDefaultsHelpFormatter, argparse.RawDescriptionHelpFormatter):
        pass

    parser = argparse.ArgumentParser(formatter_class=CustomFormatter, description=textwrap.dedent(__doc__),
                                     epilog='examples:\n'
                                            '  bidscramble bids pseudobids\n\n'
                                            'author:\n'
                                            '  Marcel Zwiers\n ')
    parser.add_argument('inputdir',  help='The BIDS input-directory with the real data')
    parser.add_argument('outputdir', help='The BIDS output-directory with empty pseudo data')
    args = parser.parse_args()

    bidscramble(inputdir=args.inputdir, outputdir=args.outputdir)


if __name__ == "__main__":
    main()
