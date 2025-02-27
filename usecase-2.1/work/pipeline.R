#!/usr/bin/env Rscript

# This pipeline computes averages from the participants.tsv file
#
# Use as
#    ./pipeline.R [options] <inputdir> <outputdir> <level>
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

# This part of the script deals with possibly missing packages on-the-fly:
# It downloads them and puts them in a tempdir + adds the tempdir to the path
tdir <- tempdir()
.libPaths(c(tdir, .libPaths()))

hasoptparse  <- c("optparse") %in% rownames(installed.packages())
hasdplyr     <- c("dplyr") %in% rownames(installed.packages())
if (hasoptparse==FALSE)  {install.packages("optparse", lib=tdir, dependencies=TRUE, repos="https://cloud.r-project.org")}
if (hasdplyr==FALSE)     {install.packages("dplyr", lib=tdir, dependencies=TRUE, repos="https://cloud.r-project.org")}

# Load the required package for the option parsing
library("optparse", warn.conflicts = FALSE)
# Load the required package for column selection
library("dplyr", warn.conflicts = FALSE)

# Define the option parser
option_list <- list(
  make_option(c("-v", "--verbose"), action="store_true", default=FALSE,
              help="Print extra output"),
  make_option(c("--start-idx"), type="integer", default=0,
              help="Start index for participant selection", metavar="INTEGER"),
  make_option(c("--stop-idx"), type="integer", default=0,
              help="Stop index for participant selection", metavar="INTEGER")
)

# Parse the options
parser <- OptionParser(option_list=option_list, 
                       usage = "usage: %prog [options] input output level",
                       description = "This pipeline computes averages from the participants.tsv file.")
arguments <- parse_args(parser, positional_arguments = 3)
opts <- arguments$options
args <- arguments$args

# Check if help was requested
if (opts$help) {
  print_help(parser)
  quit(status = 0)
}

# Assign positional arguments
inputdir <- args[1]
outputdir <- args[2]
level <- args[3]

# Print verbose output if requested
if (opts$verbose) {
  cat("Verbose mode enabled\n")
  cat("Input directory:", inputdir, "\n")
  cat("Output directory:", outputdir, "\n")
  cat("Level:", level, "\n")
  cat("Starting index:", opts$'start-idx', "\n")
  cat("Stopping index:", opts$'stop-idx', "\n")
}

#
inputfile  <- file.path(inputdir, c("participants.tsv"))

# read table, deal with missing values
participants <- read.csv(inputfile, sep="\t", na.strings=c("n/a"))

# select the rows
if (opts$'stop-idx'>0) {
  participants <- participants[1:opts$'stop-idx', ]
}
if (opts$'start-idx'>0) {
  participants <- participants[opts$'start-idx':nrow(participants), ]
}

# print some of the columns
if (opts$verbose) {
  print(participants %>% select(1:5))
}

# create the output directory and its parents if they don't exist
dir.create(outputdir, recursive = TRUE, showWarnings = FALSE)

if (level == "participant") {
  print("nothing to do at the participant level, only creating participant-level output directories")
  for (i in 1:nrow(participants)) {
    dir.create(file.path(outputdir, participants$participant_id[i]), recursive = TRUE, showWarnings = FALSE)
  }

} else if (level == "group") {
  outputfile <- file.path(outputdir, "group", "results.tsv")
  dir.create(file.path(outputdir, "group"), recursive = TRUE, showWarnings = FALSE)

  # use the column names and capitalization from the original dataset
  # ignore missing values
  averagedage <- mean(participants$age, na.rm = TRUE)
  averagedHeight <- mean(participants$Height, na.rm = TRUE)
  averagedWeight <- mean(participants$Weight, na.rm = TRUE)

  # construct table with results
  result <- data.frame(averagedage, averagedHeight, averagedWeight)

  if (opts$verbose) {
    print(result)
  }

  # write the results to disk
  write.table(result, file=outputfile, sep="\t", col.names=FALSE, row.names=FALSE)
}
