#
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
