## Library
library(ggplot2)
library(ggpubr)

## Config
inputfilepath <- paste(INPUTDIR, 'onsetqualitytable.csv', sep = "")
REFVALUENAME <- "Reference"

## ETL
T <- read.csv(inputfilepath)
idx <- (T$experiment == "With texts" | T$experiment == "Reannotation" | T$experiment == "Automated") & (T$feature == "IOI rate" | T$feature == "f0 ratio")
T <- T[idx, ]

T$comparison <- paste(T$type_m, "-", T$type_l, sep = "")

G <- T[T$experiment == "With texts" & T$datalang == T$annotatorlang, ]
G$experiment <- REFVALUENAME

T <- T[!(T$experiment == "With texts" & T$datalang == T$annotatorlang), ]
T$experiment[T$experiment == "With texts"] <- "Another annotator"

##
comparisonlist <- unique(T$comparison)
plottitle <- comparisonlist
plottitle[plottitle == "inst-desc"] <- "Instrumental vs. Spoken description"
plottitle[plottitle == "song-desc"] <- "Song vs. Spoken description"
plottitle[plottitle == "song-recit"] <- "Song vs. Lyrics recitation"

##
featurename <- c("Temporal rate", "Pitch interval size")
featurelist <- unique(T$feature)
g_list <- vector(mode = "list", length = length(featurename))

for(j in 1:length(comparisonlist)) {
  for(i in 1:length(featurelist)) {
    idx <- T$feature == featurelist[i] & T$comparison == comparisonlist[j]
    
    T_ij <- T[idx, ]
    T_ij$shape <- "Another annotation"
    T_ij$size <- 3
    G_ij <- G[G$comparison == comparisonlist[j] & G$feature == featurelist[i], ]
    G_ij$shape <- "Reference annotation"
    G_ij$size <- 4
    Q <- rbind(T_ij, G_ij)
    
    g_list[[i]] <- ggplot(data = Q, aes(x = datalang, y = p, color = experiment, shape = shape), alpha = 0.8) + geom_point(aes(size = size)) +
      labs(x = "Recording data", y = "Relative effect", title = paste(plottitle[j], "\n(", featurename[i], " - ", featurelist[i], ")", sep = ""), colour = "Pattern", shape = "Pattern") +
      guides(color = guide_legend(), shape = "none", size = "none") +
      theme(plot.title = element_text(hjust = 0.5), axis.text.x = element_text(angle = 0, size = 10), axis.text.y = element_text(size = 10)) +
      ylim(c(0, 1)) + 
      scale_size(breaks = c(3, 4), range = c(3, 4))
    
    if (i == 2) {
      g_list[[i]] <- g_list[[i]] + ylab("")
    }
  }
  
  g <- ggarrange(plotlist = g_list, ncol = 2, nrow = 1, common.legend = TRUE, legend = "right")
  ggsave(file = paste(OUTPUTDIR, "onsetquality_", comparisonlist[j], ".png", sep = ""), plot = g, width = 10, height = 6)
}