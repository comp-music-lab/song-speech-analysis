## Library
library(ggplot2)
library(ggpubr)

## Config
inputfilepath <- './output/20220918/onsetqualitytable.csv'  
outputdir <- './output/20220918/'
REFVALUENAME <- "Reference"

## ETL
T = read.csv(inputfilepath)
T$comparison <- paste(T$type_m, "-", T$type_l, sep = "")
T$annotatorlang[T$annotatorlang == "n/a"] <- "n/a (automated method)"

G <- T[T$experiment == "With texts" & T$datalang == T$annotatorlang, ]
G$annotatorlang <- REFVALUENAME

DUMMY <- data.frame(datalang = rep(unique(T$datalang)[1], 6), p = rep(0, 6), annotatorlang = c(unique(T$annotatorlang, REFVALUENAME)))

##
annotatorlanglist <- unique(T$annotatorlang)
hues <- seq(15, 375, length = length(annotatorlanglist) + 1)
colorcode <- hcl(h = hues, l = 65, c = 100)[1:length(annotatorlanglist)]
colorcode <- c(colorcode, "#777777")

##
comparisonlist <- unique(T$comparison)
plottitle <- comparisonlist
plottitle[plottitle == "inst-desc"] <- "Instrumental vs. Spoken description"
plottitle[plottitle == "song-desc"] <- "Song vs. Spoken description"
plottitle[plottitle == "song-recit"] <- "Song vs. Lyrics recitation"

##
featurelist <- unique(T$feature)
experimentlist <- unique(T$experiment)
experimentlist <- c(experimentlist[1:2], "DUMMY", experimentlist[3:5])
g_list <- vector(mode = "list", length = length(experimentlist))

for (k in 1:length(featurelist)) {
  for (j in 1:length(comparisonlist)) {
    for (i in 1:length(experimentlist)) {
      if (experimentlist[i] != "DUMMY") {
        idx <- T$experiment == experimentlist[i] & T$comparison == comparisonlist[j] & T$feature == featurelist[k]
        langlist_ij <- unique(T[idx, ]$datalang)
        
        g_list[[i]] <- ggplot() + 
          geom_point(data = T[idx, ], aes(x = datalang, y = p, color = annotatorlang), alpha = 0.8, size = 3) +
          geom_point(data = G[G$comparison == comparisonlist[j] & G$datalang %in% langlist_ij & G$feature == featurelist[k], ], aes(x = datalang, y = p, color = annotatorlang), alpha = 0.6, size = 2) +
          geom_point(data = DUMMY, aes(x = datalang, y = p, color = annotatorlang), alpha = 0) + 
          labs(x = "", y = "", title = experimentlist[i], color = "Annotator") +
          theme(plot.title = element_text(hjust = 0.5), axis.text.x = element_text(angle = 18, size = 10), axis.text.y = element_text(size = 10)) +
          ylim(c(0, 1)) + 
          scale_color_manual(values = colorcode, breaks = c(annotatorlanglist, REFVALUENAME))
        
        if (i == 1 || i == 4) {
          g_list[[i]] <- g_list[[i]] + ylab("Relative effect")
        }
        if (i == 4 || i == 5 || i == 6) {
          g_list[[i]] <- g_list[[i]] + xlab("Recording data")
        }
      }
    }
    
    g <- ggarrange(plotlist = g_list, ncol = 3, nrow = 2, common.legend = TRUE, legend = "right")
    g <- annotate_figure(g, top = text_grob(plottitle[j], face = "bold", size = 14))
    ggsave(file = paste(outputdir, "onsetquality_", comparisonlist[j], "_", featurelist[k], ".png", sep = ""), plot = g, width = 10, height = 6)
  }
}