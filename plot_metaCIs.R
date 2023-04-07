## Library
library(ggplot2)
library(ggpubr)

## Constants
LIST_FEATURE <- c('Spectral flatness', 'IOI rate', '90% f0 quantile length', 'Short-term energy', 'IOI ratio deviation', 'f0', 'Sign of f0 slope', 'Onset-break interval', 'f0 ratio deviation', '-|Δf0|', 'f0 ratio', 'Spectral centroid', 'Pulse clarity')
CONCEPT_NAME <- c('Timbral noisiness', 'Temporal rate', 'Pitch range', 'Loudness', 'Rhythmic regularity', 'Pitch height', 'Pitch declination', 'Phrase length', 'Interval regularity', 'Pitch stability', 'Pitch interval size', 'Timbral brightness', 'Pulse clarity')
FEATURE_DIFF <- c('f0', 'IOI rate', '-|Δf0|')
FEATURE_SIM <- c('Spectral centroid', 'Sign of f0 slope', 'f0 ratio')
FEATURE_OTHER <- c('Spectral flatness', '90% f0 quantile length', 'Short-term energy', 'IOI ratio deviation', 'Onset-break interval', 'f0 ratio deviation', 'Pulse clarity')

TITLESTR <- c('Instrumental vs. Spoken description', 'Song vs. Spoken description', 'Song vs. Lyrics recitation')
DATATYPE <- c('inst-desc', 'song-desc', 'song-recit')
XL <- c(-1.8, 7.0)
XBREAK <- c(-2, -1, -0.4, 0, 0.4, 1, 2, 3, 4, 5, 6, 7, 8)
G_WID <- 15.0
G_HEI <- 6.0

if (exploratory) {
  CORE_FEATURE <- LIST_FEATURE
  FILEID <- "_exp"
} else {
  CORE_FEATURE <- c('IOI rate', 'f0', 'Sign of f0 slope', 'Spectral centroid', '-|Δf0|', 'f0 ratio')
  FILEID <- "_cnf"
}

## Load meta-analysis results
file.data <- c(
  paste(INPUTDIR, 'ma_acoustic_', DATATYPE, '_', durationID, '.csv', sep = ''),
  paste(INPUTDIR, 'ma_seg_', DATATYPE, '_', durationID, '.csv', sep = '')
)

data_ma <- c()
for (i in 1:length(file.data)) {
  if (file.exists(file.data[i])) {
    data_i <- read.csv(file = file.data[i])
    
    idx <- sapply(DATATYPE, function (x) grepl(x, file.data[i], fixed = TRUE))
    data_i$Comparison <- TITLESTR[idx]
    
    data_ma <- rbind(data_ma, data_i)
  } else {
    print(paste(file.data[i], " does not exist.", sep = ""))
  }
}

## ETL
data_ma$featureplotname <- ""
for (i in 1:length(LIST_FEATURE)) {
  plotname <- paste(CONCEPT_NAME[i], "\n(", LIST_FEATURE[i], ")", sep = "") 
  data_ma$featureplotname[data_ma$feature == LIST_FEATURE[i]] <- plotname
}

data_ma$dummyID <- 0
data_ma$lang <- ""

## Extract core features
idx_ma <- 0
for (i in 1:length(CORE_FEATURE)) {
  idx_ma <- idx_ma | data_ma$feature == CORE_FEATURE[i]
}

data_ma <- data_ma[idx_ma, ]

## ggplot
magnitude <- aggregate(mean ~ featureplotname, data = data_ma[data_ma$Comparison == "Song vs. Spoken description", ], median)
idx <- sort(magnitude$mean, decreasing = FALSE, index=T)$ix
ORDER_Y_AXIS <- as.factor(magnitude[idx, 1])

LIST_COMPARISON <- unique(data_ma$Comparison)
PNUDGE <- c(-0.25, 0, 0.25)
BARSIZE <- 3
DOTSIZE <- 3
g_list <- ggplot()

for (i in 1:length(LIST_COMPARISON)) {
  ## difference
  idx <- data_ma$feature %in% FEATURE_DIFF & data_ma$Comparison == LIST_COMPARISON[i]
  
  if (sum(idx) > 0) {
    data_i <- data_ma[idx, ]
    data_i$grp <- 1:sum(idx)
    data_i$x <- sqrt(2)*qnorm(data_i$mean, 0, 1)
    data_j <- data_ma[idx, ]
    data_j$grp <- 1:sum(idx)
    data_j$x <- sqrt(2)*qnorm(data_j$CI_l, 0, 1)
    
    g_list <- g_list + 
      geom_line(data = rbind(data_i, data_j), aes(x = x, y = featureplotname, group = grp), position = position_nudge(y = PNUDGE[i])) + 
      geom_point(data = data_ma[idx, ], aes(x = sqrt(2)*qnorm(CI_l, 0, 1), y = featureplotname), shape = "|", size = BARSIZE, position = position_nudge(y = PNUDGE[i])) +
      geom_point(data = data_ma[idx, ], aes(x = sqrt(2)*qnorm(mean, 0, 1), y = featureplotname, fill = Comparison), shape = 23, size = DOTSIZE, position = position_nudge(y = PNUDGE[i]))
  }
  
  ## similarity
  idx <- data_ma$feature %in% FEATURE_SIM & data_ma$Comparison == LIST_COMPARISON[i]
  
  if (sum(idx) > 0) {
    data_i <- data_ma[idx, ]
    data_i$grp <- 1:sum(idx)
    data_i$x <- sqrt(2)*qnorm(data_i$CI_l, 0, 1)
    data_j <- data_ma[idx, ]
    data_j$grp <- 1:sum(idx)
    data_j$x <- sqrt(2)*qnorm(data_j$CI_u, 0, 1)
    
    g_list <- g_list + 
      geom_line(data = rbind(data_i, data_j), aes(x = x, y = featureplotname, group = grp), position = position_nudge(y = PNUDGE[i])) + 
      geom_point(data = data_ma[idx, ], aes(x = sqrt(2)*qnorm(mean, 0, 1), y = featureplotname, fill = Comparison), shape = 23,  size = DOTSIZE, position = position_nudge(y = PNUDGE[i])) +
      geom_point(data = rbind(data_i, data_j), aes(x = x, y = featureplotname), shape = "|", size = BARSIZE, position = position_nudge(y = PNUDGE[i]))
  }
}

g_list <- g_list + 
  geom_rect(data = data_ma, aes(xmin = -0.4, xmax = 0.4, ymin = 0.3, ymax = length(unique(featureplotname)) + 0.7), fill = "#E46F80", alpha = 0.01, show.legend = FALSE) + 
  geom_vline(xintercept = 0, linetype = 2) +
  geom_vline(xintercept = 0.4, linetype = 3) +
  geom_vline(xintercept = -0.4, linetype = 3)

g_list <- g_list + 
  theme(axis.title.y = element_blank(), legend.position = "bottom", legend.title = element_blank(), legend.text = element_text(size = 14)) +
  ggtitle("Confidence intervals of each type of comparison") + theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5)) +
  xlab("Translated Cohen's D") + 
  scale_y_discrete(limits = ORDER_Y_AXIS) + 
  scale_x_continuous(breaks = XBREAK, limits = XL)

ggsave(file = paste(OUTPUTDIR, "CIs", FILEID, ".png", sep = ""), plot = g_list, width = G_WID, height = G_HEI)