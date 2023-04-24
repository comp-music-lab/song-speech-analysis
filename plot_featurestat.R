## Library
library(ggplot2)
library(ggpubr)

## Config
FEATURENAME <- c("-|Δf0|" = "Pitch stability", "90% f0 quantile length" = "Pitch range", "f0" = "Pitch height",
            "f0 ratio" = "Pitch interval size", "f0 ratio deviation" = "Interval regularity", "IOI rate" = "Temporal rate",
            "IOI ratio deviation" = "Rhythmic regularity", "Onset-break interval" = "Phrase length", "Pulse clarity" = "Pulse clarity",
            "Short-term energy" = "Loudness", "Sign of f0 slope" = "Pitch declination", "Spectral centroid" = "Timbral brightness",    
            "Spectral flatness" = "Timbral noisiness")
FEATUREUNIT <- c("-|Δf0|" = "Cent/sec.", "90% f0 quantile length" = "Cent", "f0" = "Cent",
                 "f0 ratio" = "Cent", "f0 ratio deviation" = "Cent", "IOI rate" = "Hz",
                 "IOI ratio deviation" = "-", "Onset-break interval" = "Sec.", "Pulse clarity" = "-",
                 "Short-term energy" = "-", "Sign of f0 slope" = "-", "Spectral centroid" = "Hz",    
                 "Spectral flatness" = "-")
FEATUREORDER <- c("f0" = 1, "IOI rate" = 2, "-|Δf0|" = 3, "Spectral centroid" = 4,
                  "f0 ratio" = 5, "Sign of f0 slope" = 6, "Onset-break interval" = 7,
                  "Short-term energy" = 8, "Spectral flatness" = 9, "IOI ratio deviation" = 10,
                  "f0 ratio deviation" = 11, "Pulse clarity" = 12, "90% f0 quantile length" = 13)

XLABEL <- c("desc" = "Desc.", "song" = "Song", "recit" = "Recit.", "inst" = "Inst.")
XLIMIT <- c("inst", "song", "recit", "desc")

LANGCOLORMAP <- read.csv("./data/LangColorMap.csv")
LANGCOLORMAP$rgb <- paste("#", LANGCOLORMAP$rgb, sep = "")

NCOL <- 3
WID <- 8
HEI <- 6
FILEID_TYPE <- "isrd"
FILEID_FEATURE <- "full"
SEX <- "MF"

if (!FULLFEATURE) {
  FILEID_FEATURE <- "main"
}

if (!FULLTYPE) {
  FILEID_TYPE <- "sd"
}

## ETL
featurestatinfo <- read.csv(featurestatfilepath)

## Plot
featureset <- sort(unique(featurestatinfo$feature))
g_list <- vector(mode = "list", length = length(featureset))

for (i in 1:length(featureset)) {
  featurestatinfo_i <- featurestatinfo[featurestatinfo$feature == featureset[i], ]
  ylabel <- paste("Mean ", sub("δ", "Δ", sub("ioi", "IOI", tolower(featureset[i]))), "\n[", FEATUREUNIT[i], "]", sep = "")
  
  g <- ggplot(data = featurestatinfo_i, aes(x = type, y = mean, color = lang)) + 
    geom_violin(aes(group = type)) +
    geom_point(aes(shape = sex)) +
    geom_line(aes(group = groupid), linetype = "dotdash") +
    geom_violin(aes(group = type), alpha = 0, draw_quantiles = 0.5) +
    ggtitle(FEATURENAME[featureset[i]]) + 
    xlab("") +
    ylab(ylabel) +
    guides(color = "none", shape = "none") + 
    theme(plot.title = element_text(size = 9, face = "bold", hjust = 0.5),
          axis.text = element_text(size = 6),
          axis.title = element_text(size = 7)) + 
    scale_x_discrete(limits = XLIMIT, label = XLABEL) +
    scale_color_manual(values = LANGCOLORMAP$rgb, breaks = LANGCOLORMAP$lang_filename) + 
    scale_shape_manual(breaks = c("F", "M"), values = c(16, 17))
  
  if (featureset[i] == "f0 ratio deviation" || featureset[i] == "IOI ratio deviation") {
    g <- g + scale_y_reverse()
  }
  
  if(featureset[i] == "Onset-break interval" || featureset[i] == "Short-term energy" || featureset[i] == "Spectral flatness") {
    g <- g + scale_y_log10() 
  }
  
  g_list[[FEATUREORDER[featureset[i]]]] <- g
}

## Combine plots
g <- ggarrange(plotlist = g_list, ncol = NCOL, nrow = ceiling(length(featureset)/NCOL), common.legend = FALSE)

## Save
ggsave(file = paste(OUTPUTDIR, "featurestat_", FILEID_TYPE, "_", FILEID_FEATURE, "_", SEX, ".png", sep = ""),
       plot = g, width = WID, height = HEI)