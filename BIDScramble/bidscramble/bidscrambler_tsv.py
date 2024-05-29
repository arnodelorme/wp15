#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Adds randomly permuted versions of the tsv files in the BIDS input directory to the BIDS output directory.
"""

import argparse
import textwrap
import pandas as pd
import numpy as np
from fnmatch import fnmatch
from pathlib import Path


def bidscrambler_tsv(inputdir: str, outputdir: str, include: str, preserve: list[str]):

    # Defaults
    inputdir  = Path(inputdir).resolve()
    outputdir = Path(outputdir).resolve()
    outputdir.mkdir(parents=True, exist_ok=True)

    # Create pseudo-random out data for all files of each included data type
    for inputfile in inputdir.rglob(include):

        # Define the output target
        outputfile = outputdir/inputfile.relative_to(inputdir)

        # Load the (zipped) tsv data
        if '.tsv' in inputfile.suffixes:
            tsvdata = pd.read_csv(inputfile, sep='\t')
        else:
            print(f"Skipping non-tsv file: {outputfile}")
            continue

        # Permute columns that are not of interest (i.e. preserve the relation between columns of interest)
        for column in tsvdata.columns:
            if not any([fnmatch(column, keep) for keep in preserve]):
                tsvdata[column] = np.random.permutation(tsvdata[column])

        # Permute the rows
        tsvdata = tsvdata.sample(frac=1).reset_index(drop=True)

        # Save the output data
        print(f"Saving: {outputfile}\n ")
        tsvdata.to_csv(outputfile, sep='\t', index=False, encoding='utf-8', na_rep='n/a')


def main():
    """Console script entry point"""

    # Parse the input arguments and run main(args)
    class CustomFormatter(argparse.ArgumentDefaultsHelpFormatter, argparse.RawDescriptionHelpFormatter):
        pass

    parser = argparse.ArgumentParser(formatter_class=CustomFormatter, description=textwrap.dedent(__doc__),
                                     epilog='examples:\n'
                                            "  bidscrambler_tsv bids pseudobids '*.tsv'\n"
                                            "  bidscrambler_tsv bids pseudobids participants.tsv -p participant_id 'SAS*'\n"
                                            "  bidscrambler_tsv bids pseudobids 'partici*.tsv' -p '*'\n ")
    parser.add_argument('inputdir',         help='The input directory with the real data')
    parser.add_argument('outputdir',        help='The output directory with generated pseudo data')
    parser.add_argument('include',          help='A wildcard pattern for selecting input files to be included in the output directory')
    parser.add_argument('-p', '--preserve', help='A list of tsv column names between which the relationship is preserved when generating the pseudo data. Supports wildcard patterns', nargs='+')
    args = parser.parse_args()

    bidscrambler_tsv(inputdir=args.inputdir, outputdir=args.outputdir, include=args.include, preserve=args.preserve)


if __name__ == "__main__":
    main()
