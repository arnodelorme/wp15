#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""

"""

import argparse
import textwrap
import pandas as pd
import shutil
import numpy as np
import json
from urllib.request import urlopen
from pathlib import Path
from . import __version__, __description__, __url__


def bidscramble(inputdir: str, outputdir: str, covariance: list[str], include: list[str]):

    # Defaults
    inputdir  = Path(inputdir).resolve()
    outputdir = Path(outputdir).resolve()
    outputdir.mkdir(parents=True, exist_ok=True)

    # Create a dataset description file
    dataset_file = inputdir/'dataset_description.json'
    if not dataset_file.is_file():
        dataset_description = {}
    else:
        with dataset_file.open('r') as fid:
            dataset_description = json.load(fid)
    dataset_description['GeneratedBy'] = [{'Name':__package__, 'Version':__version__, 'Description:':__description__, 'CodeURL':__url__}]
    dataset_description['DatasetType'] = 'derivative'
    with (outputdir/dataset_file.name).open('w') as fid:
        json.dump(dataset_description, fid, indent=4)

    # Copy the README file if it exists
    readme_file = inputdir/'README'
    if readme_file.is_file():
        shutil.copyfile(readme_file, outputdir/readme_file.name)

    # Copy or add the LICENSE file
    license_file = inputdir/'LICENSE'
    if license_file.is_file():
        shutil.copyfile(license_file, outputdir/license_file.name)
    else:
        license = dataset_description.get('License')
        if license:
            # Read the SPDX licenses
            response = urlopen('https://spdx.org/licenses/licenses.json')
            licenses = json.loads(response.read())['licenses']
            for item in licenses:
                if license in (item['name'], item['licenseId']):
                    print(f"Downloading SPDX license: {item['licenseId']}")
                    response = urlopen(item['detailsUrl'])
                    license  = json.loads(response.read())['licenseText']
                    break
            license_file.write_text(license)

    # Create pseudo-random out data for all files of each included data type
    for pattern in include:

        inputfiles = inputdir.rglob(pattern)

        for inputfile in inputfiles:

            # Define the output target
            outputfile = outputdir/inputfile.relative_to(inputdir)

            # Load or copy the data
            inputdata = pd.DataFrame()
            if inputfile.suffix == '.tsv':
                print(f"Reading: {inputfile}")
                inputdata = pd.read_csv(inputfile, sep='\t')
            elif inputfile.suffix == '.json':
                print(f"Saving: {outputfile}")
                shutil.copyfile(inputfile, outputfile)  # WIP
                continue
            else:
                print(f"Saving: {outputfile}")
                shutil.copyfile(inputfile, outputfile)
                continue

            # Permute columns that are not of interest
            for column in inputdata.columns:
                if column not in covariance:
                    inputdata[column] = np.random.permutation(inputdata[column])

            # Save the output data
            print(f"Saving: {outputfile}")
            inputdata.to_csv(outputfile, sep='\t', index=False, encoding='utf-8', na_rep='n/a')


def main():
    """Console script entry point"""

    # Parse the input arguments and run main(args)
    class CustomFormatter(argparse.ArgumentDefaultsHelpFormatter, argparse.RawDescriptionHelpFormatter):
        pass

    parser = argparse.ArgumentParser(formatter_class=CustomFormatter, description=textwrap.dedent(__doc__),
                                     epilog='examples:\n'
                                            '  bidscramble bids pseudobids -c age sex height -i *.tsv *.json CHANGES README\n\n'
                                            'author:\n'
                                            '  Marcel Zwiers\n ')
    parser.add_argument('inputdir',           help='The BIDS input-directory with the real data')
    parser.add_argument('outputdir',          help='The BIDS output-directory with generated pseudo data')
    parser.add_argument('-c', '--covariance', help='A list of variable names between which the covariance structure is preserved when generating the pseudo data', nargs='+')
    parser.add_argument('-i', '--include',    help='A list of include pattern(s) that select the files in the BIDS input-directory that are produced in the output directory', nargs='+', default=['*'])
    args = parser.parse_args()

    bidscramble(inputdir=args.inputdir, outputdir=args.outputdir, covariance=args.covariance, include=args.include)


if __name__ == "__main__":
    main()
