## Library
library(ggplot2)
library(ggpubr)
library(clinfun)

## Config
FEATURENAME <- c("-|Δf0|" = "Pitch stability", "90% f0 quantile length" = "Pitch range", "f0" = "Pitch height",
            "f0 ratio" = "Pitch interval size", "f0 ratio deviation" = "Pitch interval regularity", "IOI rate" = "Temporal rate",
            "IOI ratio deviation" = "Rhythmic regularity", "Onset-break interval" = "Phrase length", "Pulse clarity" = "Pulse clarity",
            "Short-term energy" = "Intensity", "Sign of f0 slope" = "Pitch declination", "Spectral centroid" = "Timbral brightness",    
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
ALTERNATIVE <- c("f0" = "decreasing", "IOI rate" = "increasing", "-|Δf0|" = "decreasing", "Spectral centroid" = "increasing",
                 "f0 ratio" = "decreasing", "Sign of f0 slope" = "decreasing", "Onset-break interval" = "decreasing",
                 "Short-term energy" = "decreasing", "Spectral flatness" = "increasing", "IOI ratio deviation" = "increasing",
                 "f0 ratio deviation" = "increasing", "Pulse clarity" = "decreasing", "90% f0 quantile length" = "decreasing")
                 
XLABEL <- c("desc" = "Desc.", "song" = "Song", "recit" = "Recit.", "inst" = "Inst.")
XLIMIT <- c("inst", "song", "recit", "desc")

LANGCOLORMAP <- read.csv("./data/LangColorMap.csv")
LANGCOLORMAP$rgb <- paste("#", LANGCOLORMAP$rgb, sep = "")

NCOL <- 3
WID <- 8
HEI <- 6

## ETL
featurestatinfo <- read.csv(featurestatfilepath)
featurestatinfo$type <- factor(featurestatinfo$type, levels = c("inst", "song", "recit", "desc"))

## Plot
featureset <- sort(unique(featurestatinfo$feature))
g_list <- vector(mode = "list", length = length(featureset))
linearcontrasttest <- c()

for (i in 1:length(featureset)) {
  featurestatinfo_i <- featurestatinfo[featurestatinfo$feature == featureset[i], ]
  ylabel <- paste("Mean ", sub("δ", "Δ", sub("ioi", "IOI", tolower(featureset[i]))), "\n[", FEATUREUNIT[i], "]", sep = "")
  
  ## Linear contrast analysis
  result <- jonckheere.test(featurestatinfo_i$mean, as.numeric(featurestatinfo_i$type), alternative = ALTERNATIVE[featureset[i]], nperm = 8192)
  linearcontrasttest <- rbind(linearcontrasttest, data.frame(feature = featureset[i],
                                                             alternative = result$alternative, JT = result$statistic, pvalue = result$p.value
  )
  )
  
  ## ggplot
  g <- ggplot(data = featurestatinfo_i, aes(x = type, y = mean, color = lang)) + 
    geom_violin(aes(group = type)) +
    geom_point(aes(shape = sex)) +
    geom_line(aes(group = groupid), linetype = "dotdash") +
    geom_violin(aes(group = type), alpha = 0, draw_quantiles = 0.5) +
    ggtitle(FEATURENAME[featureset[i]]) + 
    xlab("") +
    ylab(ylabel) +
    guides(color = "none", shape = "none") + 
    theme_gray() +
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
ggsave(file = paste(OUTPUTDIR, "featurestat.png", sep = ""),
       plot = g, width = WID, height = HEI)

print(linearcontrasttest)
write.table(linearcontrasttest, file = paste(OUTPUTDIR, "featurestat_lctest.csv", sep = ""), row.names = FALSE, sep = ",")



########################## graveyard ##########################
#options(contrasts = c("contr.sum", "contr.poly")) # Important! Set sum-to-zero contrasts
#df.aov <- aov(mean ~ type, data = featurestatinfo_i)
#sm <- summary(df.aov, split = list(type = list(linear=1, quadratic=2, cubic=3)))
#linearcontrasttest <- rbind(linearcontrasttest,
#                            data.frame(feature = featureset[i],
#                                       DF_om = sm[[1]]$Df[1], Favlue_om = sm[[1]]$`F value`[1], pvalue_om = sm[[1]]$`Pr(>F)`[1],
#                                       DF_lc = sm[[1]]$Df["linear"], Fvalue_lc = sm[[1]]$`F value`["linear"], pvalue_lc = sm[[1]]$`Pr(>F)`["linear"])
#                            )
#g <- g + ggtitle(paste(FEATURENAME[featureset[i]], " (p = ", format(result$p.value, digits = 2), ")", sep = "")) 