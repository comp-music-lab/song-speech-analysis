## Library
library(ggplot2)
library(ggpubr)

##
INPUTDIR <- c("./output/analysis/Stage2/", "./output/analysis/Stage2/pyin/",
              "./output/analysis/Stage2/subset/", "./output/analysis/Stage2/pyin-subset/",
              "./output/analysis/Stage2/Hilton-subset/", "./output/analysis/Stage2/Hilton/")
ANALYSISPATTERN <- c("Ours\n(full, SA, 20 sec.)", "Ours\n(full, FA, full length)", 
                     "Ours\n(matched, SA, 20 sec.)", "Ours\n(matched, FA, full length)",
                     "Hilton\n(matched, FA, full length)", "Hilton\n(full, FA, full length)")
ANALYSISPATTERN <- factor(ANALYSISPATTERN, levels = ANALYSISPATTERN)
DURATION <- c("20", "Inf", "20", "Inf", "Inf", "Inf")
FEATURESET <- c("f0", "-|Δf0|", "Spectral centroid")
FEATURENAMESET <- c("Pitch height", "Pitch stability", "Timbral brightness")
FIGLABEL <- c("(A) ", "(B) ", "(C) ")
FEATURESET_DIFF <- c("f0", "-|Δf0|")
FEATURESET_SIM <- c("Spectral centroid")

XL <- c(-2, 7.5)
XBREAK <- c(-1, 0, 1, 2, 3, 4, 5, 6, 7)
WID <- 7
HEI <- 5

LANGCOLORMAP <- read.csv("./data/LangColorMap.csv")
LANGCOLORMAP$rgb <- paste("#", LANGCOLORMAP$rgb, sep = "")

##
esinfo = c()

for (i in 1:length(INPUTDIR)) {
  esinfo_i <- read.csv(file = paste(INPUTDIR[i], "results_effectsize_acoustic_song-desc_", DURATION[i], "sec.csv", sep = ""))
  esinfo_i$analysis <- ANALYSISPATTERN[i]
  esinfo <- rbind(esinfo, esinfo_i)
}

##
CIinfo = c()
meaninfo = c()

for (i in 1:length(INPUTDIR)) {
  CI_temp <- read.csv(file = paste(INPUTDIR[i], "ma_acoustic_song-desc_", DURATION[i], "sec.csv", sep = ""))
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
  
  g <- g + guides(fill = "none", colour = "none") +
    theme_gray() +
    theme(axis.title.y = element_blank()) +
    xlab("Translated Cohen's D") + 
    ggtitle(paste(FIGLABEL[i], FEATURENAMESET[i], sep = "")) +
    theme(plot.title = element_text(size = 18, face = "bold", hjust = 0.5), axis.title.x = element_text(size = 16), axis.text = element_text(size = 15)) +
    scale_y_discrete(limits = rev(ANALYSISPATTERN)) + 
    scale_fill_manual(values = LANGCOLORMAP$rgb, breaks = LANGCOLORMAP$lang_filename) +
    scale_x_continuous(breaks = XBREAK, limits = XL)
  
  ggsave(file = paste(OUTPUTDIR, "AllEffectSizes_", FEATURENAMESET[i], ".png", sep = ""), plot = g, width = WID, height = HEI)
}

gl <- g + guides(fill = guide_legend("Language"))
l <- as_ggplot(get_legend(gl))
ggsave(file = paste(OUTPUTDIR, "AllEffectSizes_legend.png", sep = ""), plot = l, width = 5, height = 5)