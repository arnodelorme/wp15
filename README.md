# SIESTA - work package 15

This repository contains the work that is done in the context of work package 15, reflecting use case 2 about medical (neuro)imaging applications. It identifies representative datasets and defines some representative analysis pipelines.

## Data

Throughout this work package we distinguish three types of data:

1. Source or input data. This type of data typically concerns original data that, alongside features of scienctific interest, contains a rich set of _indirect_ personal data (but no _direct_ personal data). When combined with other data sources, indirect personal data may allow for re-identification of direct personal data (such as a subject's name or birthdate), and hence makes the input data unfit for unrestricted public sharing.
2. Pseudo or in-between data. This type of data is derived from the input data, such that the indirect personal features have been removed (to a varying degree) from the data, while the scientific features of interest are preserved sufficiently to allow implementing and testing an analysis pipeline.
3. Anonymous or output data. This type of data is also derived from the data, but no longer contains any direct or indirect personal data and is therefore always fit for sharing it externally.

## User roles

Permission for accessing data is defined by the role of the user. In this work packacge we distinguish three roles:

1. Data owner
2. Data user
3. Product owner

## Data flow

This can be conceived to be graphically depicted in a flowchart.

1. data owner -> sends input data to the platform
2. data user -> requests the product owner for access to the platform
3. data user -> installs software and dependencies
4. data user -> requests the product owner for pseudo data to be disclosed (using tools developed in this WP)
5. (optional) product owner -> requests the data owner for a review and permission to disclose the pseudo data to the data user
6. (optional) data owner -> grants permission
7. data user -> interactively implements and tests analysis pipeline on pseudo data
8. data user -> requests the product owner for the pipeline to be executed on the source data, output data is not yet disclosed
9. product owner -> requests the data owner for a review and permission to disclose the output data to the data user
10. data owner -> grants permission
11. data user -> uses output data to answer research question and publishes research outcomes

Step 5 and 6 are optional, depending on the trust that the data owner puts in the process for generating the pseudo data. There might be different levels of randomness implemented in the pseudo data tool (and requested by the data user), resulting in the in-between pseudo data being somewhere along the scale of "anonymous" to "personal". On one side of the scale, a review is not needed, whereas on the other side of the scale it is.
