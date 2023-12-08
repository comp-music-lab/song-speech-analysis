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

XLABEL <- c("desc" = "Spoken\ndescription", "song" = "Song", "recit" = "Lyrics\nrecitation", "inst" = "Instrumental")
XLIMIT <- c("inst", "song", "recit", "desc")

LANGCOLORMAP <- read.csv("./data/LangColorMap.csv")
LANGCOLORMAP$rgb <- paste("#", LANGCOLORMAP$rgb, sep = "")

WID <- 10
HEI <- 6

FEATUREFILTER <- c("f0", "IOI rate", "-|Δf0|", "Spectral centroid", "f0 ratio", "Sign of f0 slope")

## ETL
featurestatinfo <- read.csv(featurestatfilepath)
featurestatinfo <- featurestatinfo[featurestatinfo$feature %in% FEATUREFILTER, ]

## Plot
featureset <- sort(unique(featurestatinfo$feature))
g_list <- vector(mode = "list", length = length(featureset))

g_mf <- vector(mode = "list", length = 2)
FEATUREORDER <- FEATUREORDER[FEATUREFILTER]
FEATUREORDER[1:length(FEATUREORDER)] <- 1:length(FEATUREORDER)

for (i in 1:length(featureset)) {
  ylabel <- paste("Mean ", sub("δ", "Δ", sub("ioi", "IOI", tolower(featureset[i]))), "\n[", FEATUREUNIT[i], "]", sep = "")
  
  for (j in 1:2) {
    if (j == 1) {
      featurestatinfo_i <- featurestatinfo[featurestatinfo$feature == featureset[i] & featurestatinfo$sex == "M", ]
      titlestr <- "Male"
    } else if (j == 2) {
      featurestatinfo_i <- featurestatinfo[featurestatinfo$feature == featureset[i] & featurestatinfo$sex == "F", ]
      titlestr <- "Female"
    }
    
    g <- ggplot(data = featurestatinfo_i, aes(x = type, y = mean, color = lang)) + 
      geom_violin(aes(group = type)) +
      geom_point(aes(shape = sex)) +
      geom_line(aes(group = groupid), linetype = "dotdash") +
      geom_violin(aes(group = type), alpha = 0, draw_quantiles = 0.5) +
      ggtitle(titlestr) + 
      xlab("") +
      ylab("") +
      guides(color = "none", shape = "none") + 
      theme_gray() +
      theme(plot.title = element_text(size = 10, face = "bold", hjust = 0.5),
            axis.text.x = element_text(size = 7, angle = -90, vjust = 0.5),
            axis.text.y = element_text(size = 7),
            axis.title = element_text(size = 9)) + 
      scale_x_discrete(limits = XLIMIT, label = XLABEL) +
      scale_color_manual(values = LANGCOLORMAP$rgb, breaks = LANGCOLORMAP$lang_filename) + 
      scale_shape_manual(breaks = c("F", "M"), values = c(16, 17))
    
    if (featureset[i] == "f0 ratio deviation" || featureset[i] == "IOI ratio deviation") {
      g <- g + scale_y_reverse()
    }
    
    if(featureset[i] == "Onset-break interval" || featureset[i] == "Short-term energy" || featureset[i] == "Spectral flatness") {
      g <- g + scale_y_log10() 
    }
    
    g_mf[[j]] <- g
  }
  
  YL_m <- layer_scales(g_mf[[1]])$y$range$range
  YL_f <- layer_scales(g_mf[[2]])$y$range$range
  YL <- c(min(YL_m[1], YL_f[1]), max(YL_m[2], YL_f[2]))
  g_mf[[1]] <- g_mf[[1]] + ylim(YL)
  g_mf[[2]] <- g_mf[[2]] + ylim(YL)
  
  g <- ggarrange(plotlist = g_mf, ncol = 2, nrow = 1, common.legend = FALSE)
  g <- annotate_figure(g, left = text_grob(ylabel, rot = 90, vjust = 1, size = 10),
                       top = text_grob(FEATURENAME[featureset[i]], face = "bold", size = 12))
  
  g_list[[FEATUREORDER[featureset[i]]]] <- g
}

## Combine plots
g <- ggarrange(plotlist = g_list, ncol = 3, nrow = 2, common.legend = FALSE)

## Save
ggsave(file = paste(OUTPUTDIR, "featurestat_FM.png", sep = ""),
       plot = g, width = WID, height = HEI)