### Import libraries
library(ggplot2)
library(stringdist)
library(rstan)
library(brms)

### Constants
GSI_MEASUREMENT <- rbind(
  data.frame(var = "selfrep_performer", desc = "Self-reported performer", order = c(0, 1, 2, 3, 4, 5, 6), value = c(1, 2, 3, 4, 5, 6, 7)),
  data.frame(var = "selfrep_musician", desc = "Self-reported musician", order = c(0, 1, 2, 3, 4, 5, 6), value = c(1, 2, 3, 4, 5, 6, 7)),
  data.frame(var = "practice_years", desc = "Years of regular practice", order = c(0, 1, 2, 3, 4, 5, 6), value = c("0", "1", "2", "3", "4-5", "6-9", "10 or more")),
  data.frame(var = "practice_hours", desc = "Hours of regular practice", order = c(0, 1, 2, 3, 4, 5, 6), value = c("0", "0.5", "1", "1.5", "2", "3-4", "5 or more")),
  data.frame(var = "trainyr_theory", desc = "Years of theory training", order = c(0, 1, 2, 3, 4, 5, 6), value = c("0", "0.5", "1", "2", "3", "4-6", "7 or more")),
  data.frame(var = "trainyr_singing", desc = "Years of singing training", order = c(0, 1, 2, 3, 4, 5, 6), value = c("0", "0.5", "1", "2", "3-5", "6-9", "10 or more")),
  data.frame(var = "trainyr_inst", desc = "Years of instrumental training", order = c(0, 1, 2, 3, 4, 5, 6), value = c("0", "0.5", "1", "2", "3-5", "6-9", "10 or more")),
  data.frame(var = "numinst", desc = "Number of instruments", order = c(0, 1, 2, 3, 4, 5, 6), value = c("0", "1", "2", "3", "4", "5", "6 or more"))
)
GSI_VAR <- unique(GSI_MEASUREMENT[, 1:2])

FEATURE <- data.frame(feature = c("f0", "-|Δf0|", "IOI rate"), featurename = c("Pitch height", "Pitch stability", "Temporal rate"))

LANGCOLORMAP <- read.csv("./data/LangColorMap.csv")
LANGCOLORMAP$rgb <- paste("#", LANGCOLORMAP$rgb, sep = "")

### Read musical experience data
rawdata <- read.csv('./data/Questionnaire on linguistic and musical information for Ozaki et al. (2023) (Responses).csv')
rawdata <- rawdata[2:nrow(rawdata), ]

df_musicalexperience <- data.frame(
  firstname = rawdata[, 16],
  lastname = rawdata[, 17],
  selfrep_performer = rawdata[, 7],
  selfrep_musician = rawdata[, 8],
  practice_years = rawdata[, 9],
  practice_hours = rawdata[, 10],
  trainyr_theory = rawdata[, 11],
  trainyr_singing = rawdata[, 12],
  trainyr_inst = rawdata[, 19],
  numinst = rawdata[, 13]
)

### Read name and id data, and combine them
rawdata <- read.csv("datainfo.csv")

df_musicalexperience$performer <- ""
df_musicalexperience$groupid <- 0
df_musicalexperience$language <- ""

for (i in 1:nrow(df_musicalexperience)) {
  performer_i <- paste(df_musicalexperience$firstname[i], df_musicalexperience$lastname[i], sep = " ")
  lvdist <- stringdist(performer_i, rawdata$performer, method = 'lv')
  idx <- which.min(lvdist)
  df_musicalexperience$performer[i] <- rawdata$performer[idx]
  df_musicalexperience$groupid[i] <- rawdata$groupid[idx]
  df_musicalexperience$language[i] <- rawdata$language[idx]
}

### Read effect size data, and combine them
esinfo <- rbind(
  read.csv('./output/analysis/Stage2/results_effectsize_seg_song-desc_20sec.csv'),
  read.csv('./output/analysis/Stage2/results_effectsize_acoustic_song-desc_20sec.csv')
)
esinfo$performer <- ""

for (i in 1:nrow(GSI_VAR)) {
  esinfo[, GSI_VAR$var[i]] <- NA
}

for (i in 1:nrow(df_musicalexperience)) {
  idx <- esinfo$groupid == df_musicalexperience$groupid[i]
  
  for (j in 1:nrow(GSI_VAR)) {
    order_i <- GSI_MEASUREMENT$order[GSI_MEASUREMENT$var == GSI_VAR$var[j] & GSI_MEASUREMENT$value == df_musicalexperience[i, GSI_VAR$var[j]]]
    esinfo[idx, GSI_VAR$var[j]] <- order_i
  }
  
  esinfo$performer[idx] <- df_musicalexperience$performer[i]
}

esinfo$translatedCohensD <- sqrt(2)*qnorm(esinfo$diff)

esinfo <- esinfo[!is.na(esinfo[, GSI_VAR$var[1]]), ]

### Bayesian regression analysis
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

g_list <- vector(mode = 'list', length = dim(FEATURE)[1])

for (i in 1:dim(FEATURE)[1]) {
  idx = esinfo$feature == FEATURE$feature[i]
  df_data = data.frame(
    y = esinfo$translatedCohensD[idx],
    x1 = esinfo[idx, 10],
    x2 = esinfo[idx, 11],
    x3 = esinfo[idx, 12],
    x4 = esinfo[idx, 13],
    x5 = esinfo[idx, 14],
    x6 = esinfo[idx, 15],
    x7 = esinfo[idx, 16],
    x8 = esinfo[idx, 17]
  )
  
  prior_dirichlet = 
    prior(dirichlet(1, 1, 1, 1, 1, 1), class = "simo", coef = "mox11") + 
    prior(dirichlet(1, 1, 1, 1, 1, 1), class = "simo", coef = "mox21") + 
    prior(dirichlet(1, 1, 1, 1, 1, 1), class = "simo", coef = "mox31") +
    prior(dirichlet(1, 1, 1, 1, 1, 1), class = "simo", coef = "mox41") + 
    prior(dirichlet(1, 1, 1, 1, 1, 1), class = "simo", coef = "mox51") + 
    prior(dirichlet(1, 1, 1, 1, 1, 1), class = "simo", coef = "mox61") +
    prior(dirichlet(1, 1, 1, 1, 1, 1), class = "simo", coef = "mox71") + 
    prior(dirichlet(1, 1, 1, 1, 1, 1), class = "simo", coef = "mox81")
  
  glmmo_formula = bf(y ~ 0 + Intercept + mo(x1) + mo(x2) + mo(x3) + mo(x4) + mo(x5) + mo(x6) + mo(x7) + mo(x8))
  
  glmmo_prior =
    prior(normal(0, 2.5), class = "b", coef = "mox1") + 
    prior(normal(0, 2.5), class = "b", coef = "mox2") + 
    prior(normal(0, 2.5), class = "b", coef = "mox3") + 
    prior(normal(0, 2.5), class = "b", coef = "mox4") + 
    prior(normal(0, 2.5), class = "b", coef = "mox5") + 
    prior(normal(0, 2.5), class = "b", coef = "mox6") + 
    prior(normal(0, 2.5), class = "b", coef = "mox7") + 
    prior(normal(0, 2.5), class = "b", coef = "mox8") + 
    prior(normal(0, 2.5), class = "b", coef = "Intercept") + 
    prior_dirichlet + 
    prior(gamma(0.01, 0.01), class = "sigma")
  
  glmmo <- brm(
    formula = glmmo_formula,
    family = gaussian(link = "identity"),
    prior = glmmo_prior,
    data = df_data,
    seed = 1,
    chains = 6,
    iter = 3000,
    warmup = 1500,
    thin = 1
  )
  
  pstr_i = posterior_summary(glmmo)
  df_pstr_CI = c()
  df_pstr_pe = c()
  for (j in 1:9) {
    df_pstr_CI = rbind(
      df_pstr_CI,
      data.frame(x = c(pstr_i[j, 3], pstr_i[j, 4]), y = c(row.names(pstr_i)[j], row.names(pstr_i)[j]), feature = FEATURE$featurename[i])
    )
    
    df_pstr_pe = rbind(
      df_pstr_pe,
      data.frame(x = pstr_i[j, 1], y = row.names(pstr_i)[j], feature = FEATURE$featurename[i])
    )
  }
  
  ### Plot 
  g_list[[i]] <- ggplot() + 
    geom_line(data = df_pstr_CI, aes(x = x, y = y)) +
    geom_point(data = df_pstr_pe, aes(x = x, y = y), color = "#DD2350") +
    geom_vline(xintercept = 0, linetype="dotdash") +
    labs(x = "", y = "", title = paste("Effect for ", FEATURE$featurename[i], " difference\n(Singing vs. Spoken description)", sep = "")) +
    theme(plot.title = element_text(hjust = 0.5)) + 
    scale_y_discrete(labels = c("Intercept", GSI_VAR$desc))
  
  ggsave(filename = paste("./output/figure/Stage2/ES-gmsi_", FEATURE$featurename[i], ".png", sep = ""),
         plot = g_list[[i]], width = 5, height = 4)
}