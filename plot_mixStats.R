##
library(ggplot2)

##
WID <- 4
HEI <- 3

ANALYSISPATTERN <- c("Hilton\n(pYIN, full length)", "Ours\n(pYIN, full length)")

FEATURESET <- c("f0", "-|Δf0|", "Spectral centroid")
FEATURESETLABEL <- c("Pitch height", "Pitch stability", "Timbral brightness")
FEATUREUNITDESC <- c("(Mean f0 [Cent (440 Hz = 0)])", "(Mean -|Δf0| [Cent/sec.])", "(Mean spectral centroid [Hz])")
DATATYPE <- c("desc", "song")
DATATYPELABEL <- c("Spoken description", "Song")
SEXLABEL <- c("Female", "Male")
SHAPETYPE <- c(16, 17)

LANGCOLORMAP <- read.csv("./data/LangColorMap.csv")
LANGCOLORMAP$rgb <- paste("#", LANGCOLORMAP$rgb, sep = "")

##
statsinfo <- c()
for (i in 1:length(INPUTDIR)) {
  statsinfo_i <- read.csv(paste(INPUTDIR[i], "featurestat_", DURATION[i], "sec.csv", sep = ""))
  statsinfo_i$analysis <- ANALYSISPATTERN[i]
  statsinfo <- rbind(statsinfo, statsinfo_i)
}

##
YL <- list(
  c(min(statsinfo$mean[statsinfo$feature == "f0"]), max(statsinfo$mean[statsinfo$feature == "f0"])),
  c(min(statsinfo$mean[statsinfo$feature == "-|Δf0|"]), 0),
  c(0, max(statsinfo$mean[statsinfo$feature == "Spectral centroid"]))
)

SEX <- sort(unique(statsinfo$sex))

for (j in 1:length(FEATURESET)) {
  for (k in 1:length(DATATYPE)) {
    for (i in 1:length(SEX)) {
      statsinfo_i <- statsinfo[statsinfo$feature == FEATURESET[j] & statsinfo$sex == SEX[i] & statsinfo$type == DATATYPE[k], ]
      
      g <- ggplot(data = statsinfo_i, aes(x = analysis, y = mean, color = lang, group = analysis)) + 
        geom_violin(draw_quantiles = 0.5) +
        geom_point(position = position_jitter(width = 0.05, height = 0), shape = SHAPETYPE[i]) + 
        ggtitle(paste(DATATYPELABEL[k], " (", SEXLABEL[i], ")", sep = "")) +
        ylab(paste(FEATURESETLABEL[j], "\n", FEATUREUNITDESC[j], sep = "")) +
        theme_gray() +
        theme(axis.title.x = element_blank(), plot.title = element_text(face = "bold", hjust = 0.5)) + 
        guides(color = "none", shape = "none") + 
        ylim(YL[[j]]) +
        scale_color_manual(values = LANGCOLORMAP$rgb, breaks = LANGCOLORMAP$lang_filename)
      
      ggsave(file = paste(OUTPUTDIR, "Stats (ours vs Hilton)_", SEX[i], "_", FEATURESETLABEL[j], "_", DATATYPE[k], ".png", sep = ""),
             plot = g, width = WID, height = HEI)
    }
  }
}