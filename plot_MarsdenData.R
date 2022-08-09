library(ggplot2)

#TITLESTR <- 'Instrumental vs. Spoken description'
#TITLESTR <- 'Song vs. Spoken description'
TITLESTR <- 'Song vs. Lyrics recitation'
OUTPUTDIR <- './output/20220705/'
G_WID <- 8
G_HEI <- 5

#Specify data download location
file.data <- "./output/20220705/results_Marsden-all_song-recit.csv"
data_all <- read.csv(file = file.data)

file.data <- "./output/20220705/results_Marsden-complete_song-recit.csv"
data_complete <- read.csv(file = file.data)

data <- rbind(data_all, data_complete)

# ETL
data$diff[data$diff == 1 & !is.nan(data$diff)] <- 1 - 1e-8
data$d <- sqrt(2)*qnorm(data$diff, 0, 1) #convert common language effect size to Cohen's d
data <- subset(data, method=="common language effect size") #restrict to only effect size data

T <- aggregate(data[, 3], list(data$feature), median)
ORDER_YAXIS <- T[(sort(T$x, decreasing = TRUE, index=TRUE)$ix), 1]

# ggplot
g <- ggplot(data, aes(x = d, y = feature, fill = lang)) + 
  geom_dotplot(binaxis = 'y', stackdir = 'center', position = "dodge", alpha = 0.9) +
  geom_vline(xintercept = 0, linetype = 2) +
  geom_vline(xintercept = 0.5, linetype = 3) +
  geom_vline(xintercept = 0.8, linetype = 3) +
  scale_y_discrete(limits = ORDER_YAXIS) +
  xlab("Translated Cohen's d") + theme(axis.title.y = element_blank()) +
  guides(fill = guide_legend(title = "Language")) +
  ggtitle(TITLESTR) + theme(plot.title = element_text(hjust = 0.5))

ggsave(file = paste(OUTPUTDIR, "MarsdenData_", TITLESTR, ".png", sep = ""), plot = g, width = G_WID, height = G_HEI)