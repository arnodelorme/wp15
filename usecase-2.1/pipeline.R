# This part of the script deals with possibly missing packages on-the-fly:
# It downloads them and puts them in a tempdir + adds the tempdir to the 
# path
tdir <- tempdir()
.libPaths(tdir)

hasgetopt   <- c("getopt") %in% rownames(installed.packages())
hasoptparse <- c("optparse") %in% rownames(installed.packages())
if (hasgetopt==FALSE)   {install.packages("getopt",   lib=tdir, dependencies=FALSE, repos="https://cloud.r-project.org")}
if (hasoptparse==FALSE) {install.packages("optparse", lib=tdir, dependencies=FALSE, repos="https://cloud.r-project.org")}

# Load the required package for the option parsing
library("optparse")

option_list = list(
  make_option(c("-f", "--file"), type="character", default=NULL,
              help="input file name", metavar="character"),
  make_option(c("-o", "--out"), type="character", default="output.tsv",
              help="output file name [default= %default]", metavar="character")
);

usage = "usage: Rscript %prog -f INPUTFILE [-o OUTPUTFILE]"
opt_parser = OptionParser(usage=usage, option_list=option_list);
opt = parse_args(opt_parser);

if (is.null(opt$file)){
  print_help(opt_parser)
  stop("At least one argument must be supplied (input file).", call.=FALSE)
}

#
dataset <- opt$file

#
pinfo <- read.csv(dataset, sep="\t")

#
averagedage <- mean(pinfo$age)

#
df <- data.frame(averagedage)

print(df)

#
write.table(averagedage, file=opt$out, col.names="average_age", sep="\t", row.names=FALSE)
