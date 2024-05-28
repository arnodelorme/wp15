import json
import pandas as pd
import math
import urllib.request, urllib.error
from source import __version__, __description__, __url__
from source.bidscramble import bidscramble
from source.bidscramble_tsv import bidscramble_tsv


def test_bidscramble(tmp_path):

    # Create the input data
    (tmp_path/'input').mkdir()
    urllib.request.urlretrieve('https://s3.amazonaws.com/openneuro.org/ds004148/participants.tsv', tmp_path/'input'/'participants.tsv')
    urllib.request.urlretrieve('https://s3.amazonaws.com/openneuro.org/ds004148/participants.json', tmp_path/'input'/'participants.json')
    urllib.request.urlretrieve('https://s3.amazonaws.com/openneuro.org/ds004148/dataset_description.json', tmp_path/'input'/'dataset_description.json')
    urllib.request.urlretrieve('https://s3.amazonaws.com/openneuro.org/ds004148/README', tmp_path/'input'/'README')
    urllib.request.urlretrieve('https://s3.amazonaws.com/openneuro.org/ds004148/CHANGES', tmp_path/'input'/'CHANGES')

    # Fix the spdx identifier
    description = (tmp_path/'input'/'dataset_description.json').read_text().replace('CC0', 'CC0-1.0')
    (tmp_path/'input'/'dataset_description.json').write_text(description)

    # Create the output data
    bidscramble(tmp_path/'input', tmp_path/'output')

    # Check if all output data + LICENSE file is there
    assert (tmp_path/'output'/'LICENSE').is_file()
    assert len(list((tmp_path/'input').rglob('*'))) == len(list((tmp_path/'output').rglob('*'))) - 1

    # Check if the 'GeneratedBy' and 'DatasetType' have been written
    with (tmp_path/'output'/'dataset_description.json').open('r') as fid:
        description = json.load(fid)
    assert description['GeneratedBy'] == [{'Name':'BIDScramble', 'Version':__version__, 'Description:':__description__, 'CodeURL':__url__}]
    assert description['DatasetType'] == 'derivative'

    # Check if the README file has been copied
    readme = (tmp_path/'output'/'README').read_text()
    assert 'EEG' in readme


def test_bidscramble_tsv(tmp_path):

    # Create the input data
    (tmp_path/'input').mkdir()
    urllib.request.urlretrieve('https://s3.amazonaws.com/openneuro.org/ds004148/participants.tsv',  tmp_path/'input'/'participants.tsv')
    urllib.request.urlretrieve('https://s3.amazonaws.com/openneuro.org/ds004148/participants.tsv',  tmp_path/'input'/'partici_test.tsv')
    urllib.request.urlretrieve('https://s3.amazonaws.com/openneuro.org/ds004148/participants.json', tmp_path/'input'/'test.tsv')

    # Fix the "n/a " values
    tsvdata = (tmp_path/'input'/'participants.tsv').read_text().replace('n/a ', 'n/a')
    (tmp_path/'input'/'participants.tsv').write_text(tsvdata)

    # Create the output data
    bidscramble_tsv(tmp_path/'input', tmp_path/'output', ['partici*.tsv'], ['Height', 'Weig*'])
    assert (tmp_path/'output'/'partici_test.tsv').is_file()
    assert not (tmp_path/'output'/'test.tsv').is_file()

    # Check if the data is properly scrambled
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
