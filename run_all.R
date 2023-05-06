## Exploratory analysis - nPVI
rm(list = ls())
INPUTDIR <- "./output/analysis/Stage2/"
OUTPUTDIR <- "./output/figure/Stage2/"
durationID <- "20sec"

typeid <- "song-desc"
source("plot_nPVI.R")

typeid <- "song-inst"
source("plot_nPVI.R")

## Exploratory analysis - IRR
rm(list = ls())
OUTPUTDIR <-  "./output/figure/Stage2/"
source("plot_irr.R")

## Exploratory - mean feature values [Ours]
rm(list = ls())
INPUTDIR <- './output/analysis/Stage2/'
featurestatfilepath = paste(INPUTDIR, 'featurestat_20sec.csv', sep = '')
OUTPUTDIR <- './output/figure/Stage2/'
source("plot_featurestat.R")
source("plot_featurestat_MF.R")

## Exploratory - Meta-analysis [Hilton and ours]
rm(list = ls())
OUTPUTDIR <- "./output/figure/Stage2/"
source("plot_mixES.R")

## Exploratory - mean feature values [Hilton vs. ours]
rm(list = ls())
INPUTDIR <- c("./output/analysis/Stage2/Hilton/", "./output/analysis/Stage2/pyin/")
DURATION <- c("Inf", "Inf")
OUTPUTDIR <- "./output/figure/Stage2/pyin/"
source("plot_mixStats.R")

## Exploratory + confirmatory - our data with all features
rm(list = ls())
INPUTDIR <- './output/analysis/Stage2/'
OUTPUTDIR <- './output/figure/Stage2/'
durationID <- '20sec'
exploratory <- TRUE
source("plot_featureES.R")

## Exploratory analysis - Plot CIs of all combinations
rm(list = ls())
INPUTDIR <- "./output/analysis/Stage2/"
OUTPUTDIR <- "./output/figure/Stage2/"
durationID <- "20sec"
source("plot_metaCIs.R")

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

## Exploratory - our data with pYIN+Praat
rm(list = ls())
INPUTDIR <- './output/analysis/Stage2/pyin-praat/'
OUTPUTDIR <- './output/figure/Stage2/pyin-praat/'
durationID <- 'Infsec'
exploratory <- FALSE
source("plot_featureES.R")