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
featureset <- unique(esdata$feature)
result <- data.frame(feature = character(), aic_f = numeric(), aic_m = numeric(), loglik_f = numeric(), loglik_m = numeric(), var = numeric())

for (i in 1:length(featureset)) {
  esdata_i <- esdata[esdata$feature == featureset[i], ]
  
  model_ml <- mixmeta(diff, stderr^2, random = ~ 1|langfamily/dummyid, data = esdata_i, method = "ml")
  cat("-------Maximu likelihood fitting with the two-level random effects meta-analysis model-------\n")
  sm_ml <- summary(model_ml)
  print(sm_ml)
  
  model_plain <- mixmeta(diff, stderr^2, random = ~ 1|dummyid, data = esdata_i, method = "ml")
  cat("-------Maximu likelihood fitting with a standard random effects meta-analysis model-------\n")
  sm_plain <- summary(model_plain)
  print(sm_plain)
  
  cat(paste(featureset[i], ": AIC ", AIC(model_ml), " (multilevel) vs. ", AIC(model_plain), " (flat)\n\n", sep = ""))
  
  result[nrow(result) + 1, ] <- list(featureset[i], sm_plain$AIC, sm_ml$AIC, sm_plain$logLik, sm_ml$logLik, model_ml$par[1]^2)
}

print(result)