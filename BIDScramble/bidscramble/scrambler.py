#!/usr/bin/env python3

import argparse
import textwrap
from .scrambler_stub import scrambler_stub
from .scrambler_tsv import scrambler_tsv
from .scrambler_nii import scrambler_nii
from .scrambler_json import scrambler_json
from .scrambler_swap import scrambler_swap

# Use parent parsers to inherit optional arguments (https://macgregor.gitbooks.io/developer-notes/content/python/argparse-basics.html#inheriting-arguments)
parent = argparse.ArgumentParser(add_help=False)
parent.add_argument('-s','--select', metavar='PATTERN', help='A fullmatch regular expression pattern that is matched against the relative path of the input data. Files that match are scrambled and saved in outputfolder', default='.*')
parent.add_argument('-d','--dryrun', help='Do not save anything, only print the output filenames in the terminal', action='store_true')
parent_nii = argparse.ArgumentParser(add_help=False, parents=[parent])
parent_nii.add_argument('-c','--cluster', help='Use the DRMAA library to submit the scramble jobs to a high-performance compute (HPC) cluster. You can add an opaque DRMAA argument with native specifications for your HPC resource manager (NB: Use quotes and include at least one space character to prevent premature parsing -- see examples)',
                        metavar='SPECS', nargs='?', const='-l mem=4gb,walltime=0:15:00', type=str)


class DefaultsFormatter(argparse.ArgumentDefaultsHelpFormatter, argparse.RawDescriptionHelpFormatter): pass


def addparser_stub(parsers, help: str):

    description = textwrap.dedent("""
    Creates a copy of the BIDS input directory in which all files are empty stubs. Exceptions to this are the
    'dataset_description.json', 'README', 'CHANGES', 'LICENSE' and 'CITATION.cff' files, which are copied over and
    updated if possible.
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

    subparsers = parser.add_subparsers(dest='method', help='Scrambling method. Add -h, --help for more information')
    subparser = subparsers.add_parser('permute', parents=[parent], description=description, help='Randomly permute the column values of the tsv files')
    subparser.add_argument('-p','--preserve', metavar='PATTERN', help='A regular expression pattern that is matched against tsv column names. The exact relationship between the matching columns is then preserved, i.e. they are permuted in conjunction instead of independently')


def addparser_nii(parsers, help: str):

    description = textwrap.dedent("""
    Adds scrambled versions of the NIfTI files in the BIDS input directory to the BIDS output directory. If no
    scrambling method is specified, the default behavior is to null all image values.
    """)

    epilog = ('examples:\n'
              '  scrambler data/bids data/pseudobids nii\n'
              '  scrambler data/bids data/pseudobids nii diffuse -h\n'
              "  scrambler data/bids data/pseudobids nii diffuse 2 -s 'sub-.*_MP2RAGE.nii.gz' -c '--mem=5000 --time=0:20:00'\n"
              "  scrambler data/bids data/pseudobids nii wobble -a 2 -f 1 8 -s 'sub-.*_T1w.nii'\n ")

    parser = parsers.add_parser('nii', parents=[parent_nii], formatter_class=DefaultsFormatter, description=description, epilog=epilog, help=help)
    parser.set_defaults(func=scrambler_nii)

    subparsers = parser.add_subparsers(dest='method', help='Scrambling method. Add -h, --help for more information')
    subparser = subparsers.add_parser('blur', parents=[parent_nii], description=description, help='Apply a 3D Gaussian smoothing filter')
    subparser.add_argument('fwhm', help='The FWHM (in mm) of the isotropic 3D Gaussian smoothing kernel', type=float)
    subparser = subparsers.add_parser('permute', parents=[parent_nii], formatter_class=DefaultsFormatter, description=description, help='Perform random permutations along one or more image dimensions')
    subparser.add_argument('dims', help='The dimensions along which the images will be permuted', nargs='*', choices=['x','y','z','t','u','v','w'], default=['x','y'])
    subparser.add_argument('-i','--independent', help='Make all permutations along a dimension independent (instead of permuting slices as a whole)', action='store_true')
    subparser = subparsers.add_parser('diffuse', parents=[parent_nii], formatter_class=DefaultsFormatter, description=description, help='Perform random permutations using a sliding 3D permutation kernel')
    subparser.add_argument('radius', help='The radius (in mm) of the 3D/cubic permutation kernel', type=float, nargs='?', default=3)
    subparser = subparsers.add_parser('wobble', parents=[parent_nii], formatter_class=DefaultsFormatter, description=description, help='Deform the images using 3D random waveforms')
    subparser.add_argument('-a','--amplitude', metavar='GAIN', help='The amplitude of the random waveform', type=float, default=2)
    subparser.add_argument('-f','--freqrange', metavar='FREQ', help='The lowest and highest spatial frequency (in mm) of the random waveform', nargs=2, type=float, default=[1, 5])


def addparser_json(parsers, help: str):

    description = textwrap.dedent("""
    Adds scrambled key-value versions of the json files in the BIDS input directory to the BIDS output directory. If no
    preserve expression is specified, the default behavior is to null all values.
    """)

    epilog = ('examples:\n'
              '  scrambler data/bids data/pseudobids json\n'
              "  scrambler data/bids data/pseudobids json participants.json -p '.*'\n"
              "  scrambler data/bids data/pseudobids json 'sub-.*.json' -p '(?!AcquisitionTime|Date).*'\n ")

    parser = parsers.add_parser('json', parents=[parent], formatter_class=DefaultsFormatter, description=description, epilog=epilog, help=help)
    parser.add_argument('-p','--preserve', metavar='PATTERN', help='A fullmatch regular expression pattern that is matched against all keys in the json files. The json values are copied over when a key matches positively')
    parser.set_defaults(func=scrambler_json)


def addparser_swap(parsers, help: str):

    description = textwrap.dedent("""
    Randomly swappes the content of data files between a group of similar files in the BIDS input directory and save
    them as output.
    """)

    epilog = ('examples:\n'
              '  scrambler data/bids data/pseudobids swap\n'
              "  scrambler data/bids data/pseudobids swap -s '.*\.(nii|json|tsv)'\n"
              "  scrambler data/bids data/pseudobids swap -s '.*(?<!derivatives)'\n"
              "  scrambler data/bids data/pseudobids swap -g subject session run\n ")

    parser = parsers.add_parser('swap', parents=[parent], formatter_class=DefaultsFormatter, description=description, epilog=epilog, help=help)
    parser.add_argument('-g','--grouping', metavar='ENTITY', help='A list of (full-name) BIDS entities that make up a group between which file contents are swapped. See: https://bids-specification.readthedocs.io/en/stable/appendices/entities.html', nargs='+', default=['subject'], type=str)
    parser.set_defaults(func=scrambler_swap)


def main():
    """Console script entry point"""

    description = textwrap.dedent("""
    The general workflow to build up a scrambled BIDS dataset is by consecutively running `scrambler` for actions of
    your choice. For instance, you could first run `scrambler` with the `stub` action to create a dummy dataset with
    only the file structure and some basic files, and then run `scrambler` with the `nii` action  to specifically add
    scrambled NIfTI data (see examples below). To combine different scrambling actions, simply re-run `scrambler` using
    the already scrambled data as input folder.""")

    # Add the baseparser
    parser = argparse.ArgumentParser(formatter_class=DefaultsFormatter, description=description,
                                     epilog='examples:\n'
                                            '  scrambler data/bids data/pseudobids stub -h\n'
                                            '  scrambler data/bids data/pseudobids nii -h\n ')
    parser.add_argument('bidsfolder',   help='The BIDS (or BIDS-like) input directory with the original data')
    parser.add_argument('outputfolder', help='The output directory with the scrambled pseudo data')

    # Add the subparsers
    subparsers = parser.add_subparsers(dest='method', title='Action', help='Add -h, --help for more information', required=True)
    addparser_stub(subparsers, help='Saves a dummy bidsfolder skeleton in outputfolder')
    addparser_tsv(subparsers,  help='Saves scrambled tsv files in outputfolder')
    addparser_nii(subparsers,  help='Saves scrambled NIfTI files in outputfolder')
    addparser_json(subparsers, help='Saves scrambled json files in outputfolder')
    addparser_swap(subparsers, help='Saves swapped file contents in outputfolder')

    # Execute the scrambler function
    args = parser.parse_args()
    args.func(**vars(args))


if __name__ == '__main__':
    main()
