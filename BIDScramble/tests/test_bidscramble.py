import subprocess
from bidscramble import console_scripts

def test_cli_help():
    print(scripts := console_scripts(True))
    assert 'scramble' in scripts
    assert 'merge' in scripts
    for command in scripts:
        process = subprocess.run(f"{command} -h", shell=True, capture_output=True, text=True)
        print(f"{command} -h\n{process.stderr}\n{process.stdout}")
        assert process.stdout
        assert process.returncode == 0
