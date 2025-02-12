#!/usr/bin/env julia

# This pipeline computes averages from the participants.tsv file
#
# Use as 
#    ./pipeline.jl [options] <inputdir> <outputdir> <level>
# where the input and output directory must be specified, and the 
# level is either "group" or "participant".
#
# Optional arguments:
#   -h,--help           Show this help and exit.
#   --verbose           Enable verbose output.
#   --start-idx <num>   Start index for participant selection.
#   --stop-idx <num>    Stop index for participant selection.

# This code is shared under the CC0 license
#
# Copyright (C) 2024, SIESTA workpackage 15 team

using ArgParse
using CSV
using DataFrames
using Statistics

############################################################
# Parse the command line arguments
############################################################

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "inputdir"
            help = "the input directory"
            required = true
        "outputdir"
            help = "the output directory"
            required = true
        "level"
            help = "the analysis level, either 'participant' or 'group'"
            required = true
        "--start-idx"
            help = "index of the first participant to include, one-offset"
            arg_type = Int
            default = 0
        "--stop-idx"
            help = "index of the last participant to include, one-offset"
            arg_type = Int
            default = 0
        "--verbose", "-v"
            help = "give more verbose information for debugging"
            action = :store_true
    end

    return parse_args(s)
end

##########################################################################
# Compute the averages of the age, height, and weight of the participants
##########################################################################

function main(options)

    if haskey(options, "verbose") && options["verbose"]
        println("options =")
        display(options)
    end

    if haskey(options, "level") && options["level"] == "participant"
        println("nothing to do at the participant level")
        return
    end

    # Create the output directory and its parents if they don't exist
    mkpath(options["outputdir"])

    inputfile  = joinpath(options["inputdir"], "participants.tsv")
    outputfile = joinpath(options["outputdir"], "results.tsv")

    # Read the participants.tsv file into a DataFrame
    participants = CSV.read(inputfile, DataFrame; delim='\t', missingstring="n/a")

    if haskey(options, "verbose") && options["verbose"]
        println("data contains $(nrow(participants)) participants")
    end

    # Select participants based on start_idx and stop_idx
    if haskey(options, "stop_idx") && options["stop_idx"] > 0
        participants = participants[1:options["stop_idx"], :]
    end
    if haskey(options, "start_idx") && options["start_idx"] > 0
        participants = participants[options["start_idx"]:end, :]
    end

    if haskey(options, "verbose") && options["verbose"]
        println("selected $(nrow(participants)) participants")
    end

    # Compute averages
    averagedAge    = mean(skipmissing(participants.age))
    averagedHeight = mean(skipmissing(participants.Height))
    averagedWeight = mean(skipmissing(participants.Weight))

    # Put the results in a DataFrame
    result = DataFrame(
        averagedAge = [averagedAge],
        averagedHeight = [averagedHeight],
        averagedWeight = [averagedWeight]
    )

    if haskey(options, "verbose") && options["verbose"]
        display(result)
    end

    # Write the results to a TSV file
    CSV.write(outputfile, result; delim='\t', writeheader=false)
end

##########################################################################
# execute the code if it is run as a script
##########################################################################

options = parse_commandline()
main(options)

