## Library
library(ggplot2)
library(ggpubr)

## Config
featurestatfilepath = './output/20220918/featurestat.csv'  
outputdir = './output/20220918/'
featurelist_diff = c("f0", "IOI rate")
featurelist_sim = c("f0 ratio", "Spectral centroid", "Sign of f0 slope")

SONG <- "Song"
INST <- "Inst."
RECIT <- "Recit."

DESC <- "Speech"
TYPEFILTER <- c(INST, RECIT)
XTICKORDER <- c(SONG, DESC, INST, RECIT)

#DESC <- "Desc."
#TYPEFILTER <- c()
#XTICKORDER <- c(INST, SONG, RECIT, DESC)

XTICKORDER <- XTICKORDER[!(XTICKORDER %in% TYPEFILTER)]

## ETL
T = read.csv(featurestatfilepath)

T$xticklabel <- ""
T$xticklabel[T$type == "inst"] <- INST
T$xticklabel[T$type == "desc"] <- DESC
T$xticklabel[T$type == "song"] <- SONG
T$xticklabel[T$type == "recit"] <- RECIT

T$unit <- ""
T$unit[T$feature == "f0"] <- "Cent (440 Hz = 0)"
T$unit[T$feature == "IOI rate"] <- "Hz"
T$unit[T$feature == "f0 ratio"] <- "Cent"
T$unit[T$feature == "Spectral centroid"] <- "Hz"
T$unit[T$feature == "Sign of f0 slope"] <- "-"

T$sex[T$sex == "f"] <- "Female"
T$sex[T$sex == "m"] <- "Male"

T$name[T$name == "Speed"] <- "Temporal rate"

## Plot
tmp <- unique(T[c("feature", "name", "unit")])
ylabelstr <- sub("ioi", "IOI", paste(tmp$name, "\n(Mean ", tolower(tmp$feature), " [", tmp$unit, "])", sep = ""))

g_list_sim <- vector(mode = "list", length = length(featurelist_sim))
ylabelstr_sim <- ylabelstr[tmp$feature %in% featurelist_sim]
for (i in 1:length(featurelist_sim)) {
  g_list_sim[[i]] <- ggplot(data = T[T$feature == featurelist_sim[i] & !(T$xticklabel %in% TYPEFILTER), ], aes(x = xticklabel, y = mean, group = lang, color = lang, shape = sex)) + 
    geom_point(alpha = 0.8, size = 4) + 
    geom_line(linetype = 2) +
    xlab("") + ylab(ylabelstr_sim[i]) + labs(color = "Language", shape = "Sex") +
    scale_x_discrete(limits = XTICKORDER)
  
  if (featurelist_sim[i] == "f0 ratio") {
    g_list_sim[[i]] <- g_list_sim[[i]] + ylim(c(0, 300))
  } else if(featurelist_sim[i] == "Spectral centroid") {
    g_list_sim[[i]] <- g_list_sim[[i]] + ylim(c(0, 1200))
  } else if(featurelist_sim[i] == "Sign of f0 slope") {
    g_list_sim[[i]] <- g_list_sim[[i]] + ylim(c(-1, 1))
  }
}

g_list_diff <- vector(mode = "list", length = length(featurelist_diff))
ylabelstr_diff <- ylabelstr[tmp$feature %in% featurelist_diff]
for (i in 1:length(featurelist_diff)) {
  g_list_diff[[i]] <- ggplot(data = T[T$feature == featurelist_diff[i] & !(T$xticklabel %in% TYPEFILTER), ], aes(x = xticklabel, y = mean, group = lang, color = lang, shape = sex)) + 
    geom_point(alpha = 0.8, size = 4) + 
    geom_line(linetype = 2) +
    xlab("") + ylab(ylabelstr_diff[i]) + labs(color = "Language", shape = "Sex") +
    scale_x_discrete(limits = XTICKORDER)
  
  if (featurelist_diff[i] == "IOI rate") {
    g_list_diff[[i]] <- g_list_diff[[i]] + ylim(c(0, 7))
  }
}

## Merge plots
numsubplot <- max(length(g_list_sim), length(g_list_diff))
g <- ggarrange(ggarrange(plotlist = g_list_diff, ncol = numsubplot, common.legend = TRUE, legend = "right"), ggarrange(plotlist = g_list_sim, ncol = numsubplot, common.legend = TRUE, legend = "right"), nrow = 2)
ggsave(file = paste(outputdir, "featurestat.png", sep = ""), plot = g, width = 8, height = 6)
plot(g)