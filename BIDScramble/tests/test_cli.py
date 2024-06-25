import subprocess
from importlib.metadata import entry_points


def test_cli():

    console_scripts = entry_points().select(group='console_scripts')    # The select method was introduced in python = 3.10

    entrypoints = []
    for script in console_scripts:
        if script.value.startswith('bidscramble'):
            entrypoints.append(script.name)
            process = subprocess.run(f"{script.name} -h", shell=True)
            assert process.returncode == 0
    assert 'scramble' in entrypoints
