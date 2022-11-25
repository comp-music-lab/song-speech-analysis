rm(list = ls())

##
INPUTDIR <- "./output/Hilton-pyin/"
OUTPUTDIR <- "./output/Hilton-pyin/"
exploratory <- FALSE
source("plot_featureES.R")

g_pyin <- g_list[[1]] +
  scale_x_continuous(breaks = c(-0.4, 0, 0.4, 1, 2))
g_pyin$labels$title <- paste(g_pyin$labels$title, "\n(Automated f0 extraction)", sep = "")

##
INPUTDIR <- "./output/Hilton-sa/"
OUTPUTDIR <- "./output/Hilton-sa/"
exploratory <- FALSE
source("plot_featureES.R")

g_sa <- g_list[[1]] +
  scale_x_continuous(breaks = c(-0.4, 0, 0.4, 1, 2))
g_sa$labels$title <- paste(g_sa$labels$title, "\n(Semi-automated f0 extraction)", sep = "")

##
g <- ggarrange(g_pyin, g_sa, ncol = 2, nrow = 1, common.legend = TRUE, legend = "bottom")
ggsave(file = paste(OUTPUTDIR, "Hilton_merge.png", sep = ""), plot = g, width = 9, height = 4)