# SIESTA - work package 15 - use case 2.3

This implements the Event-Related Potential [(ERP)]() analysis of 'classical' [ElectroEncephalography]() research paradigms. There are two versions: 2.3.A. and 2.3.B. Version 2.3.A is fully automated, testing whether this can be run on anonymized data. Version 2.3.B requires user interaction at the input level, minimizing what information is given to users given a research question.

## Input data

The input data is obtained manually by downloading the [ERPCore BIDS dataset](https://osf.io/9f5w7/).

### Legal aspects of the input data

Those data are openly (CCBY4.0) and freely available.

## Output data

The output data will consist of ...

```console
mkdir -p output
```

## Analysis pipeline

### Software requirements

[Matlab]() with the [EGGLAB]() external toolbox and the [LIMO MEEG] plugin. 
*Installation*:
EEGLAB


### Legal aspects of the required software

...

### Executing the pipeline

Executing the pipeline from the Linux command-line is done using the following:

    ...

### Cleaning up

Cleaning up the input and output data is done using:

```console
rm -rf input
rm -rf output
```

## References

[1]: https://www.example.com
[2]: https://www.markdownguide.org/cheat-sheet/
