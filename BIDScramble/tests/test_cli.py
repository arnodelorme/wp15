import subprocess
from importlib.metadata import entry_points
from bidscramble.scramble_nii import drmaa_nativespec


def test_cli():

    console_scripts = entry_points().select(group='console_scripts')    # The select method was introduced in python = 3.10

    entrypoints = []
    for script in console_scripts:
        if script.value.startswith('bidscramble'):
            entrypoints.append(script.name)
            process = subprocess.run(f"{script.name} -h", shell=True)
            assert process.returncode == 0
    assert 'scramble' in entrypoints


def test_drmaa_nativespec():

    class DrmaaSession:
        def __init__(self, drmaaImplementation):
            self.drmaaImplementation = drmaaImplementation

    specs = drmaa_nativespec('-l walltime=00:10:00,mem=2gb', DrmaaSession('PBS Pro'))
    assert specs == '-l walltime=00:10:00,mem=2gb'

    specs = drmaa_nativespec('-l walltime=00:10:00,mem=2gb', DrmaaSession('Slurm'))
    assert specs == '--time=00:10:00 --mem=2000'

    specs = drmaa_nativespec('-l mem=200,walltime=00:10:00', DrmaaSession('Slurm'))
    assert specs == '--mem=200 --time=00:10:00'

    specs = drmaa_nativespec('-l walltime=00:10:00,mem=2gb', DrmaaSession('Unsupported'))
    assert specs == ''
