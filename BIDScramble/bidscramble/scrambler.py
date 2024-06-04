#!/usr/bin/env python3

import argparse
import textwrap
from .scrambler_stub import scrambler_stub
from .scrambler_tsv import scrambler_tsv
from .scrambler_nii import scrambler_nii
from .scrambler_json import scrambler_json

# Use a parent parser to inherit optional arguments (https://macgregor.gitbooks.io/developer-notes/content/python/argparse-basics.html#inheriting-arguments)
parent = argparse.ArgumentParser(add_help=False)
parent.add_argument('-s','--select', help='A fullmatch regular expression pattern that is matched against the relative path of the input data. Files that match are scrambled and saved in outputfolder', default='.*')
parent.add_argument('-d','--dryrun', help='Do not save anything, only print the output filenames in the terminal', action='store_true')


class DefaultsFormatter(argparse.ArgumentDefaultsHelpFormatter, argparse.RawDescriptionHelpFormatter): pass


def addparser_stub(parsers, help: str):

    description = textwrap.dedent("""
    Creates a copy of the BIDS input directory in which all files are empty stubs. Exceptions to this are the
    'dataset_description.json', 'README', 'CHANGES', 'LICENSE' and 'CITATION.cff' files, which are copied over
    and updated if possible.
    """)

    epilog = ('examples:\n'
              '  scrambler data/bids data/pseudobids stub\n'
              "  scrambler data/bids data/pseudobids stub -s '.*\.(nii|json|tsv)'\n"
              "  scrambler data/bids data/pseudobids stub -s '.*(?<!derivatives)'\n"
              "  scrambler data/bids data/pseudobids stub -s '(?!sub.*scans.tsv|/func/).*'\n ")

    parser = parsers.add_parser('stub', parents=[parent], formatter_class=DefaultsFormatter, description=description, epilog=epilog, help=help)
    parser.set_defaults(func=scrambler_stub)


def addparser_tsv(parsers, help: str):

    description = textwrap.dedent("""
    Adds scrambled versions of the tsv files in the BIDS input directory to the BIDS output directory. If no scrambling
    method is specified, the default behavior is to null all values.
    """)

    epilog = ('examples:\n'
              '  scrambler data/bids data/pseudobids tsv\n'
              '  scrambler data/bids data/pseudobids tsv permute\n'
              "  scrambler data/bids data/pseudobids tsv permute -s '.*_events.tsv' -p '.*'\n"
              '  scrambler data/bids data/pseudobids tsv permute -s participants.tsv -p (participant_id|SAS.*)\n ')

    parser = parsers.add_parser('tsv', parents=[parent], formatter_class=DefaultsFormatter, description=description, epilog=epilog, help=help)
    parser.set_defaults(func=scrambler_tsv)

    subparsers = parser.add_subparsers(dest='method', help='Scrambling method (by default the values are nulled). Add -h, --help for more information')
    subparser = subparsers.add_parser('permute', parents=[parent], description=description, help='Randomly permute the column values of the tsv files')
    subparser.add_argument('-p', '--preserve', help='A regular expression pattern that is matched against tsv column names. The exact relationship between the matching columns is then preserved, i.e. they are permuted in conjunction instead of independently')


def addparser_nii(parsers, help: str):

    description = textwrap.dedent("""
    Adds scrambled versions of the NIfTI files in the BIDS input directory to the BIDS output directory. If no scrambling
    method is specified, the default behavior is to null all image values.
    """)

    epilog = ('examples:\n'
              '  scrambler data/bids data/pseudobids nii\n'
              '  scrambler data/bids data/pseudobids nii blur -h\n'
              "  scrambler data/bids data/pseudobids nii blur 20 -s 'sub-.*_T1w.nii.gz'\n"
              "  scrambler data/bids data/pseudobids nii permute x z -i -s 'sub-.*_bold.nii'\n ")

    parser = parsers.add_parser('nii', parents=[parent], formatter_class=DefaultsFormatter, description=description, epilog=epilog, help=help)
    parser.set_defaults(func=scrambler_nii)

    subparsers = parser.add_subparsers(dest='method', help='Scrambling method (by default the images are nulled). Add -h, --help for more information')
    subparser = subparsers.add_parser('blur', parents=[parent], description=description, help='Apply a 3D Gaussian smoothing filter')
    subparser.add_argument('fwhm', help='The FWHM (in mm) of the isotropic 3D Gaussian smoothing kernel', type=float)
    subparser = subparsers.add_parser('permute', parents=[parent], description=description, help='Perform random permutations along one or more image dimensions')
    subparser.add_argument('dims', help='The dimensions along which the image will be permuted', nargs='*', choices=['x', 'y', 'z', 't'], default=['x', 'y'])
    subparser.add_argument('-i','--independent', help='Make all permutations along a dimension independent (instead of permuting slices as a whole)', action='store_true')


def addparser_json(parsers, help: str):

    description = textwrap.dedent("""
    Adds scrambled key-value versions of the json files in the BIDS input directory to the BIDS output directory. If no preserve
    expression is specified, the default behavior is to null all values.
    """)

    epilog = ('examples:\n'
              '  scrambler data/bids data/pseudobids json\n'
              "  scrambler data/bids data/pseudobids json participants.json -p '.*'\n"
              "  scrambler data/bids data/pseudobids json 'sub-.*.json' -p '(?!AcquisitionTime|Date).*'\n ")

    parser = parsers.add_parser('json', parents=[parent], formatter_class=DefaultsFormatter, description=description, epilog=epilog, help=help)
    parser.add_argument('-p', '--preserve', help='A fullmatch regular expression pattern that is matched against all keys in the json files. The json values are copied over when a key matches positively')
    parser.set_defaults(func=scrambler_json)


def main():
    """Console script entry point"""

    description = textwrap.dedent("""
    The general workflow to build up a scrambled BIDS dataset is by consecutively running `scrambler` for the datatype(s)
    of your choice. For instance, you could first run `scrambler` to create a dummy dataset with only the file structure
    and some basic files, and then run `scrambler` again to specifically add scrambled NIfTI data (see examples below).
    """)

    # Add the baseparser
    parser = argparse.ArgumentParser(formatter_class=DefaultsFormatter, description=description,
                                     epilog='examples:\n'
                                            '  scrambler data/bids data/pseudobids stub -h\n'
                                            "  scrambler data/bids data/pseudobids nii -h\n ")
    parser.add_argument('bidsfolder',   help='The BIDS (or BIDS-like) input directory with the original data')
    parser.add_argument('outputfolder', help='The output directory with the scrambled pseudo data')

    # Add the subparsers
    subparsers = parser.add_subparsers(dest='method', title='Data type', help='Add -h, --help for more information', required=True)
    addparser_stub(subparsers, help='Short help for scrambler_stub')
    addparser_tsv(subparsers,  help='Short help for scrambler_tsv')
    addparser_nii(subparsers,  help='Short help for scrambler_nii')
    addparser_json(subparsers, help='Short help for scrambler')

    # Execute the scrambler function
    args = parser.parse_args()
    args.func(**vars(args))


if __name__ == "__main__":
    main()
