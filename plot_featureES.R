## Library
library(ggplot2)
library(ggpubr)

## Constants
LIST_FEATURE <- c('Spectral flatness', 'IOI rate', '90% f0 quantile length', 'Short-term energy', 'IOI ratio deviation', 'f0', 'Sign of f0 slope', 'Onset-break interval', 'f0 ratio deviation', '-|Δf0|', 'f0 ratio', 'Spectral centroid', 'Pulse clarity')
CONCEPT_NAME <- c('Timbral noisiness', 'Temporal rate', 'Pitch range', 'Loudness', 'Rhythmic regularity', 'Pitch height', 'Pitch declination', 'Phrase length', 'Interval regularity', 'Pitch stability', 'Pitch interval size', 'Timbral brightness', 'Pulse clarity')
FEATURE_DIFF <- c('f0', 'IOI rate', '-|Δf0|')
FEATURE_SIM <- c('Spectral centroid', 'Sign of f0 slope', 'f0 ratio')
FEATURE_OTHER <- c('Spectral flatness', '90% f0 quantile length', 'Short-term energy', 'IOI ratio deviation', 'Onset-break interval', 'f0 ratio deviation', 'Pulse clarity')

if (exploratory) {
  CORE_FEATURE <- LIST_FEATURE
  FILEID <- "_exp"
} else {
  CORE_FEATURE <- c('IOI rate', 'f0', 'Sign of f0 slope', 'Spectral centroid', '-|Δf0|', 'f0 ratio')
  FILEID <- "_cnf"
}

TITLESTR <- c('Instrumental vs. Spoken description', 'Song vs. Spoken description', 'Song vs. Lyrics recitation')
DATATYPE <- c('inst-desc', 'song-desc', 'song-recit')
G_WID <- 9
G_HEI <- 6
XL <- c(-4, 8)
XBREAK <- c(-3, -2, -1, -0.4, 0, 0.4, 1, 2, 3, 4, 5, 6, 7)
YPOSNUDGE <- 0.38

LANGCOLORMAP <- read.csv("./data/LangColorMap.csv")
LANGCOLORMAP$rgb <- paste("#", LANGCOLORMAP$rgb, sep = "")

## Load effect size information
file.data <- c(
  paste(INPUTDIR, 'results_effectsize_acoustic_', DATATYPE, '_', durationID, '.csv', sep = ''),
  paste(INPUTDIR, 'results_effectsize_seg_', DATATYPE, '_', durationID, '.csv', sep = '')
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
idx <- 0
idx_ma <- 0
for (i in 1:length(CORE_FEATURE)) {
  idx <- idx | data$feature == CORE_FEATURE[i]
  idx_ma <- idx_ma | data_ma$feature == CORE_FEATURE[i]
}

data <- data[idx, ]
data_ma <- data_ma[idx_ma, ]

## ggplot
LIST_COMPARISON <- unique(data$Comparison)
g_list <- vector(mode = "list", length = length(LIST_COMPARISON))

FEATURE_PLOTORDER <- c("f0", "IOI rate", "-|Δf0|", "Spectral centroid", "f0 ratio", "Sign of f0 slope",
                       "Onset-break interval", "Short-term energy", "Spectral flatness", "IOI ratio deviation", 
                       "f0 ratio deviation", "Pulse clarity", "90% f0 quantile length")
tmp <- unique(data[, c("feature", "featureplotname")])
idx <- as.vector(sapply(FEATURE_PLOTORDER, function(s) {match(s, tmp$feature)}))
ORDER_Y_AXIS <- rev(as.factor(tmp$featureplotname[idx]))
ORDER_Y_AXIS <- ORDER_Y_AXIS[!is.na(ORDER_Y_AXIS)]

for (i in 1:length(g_list)) {
  data_i <- data[data$Comparison == LIST_COMPARISON[i], ]
  
  g_list[[i]] <- ggplot(data_i, aes(x = d, y = featureplotname, fill = lang, group = dummyID)) + 
    geom_rect(aes(xmin = -0.4, xmax = 0.4, ymin = 0.3, ymax = length(unique(featureplotname)) + 0.7), fill = "#E46F80", alpha = 0.01, show.legend = FALSE) + 
    geom_violin(data = data_i, aes(x = d, group = featureplotname), fill = "#FCAE1E", alpha = 0.2) + 
    geom_dotplot(binaxis = 'y', position = position_jitter(width = 0.00, height = 0.05), stackdir = 'center', alpha = 0.8, dotsize = 0.4) +
    geom_vline(xintercept = 0, linetype = 2) +
    geom_vline(xintercept = 0.4, linetype = 3) +
    geom_vline(xintercept = -0.4, linetype = 3) +
    theme(axis.title.y = element_blank()) +
    xlab("Translated Cohen's D") + 
    scale_y_discrete(limits = ORDER_Y_AXIS) +
    ggtitle(LIST_COMPARISON[i]) +
    theme_gray() +
    theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5)) +
    theme(axis.text.x = element_text(size = 10)) + 
    scale_fill_manual(values = LANGCOLORMAP$rgb, breaks = LANGCOLORMAP$lang_filename) +
    theme(legend.title = element_blank())
  
  if (exploratory) {
    g_list[[i]] <- g_list[[i]] + 
      geom_segment(data = data.frame(dummyID = 0, lang = "English"), aes(x = XL[1] + .05, y = 7.6, xend = XL[1] + .05, yend = 13.65), color = "red") +
      geom_segment(data = data.frame(dummyID = 0, lang = "English"), aes(x = XL[2] - .05, y = 7.6, xend = XL[2] - .05, yend = 13.65), color = "red") +
      geom_segment(data = data.frame(dummyID = 0, lang = "English"), aes(x = XL[1] + .05, y = 7.6, xend = XL[2] - .05, yend = 7.6), color = "red") +
      geom_segment(data = data.frame(dummyID = 0, lang = "English"), aes(x = XL[1] + .05, y = 13.65, xend = XL[2] - .05, yend = 13.65), color = "red")
  }
  
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
      geom_line(data = rbind(data_i, data_j), aes(x = x, y = featureplotname, group = grp), position = position_nudge(y = YPOSNUDGE), show.legend = FALSE) + 
      geom_point(data = data_ma[idx, ], aes(x = sqrt(2)*qnorm(CI_l, 0, 1), y = featureplotname), shape = "|", size = 3, position = position_nudge(y = YPOSNUDGE), show.legend = FALSE) +
      geom_point(data = data_ma[idx, ], aes(x = sqrt(2)*qnorm(mean, 0, 1), y = featureplotname), shape = 23, size = 3, fill = "#d7003a", position = position_nudge(y = YPOSNUDGE), show.legend = FALSE)
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
      geom_line(data = rbind(data_i, data_j), aes(x = x, y = featureplotname, group = grp), position = position_nudge(y = YPOSNUDGE), show.legend = FALSE) + 
      geom_point(data = data_ma[idx, ], aes(x = sqrt(2)*qnorm(mean, 0, 1), y = featureplotname), shape = 23,  size = 3, fill = "#d7003a", position = position_nudge(y = YPOSNUDGE), show.legend = FALSE) +
      geom_point(data = rbind(data_i, data_j), aes(x = x, y = featureplotname), shape = "|", size = 3, position = position_nudge(y = YPOSNUDGE), show.legend = FALSE)
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
      geom_line(data = rbind(data_i, data_j), aes(x = x, y = featureplotname, group = grp), position = position_nudge(y = YPOSNUDGE), show.legend = FALSE) +
      geom_point(data = data_ma[idx, ], aes(x = sqrt(2)*qnorm(mean, 0, 1), y = featureplotname), shape = 23,  size = 3, fill = "#008080", position = position_nudge(y = YPOSNUDGE), show.legend = FALSE) +
      geom_point(data = rbind(data_i, data_j), aes(x = x, y = featureplotname), shape = "|", size = 3, position = position_nudge(y = YPOSNUDGE), show.legend = FALSE)
  }
  
  g_list[[i]] <- g_list[[i]] + scale_x_continuous(breaks = XBREAK, limits = XL, expand = c(0.0, 0.0))
  
  # Save
  g_list[[i]] <- g_list[[i]] + theme(legend.position = 'none')
  ggsave(file = paste(OUTPUTDIR, "effectsize_", LIST_COMPARISON[i], FILEID, ".png", sep = ""), plot = g_list[[i]], width = G_WID, height = G_HEI)
  
  g_list[[i]] <- g_list[[i]] + theme(legend.position = 'right')
  l <- as_ggplot(get_legend(g_list[[i]]))
  ggsave(file = paste(OUTPUTDIR, "effectsize_", LIST_COMPARISON[i], FILEID, "-legend.png", sep = ""), plot = l, width = G_WID, height = G_HEI)
}