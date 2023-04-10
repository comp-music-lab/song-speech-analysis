## Exploratory - our data with pYIN+Praat
rm(list = ls())
INPUTDIR <- './output/analysis/Stage2/pyin-praat/'
OUTPUTDIR <- './output/figure/Stage2/pyin-praat/'
durationID <- 'Infsec'
exploratory <- FALSE
source("plot_featureES.R")

## Exploratory - our data (subset) with pYIN
rm(list = ls())
INPUTDIR <- './output/analysis/Stage2/pyin-subset/'
OUTPUTDIR <- './output/figure/Stage2/pyin-subset/'
durationID <- 'Infsec'
exploratory <- FALSE
source("plot_featureES.R")

## Exploratory - Hilton's data with pYIN
rm(list = ls())
INPUTDIR <- './output/analysis/Stage2/Hilton/'
OUTPUTDIR <- './output/figure/Stage2/Hilton/'
durationID <- 'Infsec'
exploratory <- FALSE
source("plot_featureES.R")

## Exploratory - our data with pYIN
rm(list = ls())
INPUTDIR <- './output/analysis/Stage2/pyin/'
OUTPUTDIR <- './output/figure/Stage2/pyin/'
durationID <- 'Infsec'
exploratory <- FALSE
source("plot_featureES.R")

## Exploratory - our data with all features
rm(list = ls())
INPUTDIR <- './output/analysis/Stage2/'
OUTPUTDIR <- './output/figure/Stage2/'
durationID <- '20sec'
exploratory <- TRUE
source("plot_featureES.R")

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
INPUTDIR <- "./output/analysis/Stage2/"
OUTPUTDIR <- "./output/figure/Stage2/"
durationID <- "20sec"
exploratory <- FALSE
source("plot_metaCIs.R")

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