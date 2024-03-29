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
                    "inst" = "(instrumenal)",
                    "recit" = "(lyrics recitation)")
ylabelstr <- switch(datatype[2],
                    "song" = "(song)",
                    "desc" = "(spoken description)",
                    "inst" = "(instrumenal)",
                    "recit" = "(lyrics recitation)")

g <- ggplot(data = npviinfo, aes(x = npvi_song, y = npvi_desc, fill = lang, group = 1)) +
  geom_point(shape = 21, alpha = 0.8, size = 2, stroke = 0.5) + 
  geom_smooth(method = "lm", col = "red", level = .95) +
  theme_gray() +
  geom_abline(intercept = 0, slope = 1, color = "Black", linetype = "dotted", size = 0.5) + 
  guides(fill = "none") +
  theme(axis.text = element_text(size = 14), axis.title = element_text(size = 14)) + 
  scale_fill_manual(values = LANGCOLORMAP$rgb, breaks = LANGCOLORMAP$lang_filename) +
  xlab(paste("nPVI", xlabelstr)) + ylab(paste("nPVI", ylabelstr)) + 
  xlim(c(0, 100)) + ylim(c(0, 100))

ggsave(file = paste(OUTPUTDIR, "nPVI_", durationID, '_', typeid, ".png", sep = ""), plot = g, width = WID, height = HEI)

##
print(cor.test(npviinfo$npvi_song, npviinfo$npvi_desc))

##
npvi_tmp <- read.csv(paste(INPUTDIR, 'npvi_', durationID, '_song-desc.csv', sep = ""))
tmp <- read.csv(paste(INPUTDIR, 'npvi_', durationID, '_song-inst.csv', sep = ""))
tmp2 <- read.csv(paste(INPUTDIR, 'npvi_', durationID, '_song-recit.csv', sep = ""))
npviinfo <- rbind(npvi_tmp, tmp[tmp$type == "inst", ], tmp2[tmp2$type == "recit", ])

g <- ggplot(data = npviinfo, aes(x = type, y = npvi)) + 
  geom_violin(aes(group = type)) + 
  geom_point(aes(color = lang), position = position_jitter(width = 0.1, height = 0)) + 
  geom_line(aes(group = groupid, color = lang), alpha = 0.2) +
  geom_violin(aes(group = type), alpha = 0, draw_quantiles = 0.5) +
  theme_gray() +
  guides(color = "none") + 
  xlab("") + ylab("nPVI") +
  theme(axis.text.y = element_text(size = 11), axis.text.x = element_text(size = 11), axis.title = element_text(size = 14)) + 
  scale_color_manual(values = LANGCOLORMAP$rgb, breaks = LANGCOLORMAP$lang_filename) + 
  scale_x_discrete(limits = c("inst", "song", "recit", "desc"), labels = c("song" = "Song", "inst" = "Instrumental", "recit" = "Lyrics\nrecitation", "desc" = "Spoken\ndescription"))

ggsave(file = paste(OUTPUTDIR, "nPVIdist.png", sep = ""), plot = g, width = WID, height = HEI)