##
rm(list = ls())
INPUTDIR <- './output/analysis/'
OUTPUTDIR <- './output/figure/'
exploratory <- TRUE
source("plot_featurestat.R")
exploratory <- FALSE
source("plot_featurestat.R")

##
rm(list = ls())
INPUTDIR <- './output/analysis/'
OUTPUTDIR <- './output/figure/'
source("plot_annotatoreffect.R")

##
rm(list = ls())
INPUTDIR <- './output/analysis/'
OUTPUTDIR <- './output/figure/'
exploratory <- TRUE
source("plot_featureES.R")
exploratory <- FALSE
source("plot_featureES.R")

##
rm(list = ls())
INPUTDIR <- './output/analysis/'
OUTPUTDIR <- './output/figure/'
source("plot_CollaboratorMap.R")