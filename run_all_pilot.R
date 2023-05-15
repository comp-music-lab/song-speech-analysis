##
rm(list = ls())
INPUTDIR <- './output/analysis/Stage1/'
OUTPUTDIR <- './output/figure/Stage1/'
exploratory <- TRUE
source("plot_featureES_pilot.R")
exploratory <- FALSE
source("plot_featureES_pilot.R")

##
rm(list = ls())
INPUTDIR <- './output/analysis/Stage1/'
OUTPUTDIR <- './output/figure/Stage1/'
exploratory <- TRUE
source("plot_featurestat_pilot.R")
exploratory <- FALSE
source("plot_featurestat_pilot.R")

##
rm(list = ls())
INPUTDIR <- './output/analysis/Stage1/'
OUTPUTDIR <- './output/figure/Stage1/'
source("plot_annotatoreffect.R")

##
rm(list = ls())
OUTPUTDIR <- './output/figure/Stage1/'
collaboratorinfofile <- './data/CollaboratorsPlotData.csv'
exclusion <- c()
fileid <- "full"
source("plot_CollaboratorMap.R")