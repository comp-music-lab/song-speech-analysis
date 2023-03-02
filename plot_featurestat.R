## Library
library(ggplot2)
library(ggpubr)

## Config
featurelist_diff = c("f0", "IOI rate", "-|Δf0|")
featurelist_sim = c("f0 ratio", "Spectral centroid", "Sign of f0 slope")

SONG <- "Song"
INST <- "Inst."
RECIT <- "Recit."

if (exploratory) {
  DESC <- "Desc."
  TYPEFILTER <- c()
  XTICKORDER <- c(INST, SONG, RECIT, DESC)
  FILEID <- "_exp"
  
  ylim_sc <- c(0, 4000)
  ylim_f0 <- c(-3100, 2100)
  ylim_ioirate <- c(0, 12)
} else {
  DESC <- "Speech"
  TYPEFILTER <- c(INST, RECIT)
  XTICKORDER <- c(SONG, DESC, INST, RECIT)
  FILEID <- "_cnf"
  
  ylim_sc <- c(0, 3000)
  ylim_f0 <- c(-3100, 400)
  ylim_ioirate <- c(0, 10)
}

XTICKORDER <- XTICKORDER[!(XTICKORDER %in% TYPEFILTER)]

LANGCOLORMAP <- read.csv("./data/LangColorMap.csv")
LANGCOLORMAP$rgb <- paste("#", LANGCOLORMAP$rgb, sep = "")

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
T$unit[T$feature == "-|Δf0|"] <- "Cent/sec."
T$unit[T$feature == "f0 ratio"] <- "Cent"
T$unit[T$feature == "Spectral centroid"] <- "Hz"
T$unit[T$feature == "Sign of f0 slope"] <- "-"

T$sex[T$sex == "f"] <- "Female"
T$sex[T$sex == "m"] <- "Male"

## Plot
tmp <- unique(T[c("feature", "name", "unit")])
ylabelstr <- sub("ioi", "IOI", paste(tmp$name, "\n(Mean ", tolower(tmp$feature), " [", tmp$unit, "])", sep = ""))
ylabelstr <- sub("δ", "Δ", ylabelstr)

featurelist <- c(featurelist_diff, featurelist_sim)
g_list <- vector(mode = "list", length = length(featurelist))

for (i in 1:length(featurelist)) {
  g_list[[i]] <- ggplot(data = T[T$feature == featurelist[i] & !(T$xticklabel %in% TYPEFILTER), ], aes(x = xticklabel, y = mean, group = groupid, color = lang, shape = sex)) + 
    geom_point(alpha = 0.8, size = 2) + 
    geom_line(linetype = 2) +
    xlab("") + ylab(ylabelstr[i]) + labs(color = "Language", shape = "Sex") +
    theme(axis.title.y = element_text(size = 10), legend.position = "none") +
    scale_x_discrete(limits = XTICKORDER) + 
    scale_color_manual(values = LANGCOLORMAP$rgb, breaks = LANGCOLORMAP$lang_filename)
  
  if (featurelist[i] == "f0 ratio") {
    g_list[[i]] <- g_list[[i]] + ylim(c(0, 450))
  } else if(featurelist[i] == "Spectral centroid") {
    g_list[[i]] <- g_list[[i]] + ylim(ylim_sc)
  } else if(featurelist[i] == "Coefficient of f0 slope") {
    g_list[[i]] <- g_list[[i]] + ylim(c(-1, 1))
  } else if (featurelist[i] == "IOI rate") {
    g_list[[i]] <- g_list[[i]] + ylim(ylim_ioirate)
  } else if(featurelist[i] == "-|Δf0|") {
    g_list[[i]] <- g_list[[i]] + ylim(c(-2800, 0))
  } else if(featurelist[i] == "f0") {
    g_list[[i]] <- g_list[[i]] + ylim(ylim_f0)
  }
}

## Merge plots
g <- ggarrange(plotlist = g_list, ncol = 3, nrow = 2)
ggsave(file = paste(OUTPUTDIR, "featurestat", FILEID, ".png", sep = ""), plot = g, width = 8, height = 6)

## Save legend
l <- g_list[[1]] + theme(legend.position = "right")
l <- as_ggplot(get_legend(l))
ggsave(file = paste(OUTPUTDIR, "featurestat-legend", FILEID, ".png", sep = ""), plot = l, width = 8, height = 6)