###
library(ggplot2)
DATANAME <- c('Hilton et al.\n(Automated)', 'Hilton et al.\n(Semi-automated)', 'Pilot data\n(Automated)', 'Pilot data\n(Semi-automated)')

###
es_Hilton_pyin <- read.csv(paste(INPUTDIR, "Hilton-pyin/results_effectsize_acoustic_song-desc_Infsec.csv", sep = ""))
es_Hilton_pyin$dataname <- DATANAME[1]
es_Hilton_sa <- read.csv(paste(INPUTDIR, "Hilton-sa/results_effectsize_acoustic_song-desc_Infsec.csv", sep = ""))
es_Hilton_sa$dataname <- DATANAME[2]
es_Pilotdata_auto <- read.csv(paste(INPUTDIR, "pilot-pyin/results_effectsize_acoustic_song-desc_Infsec.csv", sep = ""))
es_Pilotdata_auto$dataname <- DATANAME[3]
es_Pilotdata <- read.csv(paste(INPUTDIR, "results_effectsize_acoustic_song-desc_Infsec.csv", sep = ""))
es_Pilotdata$dataname <- DATANAME[4]

es_table <- rbind(es_Hilton_pyin, es_Hilton_sa, es_Pilotdata_auto, es_Pilotdata)
es_table <- es_table[es_table$feature == 'f0', ]
es_table$dummyID <- 1:dim(es_table)[1]

###
ma_Hilton_pyin <- read.csv(paste(INPUTDIR, "Hilton-pyin/ma_acoustic_song-desc_Infsec.csv", sep = ""))
ma_Hilton_pyin$dataname <- DATANAME[1]
ma_Hilton_sa <- read.csv(paste(INPUTDIR, "Hilton-sa/ma_acoustic_song-desc_Infsec.csv", sep = ""))
ma_Hilton_sa$dataname <- DATANAME[2]
ma_Pilotdata_auto <- read.csv(paste(INPUTDIR, "pilot-pyin/ma_acoustic_song-desc_Infsec.csv", sep = ""))
ma_Pilotdata_auto$dataname <- DATANAME[3]
ma_Pilotdata <- read.csv(paste(INPUTDIR, "ma_acoustic_song-desc_Infsec.csv", sep = ""))
ma_Pilotdata$dataname <- DATANAME[4]

ma_table <- rbind(ma_Hilton_pyin, ma_Hilton_sa, ma_Pilotdata_auto, ma_Pilotdata)
ma_table <- ma_table[ma_table$feature == 'f0', ]
ma_table$dummyID <- (1000 + 1:dim(ma_table)[1])
ma_table$lang <- es_table$lang[1]

###
g_list <- ggplot(es_table, aes(x = sqrt(2)*qnorm(diff, 0, 1), y = dataname, fill = lang, group = dummyID)) + 
  geom_rect(aes(xmin = -0.4, xmax = 0.4, ymin = 0.3, ymax = length(unique(dataname)) + 0.7), fill = "#E46F80", alpha = 0.01, show.legend = FALSE) + 
  geom_dotplot(binaxis = 'y', position = "dodge", stackdir = 'center', alpha = 0.8) +
  geom_vline(xintercept = 0, linetype = 2) +
  geom_vline(xintercept = 0.4, linetype = 3) +
  geom_vline(xintercept = -0.4, linetype = 3) +
  theme(axis.title.y = element_blank()) +
  xlab("Translated Cohen's D") + 
  scale_y_discrete(limits = DATANAME) +
  ggtitle('Song vs. Spoken description\n(Pitch height)') +
  theme(plot.title = element_text(size = 14, face = "bold", hjust = 0.5)) +
  theme(axis.text.x = element_text(size = 10)) + 
  theme(axis.text.y = element_text(hjust = 0.5)) +
  theme(legend.title = element_blank()) + 
  scale_x_continuous(breaks = c(-2, -1, -0.4, 0, 0.4, 1, 2, 3, 4, 5))

g_list <- g_list + 
  geom_point(data = ma_table, aes(x = sqrt(2)*qnorm(mean, 0, 1), y = dataname), shape = 23,  size = 3, fill = "#d7003a", show.legend = FALSE) +
  geom_point(data = ma_table, aes(x = sqrt(2)*qnorm(CI_l, 0, 1), y = dataname), shape = "|", size = 5, show.legend = FALSE) + 
  geom_segment(data = ma_table, aes(x = sqrt(2)*qnorm(CI_l, 0, 1), xend = sqrt(2)*qnorm(mean, 0, 1), yend = dataname), size = 1)

###
ggsave(file = paste(OUTPUTDIR, "Hilton_merge.png", sep = ""), plot = g_list, width = 6, height = 4)

##
INPUTDIR_base <- INPUTDIR
OUTPUTDIR_base <- OUTPUTDIR

INPUTDIR <- paste(INPUTDIR_base, "Hilton-pyin/", sep = "")
OUTPUTDIR <- paste(OUTPUTDIR_base, "Hilton-pyin/", sep = "")
if (!dir.exists(OUTPUTDIR)){
  dir.create(OUTPUTDIR)
}
exploratory <- FALSE
source("plot_featureES_pilot.R")

g_pyin <- g_list[[1]] +
  scale_x_continuous(breaks = c(-0.4, 0, 0.4, 1, 2))
g_pyin$labels$title <- paste(g_pyin$labels$title, "\n(Automated f0 extraction)", sep = "")

##
INPUTDIR <- paste(INPUTDIR_base, "Hilton-sa/", sep = "") 
OUTPUTDIR <- paste(OUTPUTDIR_base,"Hilton-sa/", sep = "")
if (!dir.exists(OUTPUTDIR)){
  dir.create(OUTPUTDIR)
}
exploratory <- FALSE
source("plot_featureES_pilot.R")

g_sa <- g_list[[1]] +
  scale_x_continuous(breaks = c(-0.4, 0, 0.4, 1, 2))
g_sa$labels$title <- paste(g_sa$labels$title, "\n(Semi-automated f0 extraction)", sep = "")

##
g <- ggarrange(g_pyin, g_sa, ncol = 2, nrow = 1, common.legend = TRUE, legend = "bottom")
ggsave(file = paste(OUTPUTDIR_base, "Hilton_merge2.png", sep = ""), plot = g, width = 9, height = 4)