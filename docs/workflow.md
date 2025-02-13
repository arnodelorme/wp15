# SIESTA computational workflow

## Data rights holder

    ./download.sif input
    ./scramble.sif input scrambled <options>
    ./datleak.sif input scrambled <options>

## Data user

Develop the pipeline and test it.
     
    ./pipeline.sif scrambled output participant
    ./pipeline.sif scrambled output group
    
## Platform operator

Run the particpant-level analysis on the single subjects.

    for SUBJ in `seq -w $NSUBJ`; do 
        ./singlesubject.sif $SUBJ input singlesubject-$SUBJ
    done

    for SUBJ in `seq -w $NSUBJ`; do 
        ./pipeline.sif singlesubject-$SUBJ participant-$SUBJ participant
    done

    ./mergeparticipant.sif participant-* participant-merged

At this level we can and therefore should implement a test. One option is to run 
the particpant-level analysis on all subjects together and check that results 
are consistent with the merged results.

    ./pipeline.sif input participant-all participant
    ./compare.sif participant-all participant-merged

We then add the participant-level derivatives to the input dataset. 

    ./mergederivatives.sif input participants-merged input+derivatives

Run the group-level analysis on the leave-one-out resampled datasets.

    for SUBJ in `seq -w $NSUBJ`; do 
        ./leaveoneout.sif $SUBJ input+derivatives leaveoneout-$SUBJ
    done

    for SUBJ in `seq -w $NSUBJ`; do 
        ./pipeline.sif leaveoneout-$SUBJ group-$SUBJ group
    done

    ./mergegroup.sif group-* group-merged
    ./calibratenoise.sif group-merged noise

Run the group-level analysis on all subjects together and add the calibrated noise.

This would also be another moomemnt to test and compare the average of the `group-merged` and the `group-all` data.

    ./pipeline.sif input+derivatives group-all 
    ./addnoise.sif group-all noise group-with-noise

## Data rights holder

Review the results with the calibrated noise and release them to the data user.


# Required applications or containers

addnoise.sif
calibratenoise.sif
compare.sif
datleak.sif
download.sif 
leaveoneout.sif
mergederivatives.sif
mergegroup.sif
mergeparticipant.sif
pipeline.sif 
scramble.sif
singlesubject.sif

# Required data directories or volumes

input
scrambled
output
singlesubject-xxx
participant-xxx
participant-merged
participant-all
input+derivatives
leaveoneout-xxx
group-xxx
group-merged
noise
group-all
group-with-noise

# Ideas

Compare the file and directory structure of `group-xxx` with those of `group-all`.
Compare the file and directory structure of `noise` with those of `group-all`.
Compare the file and directory structure of `group-with-noise` with those of `group-all`.

