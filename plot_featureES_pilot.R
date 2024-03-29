## Library
library(ggplot2)
library(ggpubr)

## Constants
LIST_FEATURE <- c('Spectral flatness', 'IOI rate', '90% f0 quantile length', 'Short-term energy', 'IOI ratio deviation', 'f0', 'Sign of f0 slope', 'Onset-break interval', 'f0 ratio deviation', 'Rate of change of f0', 'f0 ratio', 'Spectral centroid', 'Pulse clarity')
CONCEPT_NAME <- c('Timbral noisiness', 'Temporal rate', 'Pitch range', 'Loudness', 'Rhythmic regularity', 'Pitch height', 'Pitch declination', 'Phrase length', 'Interval regularity', 'Pitch stability', 'Pitch interval size', 'Timbral brightness', 'Pulse clarity')
FEATURE_DIFF <- c('f0', 'IOI rate', 'Rate of change of f0')
FEATURE_SIM <- c('Spectral centroid', 'Sign of f0 slope', 'f0 ratio')
FEATURE_OTHER <- c('Spectral flatness', '90% f0 quantile length', 'Short-term energy', 'IOI ratio deviation', 'Onset-break interval', 'f0 ratio deviation', 'Pulse clarity')

if (exploratory) {
  CORE_FEATURE <- c('IOI rate', 'f0', 'Sign of f0 slope', 'Spectral centroid', 'Rate of change of f0', 'f0 ratio')
  FILEID <- "_cnf"
} else {
  CORE_FEATURE <- LIST_FEATURE
  FILEID <- "_exp"
}

TITLESTR <- c('Instrumental vs. Spoken description', 'Song vs. Spoken description', 'Song vs. Lyrics recitation')
DATATYPE <- c('inst-desc', 'song-desc', 'song-recit')
G_WID <- 7.5
G_HEI <- 6
XL <- c(-1.8, 5.0)
XBREAK <- c(-2, -1, -0.4, 0, 0.4, 1, 2, 3, 4, 5)

## Load effect size information
file.data <- c(
  paste(INPUTDIR, 'results_effectsize_acoustic_', DATATYPE, '_Infsec.csv', sep = ''),
  paste(INPUTDIR, 'results_effectsize_seg_', DATATYPE, '_Infsec.csv', sep = '')
)

data <- c()
for (i in 1:length(file.data)) {
  if (file.exists(file.data[i])) {
    data_i <- read.csv(file = file.data[i])
    
    idx <- sapply(DATATYPE, function (x) grepl(x, file.data[i], fixed = TRUE))
    data_i$Comparison <- TITLESTR[idx]
    
    data <- rbind(data, data_i)
  } else {
    print(paste(file.data[i], " does not exist.", sep = ""))
  }
}

## Load meta-analysis results
file.data <- c(
  paste(INPUTDIR, 'ma_acoustic_', DATATYPE, '_Infsec.csv', sep = ''),
  paste(INPUTDIR, 'ma_seg_', DATATYPE, '_Infsec.csv', sep = '')
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

## Change name
CORE_FEATURE[CORE_FEATURE == "Sign of f0 slope"] <- "Coefficient of f0 slope"
FEATURE_SIM[FEATURE_SIM == "Sign of f0 slope"] <- "Coefficient of f0 slope"
LIST_FEATURE[LIST_FEATURE == "Sign of f0 slope"] <- "Coefficient of f0 slope"
data$feature[data$feature == "Sign of f0 slope"] <- "Coefficient of f0 slope"
data_ma$feature[data_ma$feature == "Sign of f0 slope"] <- "Coefficient of f0 slope"

## ELT
data$diff[data$diff == 1 & !is.nan(data$diff)] <- 1 - 3e-3
data$diff[data$diff == 0 & !is.nan(data$diff)] <- 3e-3

data$d <- sqrt(2)*qnorm(data$diff, 0, 1) #convert common language effect size to Cohen's d

data$featureplotname <- ""
data_ma$featureplotname <- ""
for (i in 1:length(LIST_FEATURE)) {
  plotname <- paste(CONCEPT_NAME[i], "\n(", LIST_FEATURE[i], ")", sep = "") 
  
  data$featureplotname[data$feature == LIST_FEATURE[i]] <- plotname 
  data_ma$featureplotname[data_ma$feature == LIST_FEATURE[i]] <- plotname
}

data$dummyID <- 1:dim(data)[1]
data_ma$dummyID <- 0

data_ma$lang <- ""

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
  data_i <- data[data$Comparison == LIST_COMPARISON[i], ]
  
  g_list[[i]] <- ggplot(data_i, aes(x = d, y = featureplotname, fill = lang, group = dummyID)) + 
    geom_rect(aes(xmin = -0.4, xmax = 0.4, ymin = 0.3, ymax = length(unique(featureplotname)) + 0.7), fill = "#E46F80", alpha = 0.01, show.legend = FALSE) + 
    geom_dotplot(binaxis = 'y', position = "dodge", stackdir = 'center', alpha = 0.8) +
    geom_vline(xintercept = 0, linetype = 2) +
    geom_vline(xintercept = 0.4, linetype = 3) +
    geom_vline(xintercept = -0.4, linetype = 3) +
    theme(axis.title.y = element_blank()) +
    xlab("Translated Cohen's D") + 
    scale_y_discrete(limits = ORDER_Y_AXIS) +
    ggtitle(LIST_COMPARISON[i]) +
    theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5)) +
    theme(axis.text.x = element_text(size = 10)) + 
    xlim(XL) + 
    scale_x_continuous(breaks = XBREAK) + 
    theme(legend.title = element_blank())
  
  ## difference
  data_ma$lang <- data_i$lang[1]
  
  idx <- data_ma$feature %in% FEATURE_DIFF & data_ma$Comparison == LIST_COMPARISON[i]
  
  if (sum(idx) > 0) {
    data_i <- data_ma[idx, ]
    data_i$grp <- 1:sum(idx)
    data_i$x <- sqrt(2)*qnorm(data_i$mean, 0, 1)
    data_j <- data_ma[idx, ]
    data_j$grp <- 1:sum(idx)
    data_j$x <- sqrt(2)*qnorm(data_j$CI_l, 0, 1)
    
    g_list[[i]] <- g_list[[i]] + 
      geom_line(data = rbind(data_i, data_j), aes(x = x, y = featureplotname, group = grp), show.legend = FALSE) + 
      geom_point(data = data_ma[idx, ], aes(x = sqrt(2)*qnorm(CI_l, 0, 1), y = featureplotname), shape = "|", size = 5, show.legend = FALSE) +
      geom_point(data = data_ma[idx, ], aes(x = sqrt(2)*qnorm(mean, 0, 1), y = featureplotname), shape = 23, size = 3, fill = "#d7003a", show.legend = FALSE)
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
    
    g_list[[i]] <- g_list[[i]] + 
      geom_line(data = rbind(data_i, data_j), aes(x = x, y = featureplotname, group = grp), show.legend = FALSE) + 
      geom_point(data = data_ma[idx, ], aes(x = sqrt(2)*qnorm(mean, 0, 1), y = featureplotname), shape = 23,  size = 3, fill = "#d7003a", show.legend = FALSE) +
      geom_point(data = rbind(data_i, data_j), aes(x = x, y = featureplotname), shape = "|", size = 5, show.legend = FALSE)
  }
  
  ## Others
  idx <- data_ma$feature %in% FEATURE_OTHER & data_ma$Comparison == LIST_COMPARISON[i]
  
  if (sum(idx) > 0) {
    data_i <- data_ma[idx, ]
    data_i$grp <- 1:sum(idx)
    data_i$x <- sqrt(2)*qnorm(data_i$CI_l, 0, 1)
    data_j <- data_ma[idx, ]
    data_j$grp <- 1:sum(idx)
    data_j$x <- sqrt(2)*qnorm(data_j$CI_u, 0, 1)
    
    g_list[[i]] <- g_list[[i]] + 
      geom_line(data = rbind(data_i, data_j), aes(x = x, y = featureplotname, group = grp), show.legend = FALSE) +
      geom_point(data = data_ma[idx, ], aes(x = sqrt(2)*qnorm(mean, 0, 1), y = featureplotname), shape = 23,  size = 3, fill = "#008080", show.legend = FALSE) +
      geom_point(data = rbind(data_i, data_j), aes(x = x, y = featureplotname), shape = "|", size = 5, show.legend = FALSE)
  }
  
  ggsave(file = paste(OUTPUTDIR, "effectsize_", LIST_COMPARISON[i], FILEID, ".png", sep = ""), plot = g_list[[i]], width = G_WID, height = G_HEI)
}