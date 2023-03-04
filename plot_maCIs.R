##### [Driver] #####
rm(list = ls())
INPUTDIR <- './output/analysis/Stage2/'
OUTPUTDIR <- './output/figure/Stage2/'
durationID <- '20sec'
exploratory <- FALSE

## Library
library(ggplot2)
library(ggpubr)

## Constants
DATATYPE <- c('inst-desc', 'song-desc', 'song-recit')
TITLESTR <- c('Instrumental vs. Spoken description', 'Song vs. Spoken description', 'Song vs. Lyrics recitation')

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

## Arrange for geom_line
data_i <- data[data$feature == 'f0 ratio', ]
df_i <- data.frame('diff' = sqrt(2)*qnorm(data_i$diff, mean = 0, sd = 1), 'lang' = data_i$lang, 'dummyid' = 0, 'langfamily' = "")
for (i in 1:dim(df_i)[1]) {
  df_i$langfamily[i] <- LANGCOLORMAP$family[LANGCOLORMAP$lang_filename == df_i$lang[i]]
}
df_i$dummyid[order(df_i$langfamily, df_i$diff)] <- 1:dim(df_i)[1]

df_cil <- cbind(df_i, data.frame('ci95' = sqrt(2)*qnorm(data_i$ci95_l, mean = 0, sd = 1)))
df_ciu <- cbind(df_i, data.frame('ci95' = sqrt(2)*qnorm(data_i$ci95_u, mean = 0, sd = 1)))
df_ci <- rbind(df_cil, df_ciu)

## ggplot
g <- ggplot(data = df_ci, aes(y = dummyid, color = lang)) +
  geom_line(aes(x = ci95, group = dummyid), color = "#000000", show.legend = FALSE) +
  geom_point(aes(x = diff)) + 
  scale_color_manual(values = LANGCOLORMAP$rgb, breaks = LANGCOLORMAP$lang_filename) + 
  theme(legend.position = "none") + 
  xlab("Translated Cohen's d") + ylab("")

plot(g)