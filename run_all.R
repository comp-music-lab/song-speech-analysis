##
rm(list = ls())
INPUTDIR <- './output/analysis/Stage2/'
OUTPUTDIR <- './output/figure/Stage2/'
exploratory <- FALSE
featurestatfilepath = paste(INPUTDIR, 'featurestat_20sec.csv', sep = '')
source("plot_featurestat.R")

##
rm(list = ls())
INPUTDIR <- './output/analysis/Stage2/'
OUTPUTDIR <- './output/figure/Stage2/'
durationID <- '20sec'
exploratory <- FALSE
source("plot_featureES.R")

##
rm(list = ls())
INPUTDIR <- './output/analysis/'
OUTPUTDIR <- './output/figure/'
source("plot_CollaboratorMap.R")