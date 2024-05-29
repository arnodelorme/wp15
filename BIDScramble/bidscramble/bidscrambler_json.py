#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Adds empty-value versions of the json files in the BIDS input directory to the BIDS output directory.
"""

import argparse
import json
import re
import textwrap
from pathlib import Path


def clearvalues(data: dict, preserve: str):

    for key, value in data.items():
        if re.match(preserve, str(key)):
            data[key] = value
        elif isinstance(value, dict):
            clearvalues(value, preserve)
        else:
            data[key] = None


def bidscrambler_json(inputdir: str, outputdir: str, include: str, preserve: str):

    # Defaults
    inputdir  = Path(inputdir).resolve()
    outputdir = Path(outputdir).resolve()
    outputdir.mkdir(parents=True, exist_ok=True)

    # Create pseudo-random out data for all files of each included data type
    for inputfile in inputdir.rglob(include):

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
        with outputfile.open('w') as fid:
            json.dump(jsondata, fid, indent=4)


def main():
    """Console script entry point"""

    # Parse the input arguments and run main(args)
    class CustomFormatter(argparse.ArgumentDefaultsHelpFormatter, argparse.RawDescriptionHelpFormatter):
        pass

    parser = argparse.ArgumentParser(formatter_class=CustomFormatter, description=textwrap.dedent(__doc__),
                                     epilog='examples:\n'
                                            "  bidscrambler_json bids pseudobids '*.json'\n"
                                            "  bidscrambler_json bids pseudobids participants.json -p '.*'\n"
                                            "  bidscrambler_json bids pseudobids '*.json' -p (?!(AcquisitionTime|.*Date))\n ")
    parser.add_argument('inputdir',         help='The input directory with the real data')
    parser.add_argument('outputdir',        help='The output directory with generated pseudo data')
    parser.add_argument('include',          help='A wildcard pattern for selecting input files to be included in the output directory')
    parser.add_argument('-p', '--preserve', help='A regular expression pattern that is matched against all keys in the json input files. Associated values are copied over to the output files when a key matches positively, else the normal empty value is used')
    args = parser.parse_args()

    bidscrambler_json(inputdir=args.inputdir, outputdir=args.outputdir, include=args.include, preserve=args.preserve)


if __name__ == "__main__":
    main()
