from importlib import metadata

try:
    __version__     = metadata.version('bidscramble')
    __description__ = metadata.metadata('bidscramble')['Summary']
    __url__         = metadata.metadata('bidscramble')['Project-URL']

except Exception:
    try:
        import tomllib
    except ModuleNotFoundError:
        import tomli as tomllib
    from pathlib import Path

    with open(Path(__file__).parents[1]/'pyproject.toml', 'rb') as fid:
        project = tomllib.load(fid)['project']
    __version__     = project['version']
    __description__ = project['description']
    __url__         = project['urls']['homepage']
