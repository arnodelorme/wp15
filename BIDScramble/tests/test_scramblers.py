import json
import numpy as np
import pandas as pd
import math
import nibabel as nib
import urllib.request, urllib.error
from bidscramble import __version__, __description__, __url__
from bidscramble.scrambler_stub import scrambler_stub
from bidscramble.scrambler_tsv import scrambler_tsv
from bidscramble.scrambler_json import scrambler_json
from bidscramble.scrambler_nii import scrambler_nii
from bidscramble.scrambler_swap import scrambler_swap


def test_scrambler_stub(tmp_path):

    # Create the input data
    (tmp_path/'input').mkdir()
    urllib.request.urlretrieve('https://s3.amazonaws.com/openneuro.org/ds004148/participants.tsv', tmp_path/'input'/'participants.tsv')
    urllib.request.urlretrieve('https://s3.amazonaws.com/openneuro.org/ds004148/participants.json', tmp_path/'input'/'participants.json')
    urllib.request.urlretrieve('https://s3.amazonaws.com/openneuro.org/ds004148/dataset_description.json', tmp_path/'input'/'dataset_description.json')
    urllib.request.urlretrieve('https://s3.amazonaws.com/openneuro.org/ds004148/README', tmp_path/'input'/'README')
    urllib.request.urlretrieve('https://s3.amazonaws.com/openneuro.org/ds004148/CHANGES', tmp_path/'input'/'CHANGES')
    (tmp_path/'input'/'code').mkdir()
    (tmp_path/'input'/'derivatives').mkdir()

    # Fix the spdx identifier
    description = (tmp_path/'input'/'dataset_description.json').read_text().replace('CC0', 'CC0-1.0')
    (tmp_path/'input'/'dataset_description.json').write_text(description)

    # Create the output data
    scrambler_stub(tmp_path/'input', tmp_path/'output', '.*(?<!derivatives)')

    # Check if all output data - `derivatives` + `LICENSE` is there
    assert (tmp_path/'output'/'LICENSE').is_file()
    assert len(list((tmp_path/'input').rglob('*'))) == len(list((tmp_path/'output').rglob('*')))
    assert (tmp_path/'output'/'code').is_dir()
    assert not (tmp_path/'output'/'derivatives').is_dir()

    # Check if the 'GeneratedBy' and 'DatasetType' have been written
    with (tmp_path/'output'/'dataset_description.json').open('r') as fid:
        description = json.load(fid)
    assert description['GeneratedBy'] == [{'Name':'BIDScramble', 'Version':__version__, 'Description:':__description__, 'CodeURL':__url__}]
    assert description['DatasetType'] == 'derivative'

    # Check if the README file has been copied
    readme = (tmp_path/'output'/'README').read_text()
    assert 'EEG' in readme


def test_scrambler_tsv(tmp_path):

    # Create the input data
    (tmp_path/'input').mkdir()
    urllib.request.urlretrieve('https://s3.amazonaws.com/openneuro.org/ds004148/participants.tsv',  tmp_path/'input'/'participants.tsv')
    urllib.request.urlretrieve('https://s3.amazonaws.com/openneuro.org/ds004148/participants.tsv',  tmp_path/'input'/'partici_test.tsv')
    urllib.request.urlretrieve('https://s3.amazonaws.com/openneuro.org/ds004148/participants.json', tmp_path/'input'/'test.tsv')

    # Fix the "n/a " values
    tsvdata = (tmp_path/'input'/'participants.tsv').read_text().replace('n/a ', 'n/a')
    (tmp_path/'input'/'participants.tsv').write_text(tsvdata)

    # Create nulled output data
    scrambler_tsv(tmp_path/'input', tmp_path/'output', 'partici.*\\.tsv', '', '')
    assert (tmp_path/'output'/'partici_test.tsv').is_file()
    assert not (tmp_path/'output'/'test.tsv').is_file()

    # Check if the participants.tsv data is properly nulled
    inputdata  = pd.read_csv(tmp_path/'input'/'participants.tsv', sep='\t')
    outputdata = pd.read_csv(tmp_path/'output'/'participants.tsv', sep='\t')
    assert inputdata.shape == outputdata.shape
    for column, values in outputdata.items():
        assert column in inputdata.columns
        assert values.isnull().all()

    # Create permuted output data
    (tmp_path/'output'/'participants.tsv').unlink()
    scrambler_tsv(tmp_path/'input', tmp_path/'output', 'partici.*\\.tsv', 'permute', '(Height|Weig.*)')

    # Check if the participants.tsv data is properly permuted
    inputdata  = pd.read_csv(tmp_path/'input'/'participants.tsv', sep='\t')
    outputdata = pd.read_csv(tmp_path/'output'/'participants.tsv', sep='\t')
    assert inputdata.shape == outputdata.shape
    assert not inputdata['participant_id'].equals(outputdata['participant_id'])
    for key in ['Height', 'Weight', 'age']:
        assert not inputdata[key].equals(outputdata[key])
        assert math.isclose(inputdata[key].mean(), outputdata[key].mean())
        assert math.isclose(inputdata[key].std(),  outputdata[key].std())

    # Check if the relation between 'Height' and 'Weight' is preserved, but not between 'SAS_1stVisit' and 'SAS_2ndVisit'
    assert math.isclose(inputdata['Height'].corr(inputdata['Weight']), outputdata['Height'].corr(outputdata['Weight']))
    assert not math.isclose(inputdata['SAS_1stVisit'].corr(inputdata['SAS_2ndVisit']), outputdata['SAS_1stVisit'].corr(outputdata['SAS_2ndVisit']))


def test_scrambler_json(tmp_path):

    # Create the input data
    eegjson = 'sub-01/ses-session1/eeg/sub-01_ses-session1_task-eyesclosed_eeg.json'
    (tmp_path/'input'/'sub-01'/'ses-session1'/'eeg').mkdir(parents=True)
    urllib.request.urlretrieve('https://s3.amazonaws.com/openneuro.org/ds004148/participants.json', tmp_path/'input'/'participants.json')
    urllib.request.urlretrieve(f"https://s3.amazonaws.com/openneuro.org/ds004148/{eegjson}", tmp_path/'input'/eegjson)

    # Create the output data
    scrambler_json(tmp_path/'input', tmp_path/'output', '.*/sub-.*\.json', '(?!RecordingDuration|Channel).*')
    assert (tmp_path/'output'/eegjson).is_file()
    assert not (tmp_path/'output'/'participants.json').is_file()

    # Check if the participants.json data is properly preserved/emptied
    with (tmp_path/'input'/eegjson).open('r') as fid:
        inputdata = json.load(fid)
    with (tmp_path/'output'/eegjson).open('r') as fid:
        outputdata = json.load(fid)
    assert inputdata.keys() == outputdata.keys()
    assert inputdata['TaskDescription'] == outputdata['TaskDescription']
    assert not outputdata['RecordingDuration']
    assert not outputdata['EMGChannelCount']


def test_scrambler_nii(tmp_path):

    # Create the input data
    niifile = 'sub-01/ses-mri/dwi/sub-01_ses-mri_dwi.nii.gz'
    (tmp_path/'input'/'sub-01'/'ses-mri'/'dwi').mkdir(parents=True)
    urllib.request.urlretrieve('https://s3.amazonaws.com/openneuro.org/ds000117/participants.tsv', tmp_path/'input'/'participants.tsv')
    urllib.request.urlretrieve(f"https://s3.amazonaws.com/openneuro.org/ds000117/{niifile}", tmp_path/'input'/niifile)

    # Create nulled output data
    scrambler_nii(tmp_path/'input', tmp_path/'output', 'sub.*\\.nii.gz', '')
    assert (tmp_path/'output'/niifile).is_file()
    assert not (tmp_path/'output'/'participants.tsv').is_file()

    # Check if the NIfTI data is properly nulled
    outdata = nib.load(tmp_path/'output'/niifile).get_fdata()
    assert outdata.shape == (96, 96, 68, 65)
    assert outdata.sum() == 0

    # Create blurred output data
    (tmp_path/'output'/niifile).unlink()
    scrambler_nii(tmp_path/'input', tmp_path/'output', 'sub.*\\.nii.gz', 'blur', fwhm=12)
    assert (tmp_path/'output'/niifile).is_file()

    # Check if the NIfTI data is properly blurred
    indata  = nib.load(tmp_path/'input'/niifile).get_fdata()
    outdata = nib.load(tmp_path/'output'/niifile).get_fdata()
    assert outdata.shape == (96, 96, 68, 65)
    assert outdata.sum() > 1000000
    assert outdata.sum() - indata.sum() < 1
    assert np.abs(outdata - indata).sum() > 1000

    # Create permuted output data
    (tmp_path/'output'/niifile).unlink()
    scrambler_nii(tmp_path/'input', tmp_path/'output', 'sub.*\\.nii.gz', 'permute', dims=['x','z'], independent=False)
    assert (tmp_path/'output'/niifile).is_file()

    # Check if the NIfTI data is properly permuted
    outdata = nib.load(tmp_path/'output'/niifile).get_fdata()
    assert outdata.shape == (96, 96, 68, 65)
    assert outdata.sum() > 1000000
    assert outdata.sum() - indata.sum() < 1
    assert np.abs(outdata - indata).sum() > 1000

    # Create independently permuted output data
    (tmp_path/'output'/niifile).unlink()
    scrambler_nii(tmp_path/'input', tmp_path/'output', 'sub.*\\.nii.gz', 'permute', dims=['x'], independent=True)
    assert (tmp_path/'output'/niifile).is_file()

    # Check if the NIfTI data is properly permuted
    outdata = nib.load(tmp_path/'output'/niifile).get_fdata()
    assert outdata.shape == (96, 96, 68, 65)
    assert outdata.sum() > 1000000
    assert outdata.sum() - indata.sum() < 1
    assert np.abs(outdata - indata).sum() > 1000

    # Create diffused output data
    (tmp_path/'output'/niifile).unlink()
    scrambler_nii(tmp_path/'input', tmp_path/'output', 'sub.*\\.nii.gz', 'diffuse', radius=25)
    assert (tmp_path/'output'/niifile).is_file()

    # Check if the NIfTI data is properly diffused
    outdata = nib.load(tmp_path/'output'/niifile).get_fdata()
    assert outdata.shape == (96, 96, 68, 65)
    assert outdata.sum() > 1000000
    assert outdata.sum() - indata.sum() < 1
    assert np.abs(outdata - indata).sum() > 1000

    # Create wobbled output data
    (tmp_path/'output'/niifile).unlink()
    scrambler_nii(tmp_path/'input', tmp_path/'output', 'sub.*\\.nii.gz', 'wobble', amplitude=25, freqrange=[0.05, 0.5])
    assert (tmp_path/'output'/niifile).is_file()

    # Check if the NIfTI data is properly diffused
    outdata = nib.load(tmp_path/'output'/niifile).get_fdata()
    assert outdata.shape == (96, 96, 68, 65)
    assert outdata.sum() > 1000000
    assert outdata.sum() - indata.sum() < 1
    assert np.abs(outdata - indata).sum() > 1000


def test_scrambler_swap(tmp_path):

    # Create the input data
    funcjsons = []
    for sub in range(1,9):
        (tmp_path/'input'/f"sub-0{sub}"/'func').mkdir(parents=True)
        for run in range(1,5):
            if not (sub == 8 and run == 4):
                funcjsons.append(f"sub-0{sub}/func/sub-0{sub}_task-closed_run-0{run}_bold.json")
                print('Downloading:', funcjsons[-1])
                urllib.request.urlretrieve(f"https://s3.amazonaws.com/openneuro.org/ds005194/{funcjsons[-1]}", tmp_path/'input'/funcjsons[-1])
    # Add 1 unique run-05 file
    funcjsons.append('sub-01/func/sub-01_task-closed_run-05_bold.json')
    urllib.request.urlretrieve(f"https://s3.amazonaws.com/openneuro.org/ds005194/{funcjsons[-1]}", tmp_path/'input'/funcjsons[-1])

    # Create the output data for swapping between subjects and runs
    scrambler_swap(tmp_path/'input', tmp_path/'output', '.*/sub-.*\.json', ['subject', 'run'])
    for funcjson in funcjsons:
        assert (tmp_path/'output'/funcjson).is_file()

    # Check if the run-05 json data is properly swapped
    with (tmp_path/'input'/funcjsons[-1]).open('r') as fid:
        inputdata = json.load(fid)
    with (tmp_path/'output'/funcjsons[-1]).open('r') as fid:
        outputdata = json.load(fid)
    assert inputdata.keys() == outputdata.keys()
    assert inputdata['AcquisitionTime'] != outputdata['AcquisitionTime']

    # Create the output data for swapping between subjects, but not between runs
    for funcjson in funcjsons:
        (tmp_path/'output'/funcjson).unlink()
    scrambler_swap(tmp_path/'input', tmp_path/'output', '.*/sub-.*\.json', ['subject'])
    for funcjson in funcjsons:
        assert (tmp_path/'output'/funcjson).is_file()

    # Check if the run-01 json data is swapped
    with (tmp_path/'input'/funcjsons[0]).open('r') as fid:
        inputdata = json.load(fid)
    with (tmp_path/'output'/funcjsons[0]).open('r') as fid:
        outputdata = json.load(fid)
    assert inputdata['AcquisitionTime'] != outputdata['AcquisitionTime']

    # Check if the run-05 json data is not swapped
    with (tmp_path/'input'/funcjsons[-1]).open('r') as fid:
        inputdata = json.load(fid)
    with (tmp_path/'output'/funcjsons[-1]).open('r') as fid:
        outputdata = json.load(fid)
    assert inputdata['AcquisitionTime'] == outputdata['AcquisitionTime']
