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
INPUTDIR <- './output/analysis/Stage2/'
OUTPUTDIR <- './output/figure/Stage2/'
durationID <- '20sec'
exploratory <- FALSE
source("analysis_multilevelAIC.R")

##
rm(list = ls())
collaboratorinfofile <- './data/CollaboratorsPlotData.csv'
OUTPUTDIR <- './output/figure/Stage2/'
source("plot_CollaboratorMap.R")

##
rm(list = ls())
INPUTDIR <- './output/analysis/Stage2/'
OUTPUTDIR <- './output/figure/Stage2/'
exploratory <- TRUE
featurestatfilepath = paste(INPUTDIR, 'featurestat_20sec.csv', sep = '')
source("plot_featurestat.R")