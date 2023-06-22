##
library(ggplot2)
library(RColorBrewer)

##
WID = 7
HEI = 4

MODELNAME <- c("SVM", "LRM", "BNB")
MODELORDER <- c("SVM" = 2, "LRM" = 1, "BNB" = 3)
MODELNAME_PLOT <- c("SVM" = "SVM", "LRM" = "Logistic regression", "BNB" = "Naive Bayes")

FEATURENAME_L <- c('Spectral flatness', 'IOI rate', '90% f0 quantile length', 'Short-term energy', 'IOI ratio deviation', 'f0', 'Sign of f0 slope', 'Onset-break interval', 'f0 ratio deviation', '-|Δf0|', 'f0 ratio', 'Spectral centroid', 'Pulse clarity')
FEATURENAME_H <- c('Timbral noisiness', 'Temporal rate', 'Pitch range', 'Intensity', 'Rhythmic regularity', 'Pitch height', 'Pitch declination', 'Breath duration', 'Pitch interval regularity', 'Pitch stability', 'Pitch interval size', 'Timbral brightness', 'Pulse clarity')
FEATUREORDER <- c("f0" = 1, "IOI rate" = 2, "-|Δf0|" = 3, "Spectral centroid" = 4,
                  "f0 ratio" = 5, "Sign of f0 slope" = 6, "Onset-break interval" = 7,
                  "Short-term energy" = 8, "Spectral flatness" = 9, "IOI ratio deviation" = 10,
                  "f0 ratio deviation" = 11, "Pulse clarity" = 12, "90% f0 quantile length" = 13)

DATATYPE <- c("desc", "song")
PLOTTITLE <- c("desc" = "Spoken description", "song" = "Song")

##
inputfilepath <- paste(INPUTDIR, "PermutationImportance_", MODELNAME, ".csv", sep = "")

PIinfo <- c()
for (i in 1:length(inputfilepath)) {
  PIinfo_i <- read.csv(inputfilepath[i])
  PIinfo_i$Model <- MODELNAME_PLOT[MODELNAME[i]]
  PIinfo <- rbind(PIinfo, PIinfo_i)
}

PIinfo$Model <- factor(PIinfo$Model, levels = MODELNAME_PLOT[MODELNAME[MODELORDER]])

##
idx_order <- order(FEATUREORDER[FEATURENAME_L], decreasing = TRUE)

g <- ggplot(data = PIinfo, aes(x = feature, y = pmi, fill = Model)) + 
  geom_bar(stat = "identity", position = position_dodge(width = 0.7), width = 0.6) + 
  theme_gray() +
  ylab("Permutation importance") + xlab("") + labs(fill = "") + ggtitle("Importance of features in song-speech classification task") +
  scale_x_discrete(breaks = FEATURENAME_L, labels = FEATURENAME_H, limits = FEATURENAME_L[idx_order]) + 
  coord_flip() + 
  theme(legend.position = "bottom")

ggsave(paste(OUTPUTDIR, "PI.png", sep = ""), plot = g, width = WID, height = HEI)

##
for (k in 1:length(DATATYPE)) {
  C <- read.csv(paste(INPUTDIR, "Correlationmat_", DATATYPE[k], ".csv", sep = ""), header = FALSE)
  
  df_C <- data.frame()
  for (i in 1:length(FEATURENAME_L)) {
    for (j in 1:length(FEATURENAME_L)) {
      df_ij = data.frame(feature_x = names(FEATUREORDER[j]), feature_y = names(FEATUREORDER[i]), r = C[i, j])
      df_C = rbind(df_C, df_ij)
    }
  }
  
  df_C$feature_x <- factor(df_C$feature_x, levels = names(FEATUREORDER))
  df_C$feature_y <- factor(df_C$feature_y, levels = rev(names(FEATUREORDER)))
  
  g <- ggplot(data = df_C, aes(x = feature_x, y = feature_y, fill = r)) + 
    geom_tile() + 
    geom_text(aes(label = sprintf("%2.2f", r)), size = 2) + 
    xlab("") + ylab("") + ggtitle(paste("Correlation matrix of featurs (", PLOTTITLE[DATATYPE[k]], ")", sep = "")) +
    theme(plot.title = element_text(face = "bold", hjust = 0.5)) +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
    scale_fill_gradientn("r", colours = rev(brewer.pal(9, "Spectral")), na.value = "white", limits = c(-1, 1)) +
    theme(panel.background = element_blank(), panel.grid = element_blank()) +
    scale_x_discrete(breaks = FEATURENAME_L, labels = FEATURENAME_H) + 
    scale_y_discrete(breaks = FEATURENAME_L, labels = FEATURENAME_H)
  
  ggsave(paste(OUTPUTDIR, "Corrmat_", DATATYPE[k], ".png", sep = ""), plot = g, width = 6, height = 4)
}