# SIESTA - work package 15 - Generative BIDS

The generative BIDS tools generate pseudo random BIDS datasets from existing BIDS datasets. The tools:

- Preserve user specified effects of interest
- Preserve statistical distributions
- Generate non-existing data that is not (or at least minimally) traceable

It requires some BIDS-specific tooling to make the input dataset properly anonymous, possibly by replacing it with pseudodata. That allows the researcher to interact with the dataset and code to implement and test the pipeline. The pipeline should run on the pseudo data just as it runs on the real input data.

## Use case 2.1

As a proof of principle, a simple BIDS generator is created that takes [use case 2.1](https://github.com/SIESTA-eu/wp15/blob/main/usecase-2.1/README.md) as input data and exports a pseudo BIDS dataset to a different (possibly demilitarized) location.
