#!/usr/bin/env python3

import argparse
import textwrap
from .scrambler_stub import scrambler_stub
from .scrambler_tsv import scrambler_tsv
from .scrambler_nii import scrambler_nii
from .scrambler_json import scrambler_json

class DefaultsFormatter(argparse.ArgumentDefaultsHelpFormatter, argparse.RawDescriptionHelpFormatter): pass


# Use a parent parser to inherit optional arguments (https://macgregor.gitbooks.io/developer-notes/content/python/argparse-basics.html#inheriting-arguments)
parent = argparse.ArgumentParser(add_help=False)
parent.add_argument('-s','--select', help='A regular expression pattern that is matched against the relative path of the input data. Files that match are scrambled and saved in outputfolder', default='.*')


def addparser_stub(parsers, help: str):

    description = textwrap.dedent("""
    Creates a copy of the BIDS input directory in which all files are empty stubs. Exceptions to this are the
    'dataset_description.json', 'README', 'CHANGES', 'LICENSE' and 'CITATION.cff' files, which are copied over
    and updated if they exist.
    """)

    epilog = ('examples:\n'
              '  scrambler data/bids data/pseudobids stub\n'
              "  scrambler data/bids data/pseudobids stub -s '.*\.(nii|json|tsv)'\n"
              '  scrambler data/bids data/pseudobids stub -s (?!derivatives)\n'
              "  scrambler data/bids data/pseudobids stub -s '.*(?!/(func|sub.*scans.tsv))\n ")

    parser = parsers.add_parser('stub', parents=[parent], formatter_class=DefaultsFormatter, description=description, epilog=epilog, help=help)
    parser.set_defaults(func=scrambler_stub)


def addparser_tsv(parsers, help: str):

    description = textwrap.dedent("""
    Adds randomly permuted versions of the tsv files in the BIDS input directory to the BIDS output directory.
    """)

    epilog = ('examples:\n'
              '  scrambler data/bids data/pseudobids tsv\n'
              "  scrambler data/bids data/pseudobids tsv -s '.*_events.tsv' -p '.*'\n"
              '  scrambler data/bids data/pseudobids tsv -s participants.tsv -p (participant_id|SAS.*)\n ')

    parser = parsers.add_parser('tsv', parents=[parent], formatter_class=DefaultsFormatter, description=description, epilog=epilog, help=help)
    parser.add_argument('-p', '--preserve', help='A regular expression pattern that is matched against tsv column names of the input files. The exact relationship between the matching columns is preserved when generating the pseudo data')
    parser.set_defaults(func=scrambler_tsv)


def addparser_nii(parsers, help: str):

    description = textwrap.dedent("""
    Adds scrambled versions of the NIfTI files in the BIDS input directory to the BIDS output directory. If no scrambling
    method is specified, the default behavior is to null all image values.
    """)

    epilog = ('examples:\n'
              '  scrambler data/bids data/pseudobids nii\n'
              '  scrambler data/bids data/pseudobids nii blur -h\n'
              "  scrambler data/bids data/pseudobids nii -s 'sub-.*_T1w.nii.gz' blur 20\n"
              "  scrambler data/bids data/pseudobids nii -s 'sub-.*_bold.nii' permute x z -i'\n ")

    parser = parsers.add_parser('nii', parents=[parent], formatter_class=DefaultsFormatter, description=description, epilog=epilog, help=help)
    parser.set_defaults(func=scrambler_nii)

    subparsers = parser.add_subparsers(dest='method', help='Scrambling method (by default the images are nulled). Add -h, --help for more information')
    subparser = subparsers.add_parser('blur', parents=[parent], description=description, help='Apply a 3D Gaussian smoothing filter')
    subparser.add_argument('fwhm', help='The FWHM (in mm) of the isotropic 3D Gaussian smoothing kernel', type=float)
    subparser = subparsers.add_parser('permute', parents=[parent], description=description, help='Perfom random permutations along one or more image dimensions')
    subparser.add_argument('dims', help='The dimensions along which the image will be permuted', nargs='*', choices=['x', 'y', 'z', 't'], default=['x', 'y'])
    subparser.add_argument('-i','--independent', help='Make all permutations along a dimension independent', action='store_true')


def addparser_json(parsers, help: str):

    description = textwrap.dedent("""
    Adds empty-value versions of the json files in the BIDS input directory to the BIDS output directory.
    """)

    epilog = ('examples:\n'
              '  scrambler_json data/bids data/pseudobids json\n'
              "  scrambler_json data/bids data/pseudobids json participants.json -p '.*'\n"
              "  scrambler_json data/bids data/pseudobids json 'sub-.*.json' -p (?!(AcquisitionTime|.*Date))\n ")

    parser = parsers.add_parser('json', parents=[parent], formatter_class=DefaultsFormatter, description=description, epilog=epilog, help=help)
    parser.add_argument('-p', '--preserve', help='A regular expression pattern that is matched against all keys in the json input files. The json values are copied over to the output files when a key matches positively, else the normal empty value is used')
    parser.set_defaults(func=scrambler_json)


def main():
    """Console script entry point"""

    description = textwrap.dedent("""
    Add some general workflow overview
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
    addparser_json(subparsers, help='Short help for scrambler_json')

    # Execute the scrambler function
    args = parser.parse_args()
    args.func(**vars(args))


if __name__ == "__main__":
    main()
