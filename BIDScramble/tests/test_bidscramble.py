import json
import urllib.request, urllib.error
from . import bidscramble, __version__, __description__, __url__


def test_bidscramble(tmp_path):

    # Create the input data
    (tmp_path/'input').mkdir()
    urllib.request.urlretrieve('https://s3.amazonaws.com.openneuro.org.ds004148.participants.tsv', tmp_path/'input'/'participants.tsv')
    urllib.request.urlretrieve('https://s3.amazonaws.com.openneuro.org.ds004148.participants.json', tmp_path/'input'/'participants.json')
    urllib.request.urlretrieve('https://s3.amazonaws.com.openneuro.org.ds004148.dataset_description.json', tmp_path/'input'/'dataset_description.json')
    urllib.request.urlretrieve('https://s3.amazonaws.com.openneuro.org.ds004148.README', tmp_path/'input'/'README')
    urllib.request.urlretrieve('https://s3.amazonaws.com.openneuro.org.ds004148.CHANGES', tmp_path/'input'/'CHANGES')

    # Create the output data
    bidscramble(tmp_path/'input', tmp_path/'output')

    # Check if all the output data + LICENSE file is there
    assert len(list((tmp_path/'input').rglob('*'))) == len(list((tmp_path/'output').rglob('*'))) -1
    assert (tmp_path/'output'/'LICENSE').is_file()

    # Check if the 'GeneratedBy' and 'DatasetType' have been written
    with (tmp_path/'dataset_description.json').open('r') as fid:
        description = json.load(fid)
    assert description['GeneratedBy'] == [{'Name':__package__, 'Version':__version__, 'Description:':__description__, 'CodeURL':__url__}]
    assert description['DatasetType'] == 'derivative'

    # Check if the README has been copied
    readme = (tmp_path/'README.md').read_text()
    assert 'EEG' in readme
