# SIESTA - work package 15 - Generative BIDS

The generative BIDS tools generate pseudo random BIDS datasets from existing BIDS datasets. The tools:

- Preserve user specified effects of interest
- Preserve statistical distributions
- Generate non-existing data that is not (or at least minimally) traceable / does not contain personal data

It requires some BIDS-specific tooling to make the input dataset properly anonymous, possibly by replacing it with pseudodata. That allows researchers to interact with pseudo datasets and code to implement and test their pipelines. The pipelines should run on the pseudo data just as it runs on the real input data.

## Software installation

The generative BIDS software runs on multiple platforms (e.g. Linux, MacOS, Windows) that have a Python 3 installation.

It is recommended (but not required) to first create a virtual environment.

```console
python -m venv venv
source venv/bin/activate
```

You can then install the generative BIDS tools using git and pip.

```console
git clone https://github.com/SIESTA-eu/wp15.git     # Or download the code yourself 
pip install wp15/generative-BIDS                    # Or use an alternative installer
```

## Legal Aspects
