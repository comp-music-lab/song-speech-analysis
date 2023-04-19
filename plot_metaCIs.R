## Library
library(ggplot2)
library(ggpubr)

##
WID <- 7
HEI <- 5

COMPARISONPATTERN <- c("inst-desc", "inst-recit", "inst-song", "song-desc", "song-recit", "recit-desc")
ANALYSISPATTERN <- c("Instrumental vs. Spoken description", "Instrumental vs. Lyrics recitation", "Instrumental vs. Song",
                     "Song vs. Spoken description", "Song vs. Lyrics recitation", "Lyrics recitation vs. spoken description")
ANALYSISPATTERN <- factor(ANALYSISPATTERN, levels = ANALYSISPATTERN)

FEATURESET_DIFF <- c("f0", "IOI rate", "-|Δf0|")
FEATURESET_SIM <- c("Spectral centroid", "f0 ratio", "Sign of f0 slope")

FEATURESET <- c(FEATURESET_DIFF, FEATURESET_SIM)
FEATURENAMESET <- c("Pitch height", "Temporal rate", "Pitch stability", "Timbral brightness", "Pitch interval size", "Pitch declination")
FIGLABEL <- c("(A) ", "(B) ", "(C) ", "(D) ", "(E) ", "(F) ")

LANGCOLORMAP <- read.csv("./data/LangColorMap.csv")
LANGCOLORMAP$rgb <- paste("#", LANGCOLORMAP$rgb, sep = "")

##
esinfo = c()

for (i in 1:length(COMPARISONPATTERN)) {
  esinfo_i <- rbind(
    read.csv(file = paste(INPUTDIR, "results_effectsize_acoustic_", COMPARISONPATTERN[i], "_", durationID, ".csv", sep = "")),
    read.csv(file = paste(INPUTDIR, "results_effectsize_seg_", COMPARISONPATTERN[i], "_", durationID, ".csv", sep = ""))
  )
  esinfo_i$analysis <- ANALYSISPATTERN[i]
  esinfo <- rbind(esinfo, esinfo_i)
}

##
CIinfo = c()
meaninfo = c()

for (i in 1:length(COMPARISONPATTERN)) {
  CI_temp <- rbind(
    read.csv(file = paste(INPUTDIR, "ma_acoustic_", COMPARISONPATTERN[i], "_20sec.csv", sep = "")),
    read.csv(file = paste(INPUTDIR, "ma_seg_", COMPARISONPATTERN[i], "_20sec.csv", sep = ""))
  )
  CI_temp$CI_u[CI_temp$feature %in% FEATURESET_DIFF] <- CI_temp$mean[CI_temp$feature %in% FEATURESET_DIFF]
  
  CIinfo_i <- rbind(data.frame(feature = CI_temp$feature, vertex = CI_temp$CI_l, type = "CI_l"),
                    data.frame(feature = CI_temp$feature, vertex = CI_temp$CI_u, type = "CI_u")
  )
  CIinfo_i$analysis <- ANALYSISPATTERN[i]
  CIinfo_i$groupID <- paste(CIinfo_i$feature, "-", CIinfo_i$analysis, sep = "")
  CIinfo = rbind(CIinfo, CIinfo_i)
  
  muinfo_i <- data.frame(feature = CI_temp$feature, vertex = CI_temp$mean, type = "mean")
  muinfo_i$analysis <- ANALYSISPATTERN[i]
  meaninfo = rbind(meaninfo, muinfo_i)
}
CIinfo$lang = ""
meaninfo$lang = ""

##
esinfo$d <- sqrt(2)*qnorm(esinfo$diff, 0, 1)
CIinfo$d <- sqrt(2)*qnorm(CIinfo$vertex, 0, 1)
meaninfo$d <- sqrt(2)*qnorm(meaninfo$vertex, 0, 1)

##
for (i in 1:length(FEATURESET)) {
  esinfo_i <- esinfo[esinfo$feature == FEATURESET[i], ]
  CIinfo_i <- CIinfo[CIinfo$feature == FEATURESET[i], ]
  meaninfo_i <- meaninfo[meaninfo$feature == FEATURESET[i], ]
  
  g <- ggplot(data = esinfo_i, aes(x = d, y = analysis, fill = lang)) + 
    geom_rect(aes(xmin = -0.4, xmax = 0.4, ymin = 0.3, ymax = length(unique(analysis)) + 0.7), fill = "#E46F80", alpha = 0.01, show.legend = FALSE) + 
    geom_violin(fill = "#FCAE1E", alpha = 0.2) + 
    geom_point(position = position_jitter(width = 0, height = 0.08), shape = 21, alpha = 0.8, size = 2, stroke = 0.5) +
    geom_vline(xintercept = 0, linetype = 2) +
    geom_vline(xintercept = 0.4, linetype = 3) +
    geom_vline(xintercept = -0.4, linetype = 3)
  
  g <- g +
    geom_line(data = CIinfo_i, aes(x = d, y = analysis, group = groupID), position = position_nudge(y = 0.25), show.legend = FALSE) +
    geom_point(data = CIinfo_i, aes(x = d, y = analysis), shape = "|", size = 4, position = position_nudge(y = 0.25), show.legend = FALSE) +
    geom_point(data = meaninfo_i, aes(x = d, y = analysis), shape = 23, size = 3, fill = "#d7003a", position = position_nudge(y = 0.25), show.legend = FALSE)
  
  g <- g + 
    guides(fill = "none", colour = "none") +
    scale_fill_manual(values = LANGCOLORMAP$rgb, breaks = LANGCOLORMAP$lang_filename) + 
    scale_y_discrete(limits = rev(ANALYSISPATTERN)) +
    theme(axis.title.y = element_blank()) +
    xlab("Translated Cohen's D") + 
    ggtitle(paste(FIGLABEL[i], FEATURENAMESET[i], sep = "")) +
    theme(plot.title = element_text(size = 18, face = "bold", hjust = 0.5), axis.title.x = element_text(size = 16), axis.text = element_text(size = 15))
    
  ggsave(file = paste(OUTPUTDIR, "AllCombinations_", FEATURENAMESET[i], ".png", sep = ""), plot = g, width = WID, height = HEI)
}