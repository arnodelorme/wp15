using DataFrames
using CSV

function pipeline(options::Dict)
    # PIPELINE to compute some averages over participants using the data
    # in the participants.tsv file from a BIDS dataset.
    #
    # Use as
    #   pipeline(options)
    # where the options input argument is a dictionary with the following fields
    #   options[:inputdir]  = string
    #   options[:outputdir] = string
    #   options[:verbose]   = boolean
    #   options[:start_idx] = number, can be nothing
    #   options[:stop_idx]  = number, can be nothing
    #
    # See also BIDSAPP

    if haskey(options, :version) && options[:version]
        println("version = unknown")
        return
    end

    if haskey(options, :verbose) && options[:verbose]
        println("options =")
        display(options)
    end

    if haskey(options, :level) && options[:level] == "participant"
        # there is nothing to do at the participant level
        return
    end

    inputfile  = joinpath(options[:inputdir], "participants.tsv")
    outputfile = joinpath(options[:outputdir], "results.tsv")

    # Read the participants.tsv file into a DataFrame
    participants = CSV.read(inputfile, DataFrame; delim='\t')

    if haskey(options, :verbose) && options[:verbose]
        println("data contains $(nrow(participants)) participants")
    end

    # Select participants based on start_idx and stop_idx
    if haskey(options, :stop_idx) && !isnothing(options[:stop_idx])
        participants = participants[1:options[:stop_idx], :]
    end
    if haskey(options, :start_idx) && !isnothing(options[:start_idx])
        participants = participants[options[:start_idx]:end, :]
    end

    if haskey(options, :verbose) && options[:verbose]
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

    if haskey(options, :verbose) && options[:verbose]
        display(result)
    end

    # Write the results to a TSV file
    CSV.write(outputfile, result; delim='\t', writeheader=false)
end
