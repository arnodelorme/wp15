from importlib import metadata

__version__     = metadata.version('bidscramble')
__description__ = metadata.metadata('bidscramble')['Summary']
__url__         = metadata.metadata('bidscramble')['Project-URL']
