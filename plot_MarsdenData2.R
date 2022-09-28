## Library
library(ggplot2)
library(ggpubr)

## Constants
CORE_FEATURE = c('IOI rate', 'f0', 'Sign of f0 slope', 'Spectral centroid', 'f0 ratio')
TITLESTR <- c('Instrumental vs. Spoken description', 'Song vs. Spoken description', 'Song vs. Lyrics recitation')
DATATYPE <- c('inst-desc', 'song-desc', 'song-recit')
OUTPUTDIR <- './output/20220918/'
G_WID <- 7.5
G_HEI <- 6

##Specify data download location
file.data <- paste('./output/20220918/results_Marsden-all_', DATATYPE, '_Infsec.csv', sep = '')

data_all <- c()
for (i in 1:length(DATATYPE)) {
  data_i <- read.csv(file = file.data[i])
  data_i$Comparison <- TITLESTR[i]
  data_all <- rbind(data_all, data_i)
}

file.data <- paste('./output/20220918/results_Marsden-complete_', DATATYPE, '_Infsec.csv', sep = '')

data_complete <- c()
for (i in 1:length(DATATYPE)) {
  data_i <- read.csv(file = file.data[i])
  data_i$Comparison <- TITLESTR[i]
  data_complete <- rbind(data_complete, data_i)
}

data <- rbind(data_all, data_complete)

# ELT
data$diff[data$diff == 1 & !is.nan(data$diff)] <- 1 - 3e-3
data$d <- sqrt(2)*qnorm(data$diff, 0, 1) #convert common language effect size to Cohen's d
data <- subset(data, method=="common language effect size") #restrict to only effect size data

data$feature[data$feature == "F0"] <- "f0"
data$feature[data$feature == "Energy"] <- "Short-term energy"
data$feature[data$feature == "Magnitude of F0 modulatioin"] <- "Rate of change of f0"
data$feature[data$feature == "Interval deviation"] <- "Pitch ratio deviation"
data$feature[data$feature == "Pitch range"] <- "90% f0 quantile length"
data$feature[data$feature == "Interval range"] <- "f0 ratio"
data$feature[data$feature == "Pitch declination"] <- "Sign of f0 slope"

LIST_FEATURE <- c('IOI rate', '90% f0 quantile length', 'Short-term energy', 'IOI ratio deviation', 'f0', 'Sign of f0 slope', 'Onset-break interval', 'Pitch ratio deviation', 'Rate of change of f0', 'f0 ratio', 'Spectral centroid', 'Pulse clarity')
CONCEPT_NAME <- c('Syllable/note rate', 'Pitch range', 'Loudness', 'Rhythmic regularity', 'Pitch height', 'Pitch declination', 'Phrase length', 'Interval regularity', 'Pitch discreteness', 'Pitch interval size', 'Timbre brightness', 'Pulse clarity')

data$featureplotname <- ""
for (i in 1:length(LIST_FEATURE)) {
  data$featureplotname[data$feature == LIST_FEATURE[i]] <- paste(CONCEPT_NAME[i], "\n(", LIST_FEATURE[i], ")", sep = "")  
}

## Extract core features
idx = 0
for (i in 1:length(CORE_FEATURE)) {
  idx <- idx | data$feature == CORE_FEATURE[i]
}

data <- data[idx, ]

## ggplot
LIST_COMPARISON <- unique(data$Comparison)
g_list <- vector(mode = "list", length = length(LIST_COMPARISON))

magnitude <- aggregate(d ~ featureplotname, data = data[data$Comparison == "Song vs. Spoken description", ], median)
idx <- sort(magnitude$d, decreasing = FALSE, index=T)$ix
ORDER_Y_AXIS <- as.factor(magnitude[idx, 1])

for (i in 1:length(g_list)) {
  g_list[[i]] <- ggplot(data[data$Comparison == LIST_COMPARISON[i], ], aes(x = d, y = featureplotname, fill = lang)) + 
    geom_dotplot(binaxis = 'y', stackdir = 'center', position = "dodge", alpha = 0.8) +
    geom_vline(xintercept = 0, linetype = 2) +
    geom_vline(xintercept = 0.4, linetype = 3) +
    geom_vline(xintercept = -0.4, linetype = 3) +
    theme(axis.title.y = element_blank()) +
    xlab("Translated Cohen's D") + 
    scale_y_discrete(limits = ORDER_Y_AXIS) +
    ggtitle(LIST_COMPARISON[i]) +
    theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5)) +
    theme(axis.text.x = element_text(size = 10)) + 
    xlim(c(-1.8, 5.0)) + 
    scale_x_continuous(breaks = c(-2, -1, -0.4, 0, 0.4, 1, 2, 3, 4)) + 
    theme(legend.title = element_blank())
  
  ggsave(file = paste(OUTPUTDIR, "MarsdenData_", LIST_COMPARISON[i], ".png", sep = ""), plot = g_list[[i]], width = G_WID, height = G_HEI)
}