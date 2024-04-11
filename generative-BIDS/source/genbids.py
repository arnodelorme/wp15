#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""

"""

import argparse
import textwrap
from pathlib import Path

def main(inputdir: str, outputdir: str, include: list[str], properties: dict):

    # Defaults
    inputdir  = Path(inputdir).resolve()
    outputdir = Path(outputdir).resolve()


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

    main(inputdir=args.inputdir, outputdir=args.outputdir, include=args.include, properties=args.properties)
