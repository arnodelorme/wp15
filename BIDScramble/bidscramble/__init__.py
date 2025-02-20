import sys
import pathlib
import re
import pandas as pd
from importlib import metadata
from typing import List, Tuple
from bids_validator import BIDSValidator

__version__     = metadata.version('bidscramble')
__description__ = metadata.metadata('bidscramble')['Summary']
__url__         = metadata.metadata('bidscramble')['Project-URL']


def get_inputfiles(inputdir: pathlib.Path, select: str, pattern: str='*', bidsvalidate: bool=False) -> Tuple[List[pathlib.Path], List[pathlib.Path]]:
    """
    :param inputdir:     The input directory from which files are retrieved using rglob
    :param select:       The fullmatch regular expression pattern to select the files of interest
    :param pattern:      The rglob search pattern (e.g. useful for additional filtering on file extension)
    :param bidsvalidate: Filters out BIDS files if True
    :return:             The input files and directories of interest
    """

    inputitems = [item for item in inputdir.rglob(pattern) if re.fullmatch(select, str(item.relative_to(inputdir)))]
    inputfiles = [fpath  for fpath  in inputitems if fpath.is_file()]
    inputdirs  = [folder for folder in inputitems if folder.is_dir() and folder.name not in ('.','..')]

    if bidsvalidate:
        inputfiles = [fpath for fpath in inputfiles if not BIDSValidator().is_bids(fpath.as_posix())]

    if not inputfiles:
        print(f"WARNING: No files found in {inputdir} using '{select}'")
    else:
        print(f"Found {len(inputfiles)} input files and {len(inputdirs)} directories using '{select}'")

    return sorted(inputfiles), sorted(inputdirs)       # TODO: create a class and return input objects?


def prune_participants_tsv(rootdir: pathlib.Path):
    """
    Removes rows from the participants tsv file if their subject directories do not exist

    :param rootdir: The BIDS (or BIDS-like) input directory with the participants.tsv file
    :return:
    """

    participants_tsv = rootdir/'participants.tsv'
    if participants_tsv.is_file():

        print(f"--> {participants_tsv}")
        table = pd.read_csv(participants_tsv, sep='\t', dtype=str, index_col='participant_id')
        for subid in table.index:
            if not isinstance(subid, str):  # Can happen with anonymized data
                return
            if not (rootdir/subid).is_dir():
                print(f"Pruning {subid} record from {participants_tsv}")
                table.drop(subid, inplace=True)

        table.to_csv(participants_tsv, sep='\t', encoding='utf-8', na_rep='n/a')


def console_scripts(show: bool=False) -> list:
    """
    :param show:    Print the installed console scripts if True
    :return:        List of BIDScramble console scripts
    """

    if show: print('Executable tools:')

    scripts = []
    if sys.version_info.major == 3 and sys.version_info.minor < 10:
        console_scripts = metadata.entry_points()['console_scripts']                 # Raises DeprecationWarning for python >= 3.10: SelectableGroups dict interface is deprecated
    else:
        console_scripts = metadata.entry_points().select(group='console_scripts')    # The select method was introduced in python = 3.10
    for script in console_scripts:
        if script.value.startswith('bidscramble'):
            scripts.append(script.name)
            if show: print(f"- {script.name}")

    return scripts
