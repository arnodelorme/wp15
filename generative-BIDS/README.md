# SIESTA - work package 15 - Generative BIDS

The generative BIDS tools generate pseudo random BIDS datasets from existing BIDS datasets. The tools:

- Preserve user specified effects of interest
- Preserve statistical distributions
- Generate non-existing data that is not (or at least minimally) traceable / does not contain personal data

It requires some BIDS-specific tooling to make the input dataset properly anonymous, possibly by replacing it with pseudodata. That allows researchers to interact with pseudo datasets and code to implement and test their pipelines. The pipelines should run on the pseudo data just as it runs on the real input data.

## Software installation

The generative BIDS software runs on multiple platforms (e.g. Linux, MacOS, Windows) that have a git and Python 3 installation. The tools and their depende can (should) be installed using (or equivalent):

```console
# It is adviced (but not required) to first create a virtual environment
python -m venv venv
source venv/bin/activate

# Then install the generative BIDS tools
git clone https://github.com/SIESTA-eu/wp15.git
cd wp15/generative-BIDS
pip install .
```

## Input data

### Use case 2.1

As a proof of principle, a simple BIDS generator is created that takes [use case 2.1](https://github.com/SIESTA-eu/wp15/blob/main/usecase-2.1/README.md) as input data and exports a pseudo BIDS dataset to a different (possibly demilitarized) location.

## Output data

## Running the pipeline

## Cleaning up

## Legal aspects

## References
