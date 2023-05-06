##
library(ggplot2)
library(ggpubr)

##
WID <- 4
HEI <- 4
LANGCOLORMAP <- read.csv("./data/LangColorMap.csv")
LANGCOLORMAP$rgb <- paste("#", LANGCOLORMAP$rgb, sep = "")

##
datatype <- strsplit(typeid, "-")[[1]]

npvi_tmp <- read.csv(paste(INPUTDIR, 'npvi_', durationID, '_', typeid, '.csv', sep = ""))
npviinfo <- lapply(unique(npvi_tmp$groupid), function(gid) {data.frame(npvi_song = npvi_tmp$npvi[npvi_tmp$type == datatype[1] & npvi_tmp$groupid == gid],
                                                                       npvi_desc = npvi_tmp$npvi[npvi_tmp$type == datatype[2] & npvi_tmp$groupid == gid],
                                                                       lang = unique(npvi_tmp$lang[npvi_tmp$groupid == gid]))})
npviinfo <- as.data.frame(do.call(rbind, npviinfo))

##
xlabelstr <- switch(datatype[1],
                    "song" = "(song)",
                    "desc" = "(spoken description)",
                    "inst" = "(instrumenal)")
ylabelstr <- switch(datatype[2],
                    "song" = "(song)",
                    "desc" = "(spoken description)",
                    "inst" = "(instrumenal)")

g <- ggplot(data = npviinfo, aes(x = npvi_song, y = npvi_desc, fill = lang, group = 1)) +
  geom_point(shape = 21, alpha = 0.8, size = 2, stroke = 0.5) + 
  geom_smooth(method = "lm", col = "red", level = .95) +
  theme_gray() +
  geom_abline(intercept = 0, slope = 1, color = "Black", linetype = "dotted", size = 0.5) + 
  guides(fill = "none") +
  scale_fill_manual(values = LANGCOLORMAP$rgb, breaks = LANGCOLORMAP$lang_filename) +
  xlab(paste("nPVI", xlabelstr)) + ylab(paste("nPVI", ylabelstr)) + 
  xlim(c(0, 100)) + ylim(c(0, 100))

ggsave(file = paste(OUTPUTDIR, "nPVI_", durationID, '_', typeid, ".png", sep = ""), plot = g, width = WID, height = HEI)

##
print(cor.test(npviinfo$npvi_song, npviinfo$npvi_desc))
print(t.test(x = npviinfo$npvi_song, y = npviinfo$npvi_desc, paired = TRUE, mu = 0, conf.level = .95))