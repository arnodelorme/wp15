import pathlib
import re
import pandas as pd
from importlib import metadata
from typing import List
from bids_validator import BIDSValidator

__version__     = metadata.version('bidscramble')
__description__ = metadata.metadata('bidscramble')['Summary']
__url__         = metadata.metadata('bidscramble')['Project-URL']


def get_inputfiles(inputdir: pathlib.Path, select: str, pattern: str='*', bidsvalidate: bool=False) -> List[pathlib.Path]:
    """
    :param inputdir:     The input directory from which files are retrieved using rglob
    :param select:       The regular expression pattern to select the files of interest
    :param pattern:      The rglob search pattern (e.g. useful for additional filtering on file extension)
    :param bidsvalidate: Filters out BIDS files if True
    :return:             The input files of interest
    """

    inputfiles = [fpath for fpath in inputdir.rglob(pattern) if re.fullmatch(select, str(fpath.relative_to(inputdir))) and fpath.is_file()]
    if bidsvalidate:
        inputfiles = [fpath for fpath in inputfiles if not BIDSValidator().is_bids(fpath.as_posix())]

    if not inputfiles:
        print(f"WARNING: No files found in {inputdir} using '{select}'")
    else:
        print(f"Found {len(inputfiles)} input files using '{select}'")

    return sorted(inputfiles)       # TODO: create a class and return input objects?


def prune_participants_tsv(inputdir: pathlib.Path):
    """
    Removes rows from the participants tsv file if their subject directories do not exist

    :param inputdir: The BIDS (or BIDS-like) input directory with the participants.tsv file
    :return:
    """

    participants_tsv = inputdir/'participants.tsv'
    if participants_tsv.is_file():

        table = pd.read_csv(participants_tsv, sep='\t', dtype=str, index_col='participant_id')
        for subid in table.index:
            if not isinstance(subid, str):  # Can happen with anonymized data
                return
            if not (inputdir/subid).is_dir():
                print(f"Pruning {subid} record from {participants_tsv}")
                table.drop(subid, inplace=True)

        table.to_csv(participants_tsv, sep='\t', encoding='utf-8', na_rep='n/a')
