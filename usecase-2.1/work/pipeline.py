#!/usr/bin/env python3

"""This pipeline computes averages from the participants.tsv file

Use as 
   ./pipeline.py [options] <inputdir> <outputdir> <level>
where the input and output directory must be specified, and the 
level is either "group" or "participant".

Optional arguments:
  -h,--help           Show this help and exit.
  --verbose           Enable verbose output.
  --start-idx <num>   Start index for participant selection.
  --stop-idx <num>    Stop index for participant selection.

This code is shared under the CC0 license

Copyright (C) 2024, SIESTA workpackage 15 team
"""

import pandas as pd
import argparse
from pathlib import Path


##########################################################################
# Compute the averages of the age, height, and weight of the participants
##########################################################################

def main(options: dict):

    if options.get('verbose'):
        print('options =')
        print(options)

    if options.get('level') == 'participant':
        print("nothing to do at the participant level")
        return

    # Create the output directory and its parents if they don't exist
    Path(options['outputdir']).mkdir(parents=True, exist_ok=True)

    # Read the participants.tsv input file into a DataFrame
    inputfile  = Path(options['inputdir'])/'participants.tsv'
    outputfile = Path(options['outputdir'])/'results.tsv'
    if not inputfile.is_file():
        print(f"WARNING: input file does not exist: {inputfile}")
        return
    participants = pd.read_csv(inputfile, sep='\t')
    if options.get('verbose'):
        print(f"data contains {len(participants)} participants")

    # Select participants based on start_idx and stop_idx
    if options.get('stop_idx') is not None:
        participants = participants.iloc[:options['stop_idx']]
    if options.get('start_idx') is not None:
        participants = participants.iloc[options['start_idx']:]
    if options.get('verbose'):
        print(f"selected {len(participants)} participants")

    # Compute averages
    averaged_age    = participants['age'].mean(skipna=True)
    averaged_height = participants['Height'].mean(skipna=True)
    averaged_weight = participants['Weight'].mean(skipna=True)

    # Put the results in a DataFrame
    result = pd.DataFrame({
        'averagedAge': [averaged_age],
        'averagedHeight': [averaged_height],
        'averagedWeight': [averaged_weight]
    })
    if options.get('verbose'):
        print(result)

    # Write the results to a TSV file
    result.to_csv(outputfile, sep='\t', index=False, header=False)


##########################################################################
# execute the code if it is run as a script
##########################################################################

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('inputdir', type=str, help='Directory containing participants.tsv')
    parser.add_argument('outputdir', type=str, help='Directory to save results.tsv')
    parser.add_argument('level', type=str, help='The analysis level', choices=['participant', 'group'])
    parser.add_argument('-v', '--verbose', action='store_true', help='Enable verbose output')
    parser.add_argument('--start-idx', type=int, default=None, help='Start index for participant selection')
    parser.add_argument('--stop-idx', type=int, default=None, help='Stop index for participant selection')

    main(vars(parser.parse_args()))
