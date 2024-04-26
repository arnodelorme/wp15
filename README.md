# SIESTA - work package 15

This repository contains the work that is done in the context of work package 15, reflecting use case 2 about medical (neuro)imaging applications. It identifies representative datasets and defines some representative analysis pipelines.

## Data

Throughout this work package we distinguish three types of data:

1. Source data. This type of data typically concerns original data that, besides features of scienctific interest, contains a rich set of indirect (quasi) personal data. When combined with other data sources, indirect personal data allows for re-identification of direct personal data (such as a subject's name or birthdate), and hence makes the data unfit for sharing it externally.
2. Pseudonymized data. This type of data is derived from the source data, such that the indirect feautures have been removed (to a varying degree) from the data, while the scientific feautures are preserved as much as possible. 
3. Anonymized data. This type of data is also derived from the data, but no longer contains any indirect personal data and is therefore always fit for sharing it externally.

## User roles

Permission for accessing data is defined by the role of the user. In this work packacge we distinguish three roles:

1. Data owner
2. Data user
3. Product owner

## Data flow

TODO: make flowchart

1. data owner -> sends data to product owner
2. data user -> requests anonymous data from the product owner
3. data user -> sends analysis pipeline to the product owner and requests pseudomized data
4. product owner -> requests permission (review) from the data owner to send the pseudonymized data to the data user
5. data user -> repeats step 3-4 until pipeline is finished
6. ??
