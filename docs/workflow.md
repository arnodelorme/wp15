# SIESTA computational workflow

## Data rights holder

    ./download.sif input
    ./scramble.sif input scrambled <options>
    ./privacy.sif input scrambled <options>

## Data user

Develop the pipeline and test it.
     
    ./pipeline.sif scrambled output participant
    ./pipeline.sif scrambled output group
    
## Platform operator

Run the particpant-level analysis on the single subjects.

    for SUBJ in `seq -w $NSUBJ`; do 
        ./singlesubject.sif input singlesubject-$SUBJ $SUBJ
    done

    for SUBJ in `seq -w $NSUBJ`; do 
        ./pipeline.sif singlesubject-$SUBJ participant-$SUBJ participant
    done

    ./mergeparticipant.sif participant-* participant-merged

At this level we can implement a test. One option for that is to run the
particpant-level analysis on all subjects together and check that results 
are consistent with the merged results.

    ./pipeline.sif input participant-all participant
    ./compare.sif participant-all participant-merged

We then add the participant-level derivatives to the input dataset. 

    ./mergederivatives.sif input participants-merged input+derivatives

Run the group-level analysis on the leave-one-out resampled datasets.

    for SUBJ in `seq -w $NSUBJ`; do 
        ./leaveoneout.sif input+derivatives leaveoneout-$SUBJ $SUBJ
    done

    for SUBJ in `seq -w $NSUBJ`; do 
        ./pipeline.sif leaveoneout-$SUBJ group-$SUBJ group
    done

    ./mergegroup.sif group-* group-merged
    ./calibratenoise.sif group-merged noise

Run the group-level analysis on all subjects together and add the calibrated noise.

    ./pipeline.sif input+derivatives group-all 
    ./addnoise.sif group-all noise group-with-noise

## Data rights holder

Review the group-level results with the calibrated noise and release them to the data user.

    ./privacy.sif group-with-noise

# Required applications or containers

- download.sif 
- scramble.sif
- privacy.sif (on the scrambled input data)
- singlesubject.sif
- pipeline.sif (participant-level, on single-subject data)
- mergeparticipant.sif
- pipeline.sif (participant-level, on all data)
- compare.sif
- mergederivatives.sif
- leaveoneout.sif
- pipeline.sif (group-level, on resampled data)
- mergegroup.sif
- pipeline.sif (group-level, on all data, not resampled)
- compare.sif
- calibratenoise.sif
- addnoise.sif
- privacy.sif (on the differentially private output data)

# Required data directories or volumes

- input
- scrambled
- output
- singlesubject-xxx
- participant-xxx
- participant-merged
- participant-all
- input+derivatives
- leaveoneout-xxx
- group-xxx
- group-merged
- noise
- group-all
- group-with-noise

# Ideas for testing and sanity checks

The comparison between the participant-merged and the participant-all is already specified above.

Compare the file and directory structure of `group-xxx` with those of `group-all`.

Compare the file and directory structure of `noise` with those of `group-all`.

Compare the file and directory structure of `group-with-noise` with those of `group-all`.
