import pathlib
import re
from importlib import metadata
from bids_validator import BIDSValidator

__version__     = metadata.version('bidscramble')
__description__ = metadata.metadata('bidscramble')['Summary']
__url__         = metadata.metadata('bidscramble')['Project-URL']


def get_inputfiles(inputdir: pathlib.Path, select: str, pattern: str='*', bidsvalidate: bool=False):

    inputfiles = [fpath for fpath in inputdir.rglob(pattern) if re.fullmatch(select, str(fpath.relative_to(inputdir))) and fpath.is_file()]
    if bidsvalidate:
        inputfiles = [fpath for fpath in inputfiles if not BIDSValidator().is_bids(fpath.as_posix())]

    if not inputfiles:
        print(f"No files found in {inputdir} using '{select}'")
    else:
        print(f"Found {len(inputfiles)} input files using '{select}'")

    return sorted(inputfiles)       # TODO: create a class and return input objects?
