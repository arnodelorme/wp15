#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""

"""

import argparse
import textwrap
import pandas as pd
import shutil
from pathlib import Path

def main(inputdir: str, outputdir: str, properties: dict, include: list[str]):

    # Defaults
    inputdir  = Path(inputdir).resolve()
    outputdir = Path(outputdir).resolve()

    for pattern in include:

        inputfiles = inputdir.rglob(pattern)

        for inputfile in inputfiles:

            inputdata  = pd.DataFrame()
            outputfile = outputdir/inputfile.relative_to(inputdir)

            # Load the data, pseudo-randomise it and save it
            if inputfile.suffix == '.tsv':
                inputdata = pd.read_csv(inputfile, sep='\t', index_col='filename')
            elif inputfile.suffix == '.json':
                shutil.copyfile(inputfile, outputfile)  # WIP
            else:
                shutil.copyfile(inputfile, outputfile)

            # Permute the participant label
            inputdata.sample(frac=1)

            # Permute columns that are not of interest
            for column in inputdata.columns:
                if column not in properties:
                    pass    # WIP

            # Save the output data
            if inputdata:
                inputdata.to_csv(outputfile, sep='\t', encoding='utf-8', na_rep='n/a')


# Shell usage
if __name__ == "__main__":

    # Parse the input arguments and run main(args)
    class CustomFormatter(argparse.ArgumentDefaultsHelpFormatter, argparse.RawDescriptionHelpFormatter):
        pass

    parser = argparse.ArgumentParser(formatter_class=CustomFormatter, description=textwrap.dedent(__doc__),
                                     epilog='examples:\n'
                                            '  genbids.py bids pseudobids properties.json *.tsv *.json CHANGES README\n'
                                            'author:\n'
                                            '  Marcel Zwiers\n ')
    parser.add_argument('inputdir',   help='The BIDS input-directory with the real data')
    parser.add_argument('outputdir',  help='The BIDS output-directory with generated pseudo data')
    parser.add_argument('properties', help='The json file with the properties that need to be preserved in the generated pseudo data')
    parser.add_argument('include',    help='The include pattern(s) that select the files in the BIDS input-directory that need to be generated in the output directory', nargs='+', default='*')
    args = parser.parse_args()

    main(inputdir=args.inputdir, outputdir=args.outputdir, properties=args.properties, include=args.include)
