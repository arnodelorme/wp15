# This part of the script deals with possibly missing packages on-the-fly:
# It downloads them and puts them in a tempdir + adds the tempdir to the path
tdir <- tempdir()
.libPaths(tdir)

hasgetopt    <- c("getopt") %in% rownames(installed.packages())
hasoptparse  <- c("optparse") %in% rownames(installed.packages())
hasdplyr     <- c("dplyr") %in% rownames(installed.packages())
if (hasgetopt==FALSE)    {install.packages("getopt",   lib=tdir, dependencies=FALSE, repos="https://cloud.r-project.org")}
if (hasoptparse==FALSE)  {install.packages("optparse", lib=tdir, dependencies=FALSE, repos="https://cloud.r-project.org")}
if (hasdplyr==FALSE)     {install.packages("dplyr", lib=tdir, dependencies=TRUE, repos="https://cloud.r-project.org")}

# Load the required package for the option parsing
library("optparse")
# Load the required package for column selection
library("dplyr")

option_list = list(
  make_option(c("-i", "--inputdir"), type="character", default=NULL,
              help="input directory", metavar="character"),
  make_option(c("-o", "--outputdir"), type="character", default=NULL,
              help="output directory", metavar="character")
);

usage = "usage: Rscript %prog -f INPUTDIR -o OUTPUTDIR"
opt_parser = OptionParser(usage=usage, option_list=option_list);
opt = parse_args(opt_parser);

if (is.null(opt$inputdir)){
  print_help(opt_parser)
  stop("Input directory must be supplied.", call.=FALSE)
}

if (is.null(opt$outputdir)){
  print_help(opt_parser)
  stop("Output directory must be supplied.", call.=FALSE)
}

#
inputfile  <- file.path(opt$inputdir, c("participants.tsv"))
outputfile <- file.path(opt$outputdir, c("results.tsv"))

# read table, deal with missing values
participants <- read.csv(inputfile, sep="\t", na.strings=c("n/a"))
print(participants %>% select(1:5))

# use the column names and capitalization from the original dataset
# ignore missing values
averagedage <- mean(participants$age, na.rm = TRUE)
averagedHeight <- mean(participants$Height, na.rm = TRUE)
averagedWeight <- mean(participants$Weight, na.rm = TRUE)

# construct table with results
result <- data.frame(averagedage, averagedHeight, averagedWeight)
print(result)

#
write.table(result, file=outputfile, sep="\t", col.names=FALSE, row.names=FALSE)
