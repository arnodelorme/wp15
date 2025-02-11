#!/usr/bin/env python3

# BIDS pipeline for computing averages from participants.tsv file
#
# Example 
#    ./pipeline.py --inputdir /path/to/input --outputdir /path/to/output
#
# Optional arguments:
#   --verbose: Enable verbose output.
#   --start_idx: Start index for participant selection.
#   --stop_idx: Stop index for participant selection.
#   --version: Print version and exit.

# This code is shared under the CC0 license
#
# Copyright (C) 2024, SIESTA workpackage 15 team

import pandas as pd
import os
import argparse

############################################################
# Parse the command line arguments
############################################################

def parse_args():
    parser = argparse.ArgumentParser(description="Compute averages from BIDS participants.tsv file.")
    parser.add_argument('inputdir', type=str, help="Directory containing participants.tsv")
    parser.add_argument('outputdir', type=str, help="Directory to save results.tsv")
    parser.add_argument('level', type=str, help="Participant or group level")
    parser.add_argument('--verbose', action='store_true', help="Enable verbose output")
    parser.add_argument('--start_idx', type=int, default=None, help="Start index for participant selection")
    parser.add_argument('--stop_idx', type=int, default=None, help="Stop index for participant selection")
    parser.add_argument('--version', action='store_true', help="Print version and exit")

    # Parse arguments
    args = parser.parse_args()

    # Create options dictionary
    options = {
        'inputdir': args.inputdir,
        'outputdir': args.outputdir,
        'verbose': args.verbose,
        'start_idx': args.start_idx,
        'stop_idx': args.stop_idx,
        'version': args.version
    }

    return options


##########################################################################
# Compute the averages of the age, height, and weight of the participants
##########################################################################

def main(options):

    if 'version' in options and options['version']:
        print("version = unknown")
        return

    if 'verbose' in options and options['verbose']:
        print("options =")
        print(options)

    if 'level' in options and options['level'] == "participant":
        # there is nothing to do at the participant level
        return

    inputfile  = os.path.join(options['inputdir'], "participants.tsv")
    outputfile = os.path.join(options['outputdir'], "results.tsv")

    # Read the participants.tsv file into a DataFrame
    participants = pd.read_csv(inputfile, sep='\t')

    if 'verbose' in options and options['verbose']:
        print(f"data contains {len(participants)} participants")

    # Select participants based on start_idx and stop_idx
    if 'stop_idx' in options and options['stop_idx'] is not None:
        participants = participants.iloc[:options['stop_idx']]
    if 'start_idx' in options and options['start_idx'] is not None:
        participants = participants.iloc[options['start_idx']:]

    if 'verbose' in options and options['verbose']:
        print(f"selected {len(participants)} participants")

    # Compute averages
    averagedAge    = participants['age'].mean(skipna=True)
    averagedHeight = participants['Height'].mean(skipna=True)
    averagedWeight = participants['Weight'].mean(skipna=True)

    # Put the results in a DataFrame
    result = pd.DataFrame({
        'averagedAge': [averagedAge],
        'averagedHeight': [averagedHeight],
        'averagedWeight': [averagedWeight]
    })

    if 'verbose' in options and options['verbose']:
        print(result)

    # Write the results to a TSV file
    result.to_csv(outputfile, sep='\t', index=False, header=False)


##########################################################################
# execute the code if it is run as a script
##########################################################################

if __name__ == "__main__":
    options = parse_args()
    main(options)
