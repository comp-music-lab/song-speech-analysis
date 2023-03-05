## Library
library("mixmeta")

## Constants
DATATYPE <- 'song-desc'

LANGCOLORMAP <- read.csv("./data/LangColorMap.csv")
LANGCOLORMAP$rgb <- paste("#", LANGCOLORMAP$rgb, sep = "")

## Load data
esdata <- rbind(
  read.csv(paste(INPUTDIR, 'results_effectsize_acoustic_', DATATYPE, '_', durationID, '.csv', sep = "")),
  read.csv(paste(INPUTDIR, 'results_effectsize_seg_', DATATYPE, '_', durationID, '.csv', sep = ""))
)

esdata$langfamily <- ""
for (i in 1:dim(LANGCOLORMAP)[1]) {
  idx <- esdata$lang == LANGCOLORMAP$lang_filename[i]
  esdata$langfamily[idx] <- LANGCOLORMAP$family[i]
}
esdata$dummyid <- 1:dim(esdata)[1]

##
esdata_i <- esdata[esdata$feature == "IOI rate", ]

model_ml <- mixmeta(diff, stderr^2, random = ~ 1|langfamily/dummyid, data = esdata_i, method = "ml")
cat("-------Maximu likelihood fitting with the two-level random effects meta-analysis model-------\n")
print(summary(model_ml))

model_plain <- mixmeta(diff, stderr^2, random = ~ 1|dummyid, data = esdata_i, method = "ml")
cat("-------Maximu likelihood fitting with a standard random effects meta-analysis model-------\n")
print(summary(model_plain))

cat(paste("AIC: ", AIC(model_ml), " (multilevel) vs. ", AIC(model_plain), " (flat)", sep = ""))