## Library
library(ggplot2)
library(ggpubr)

## Constants
TITLESTR <- c('Instrumental vs. Spoken description', 'Song vs. Spoken description', 'Song vs. Lyrics recitation')
DATATYPE <- c('inst-desc', 'song-desc', 'song-recit')
ORDER_Y_AXIS <- as.factor(TITLESTR)
OUTPUTDIR <- './output/20220705/'
G_WID <- 7.5
G_HEI <- 6

##Specify data download location
file.data <- paste('./output/20220705/results_Marsden-all_', DATATYPE, '.csv', sep = '')

data_all <- c()
for (i in 1:length(DATATYPE)) {
  data_i <- read.csv(file = file.data[i])
  data_i$Comparison <- TITLESTR[i]
  data_all <- rbind(data_all, data_i)
}

file.data <- paste('./output/20220705/results_Marsden-complete_', DATATYPE, '.csv', sep = '')

data_complete <- c()
for (i in 1:length(DATATYPE)) {
  data_i <- read.csv(file = file.data[i])
  data_i$Comparison <- TITLESTR[i]
  data_complete <- rbind(data_complete, data_i)
}

data <- rbind(data_all, data_complete)

# ETL
data$diff[data$diff == 1 & !is.nan(data$diff)] <- 1 - 3e-3
data$d <- sqrt(2)*qnorm(data$diff, 0, 1) #convert common language effect size to Cohen's d
data <- subset(data, method=="common language effect size") #restrict to only effect size data

data$feature[data$feature == "Magnitude of F0 modulatioin"] <- "F0 modulation"
#LIST_FEATURE <- unique(data$feature)
LIST_FEATURE <- c('IOI', 'F0', 'Interval deviation', 'Onset-break interval', 'F0 modulation', 'IOI ratio deviation', 'Spectral centroid')

## ggplot
g_list <- vector(mode = "list", length = length(LIST_FEATURE))

for (i in 1:length(g_list)) {
  g_list[[i]] <- ggplot(data[data$feature == LIST_FEATURE[i], ], aes(x = d, y = Comparison, fill = lang)) + 
    geom_dotplot(binaxis = 'y', stackdir = 'center', position = "dodge", alpha = 0.8) +
    geom_vline(xintercept = 0, linetype = 2) +
    geom_vline(xintercept = 0.5, linetype = 3) +
    geom_vline(xintercept = 0.8, linetype = 3) + 
    theme(axis.title.x = element_blank(), axis.title.y = element_blank()) +
    scale_y_discrete(limits = ORDER_Y_AXIS) +
    ggtitle(LIST_FEATURE[i]) +
    theme(plot.title = element_text(hjust = 0.5)) + 
    xlim(c(-1.5, 4.0)) + 
    theme(axis.text.y = element_blank()) +
    theme(legend.position = "none")
}

##
g <- ggarrange(plotlist = g_list, nrow = 2, ncol = 4, common.legend = FALSE)
plot(g)
ggsave(file = paste(OUTPUTDIR, "MarsdenData.png", sep = ""), plot = g, width = G_WID, height = G_HEI)

## Dummy figure
g_list <- vector(mode = "list", length = 2)

for (i in 1:length(g_list)) {
  g_list[[i]] <- ggplot(data[data$feature == LIST_FEATURE[i], ], aes(x = d, y = Comparison, fill = lang)) + 
    geom_dotplot(binaxis = 'y', stackdir = 'center', position = "dodge", alpha = 0.8) +
    geom_vline(xintercept = 0, linetype = 2) +
    geom_vline(xintercept = 0.5, linetype = 3) +
    geom_vline(xintercept = 0.8, linetype = 3) + 
    theme(axis.title.y = element_blank()) +
    scale_y_discrete(limits = ORDER_Y_AXIS) +
    ggtitle(LIST_FEATURE[i]) +
    theme(plot.title = element_text(hjust = 0.5)) + 
    xlim(c(-1.5, 4.0)) +
    xlab("Translated Cohen's d") +
    guides(fill = guide_legend(title = "Language"))
}

g <- ggarrange(plotlist = g_list, nrow = 2, common.legend = FALSE)
plot(g)
ggsave(file = paste(OUTPUTDIR, "MarsdenData_dummy.png", sep = ""), plot = g, width = G_WID, height = G_HEI)