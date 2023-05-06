##
library(irr)
library(ggplot2)

##
ANNOTATIONDIR_YO <- "./data/Stage 2 Annotation/"
ANNOTATIONDIR_PES <- "./data/Stage 2 Annotation (10second-onset-PES)/"

DATAID <- c('Javier_SilvaZurita_Chilean_Traditional_Song_20221009',
            'Adam_Tierney_English_Traditional_SimpleGifts_20230129',
            'Jehoshaphat_Philip Sarbah_Twi_Traditional_daa na se_20230327',
            'Manuel_Anglada-Tort_Catalan_Traditional_LaPresódeLleida_20221108',
            'Minyu_Zeng_HainanHua_Traditional_The Song of the Five-Fingers Mountain_20221009',
            'Shantala_Hegde_Kannada_Traditional_Moodala Maneya_20220214',
            'VanessaNina_Borsan_Slovenian_Traditional_EnHribčekBomKupil_20221027',
            'Wojciech_Krzyżanowski_Polish_Traditional_Wlazł Kotek Na Płotek_20221022')
PLOTNAME <- c("JSZ", "AT", "JPS", "MAT", "MZ", "SH", "VB", "WK")
LANG <- c("Chilean", "English", "Twi", "Catalan", "HainanHua", "Kannada", "Slovenian", "Polish")
TYPE <- c("desc", "song")

TITLE <- c("song" = "Song", "desc" = "Spoken description")

LANGCOLORMAP <- read.csv("./data/LangColorMap.csv")
LANGCOLORMAP$rgb <- paste("#", LANGCOLORMAP$rgb, sep = "")

##
icc_result <- c()
df_dlt <- c()

for (i in 1:length(DATAID)) {
  for (j in 1:length(TYPE)) {
    ## ICC
    df <- read.csv(paste(ANNOTATIONDIR_YO, "onset_", DATAID[i], "_", TYPE[j], ".csv", sep= ""), header = FALSE)
    X <- df$V1[df$V1 <= 10.1]
    
    df <- read.csv(paste(ANNOTATIONDIR_PES, "onset_", DATAID[i], "_", TYPE[j], ".csv", sep= ""), header = FALSE)
    Y <- df$V1[df$V1 <= 10.1]
    
    result <- icc(data.frame(onset_1 = X, onset_2 = Y), mode = "twoway", type = "agreement", unit = "single")
    std_diff <- sqrt(var(X - Y)*(length(X) - 1)/length(X))
    mu_diff <- mean(abs(X - Y))
    
    icc_result <- rbind(icc_result,
                        data.frame(dataid = DATAID[i], type = TYPE[j], icc = result$value, pvalue = result$p.value,
                                   N = result$subjects, mu_dlt = mu_diff, sgm_dlt = std_diff))
    
    ## plot data
    df_dlt <- rbind(df_dlt, data.frame(dlt = X - Y, type = TYPE[j], dataid = PLOTNAME[i], lang = LANG[i]))
  }
}

##
print(icc_result)
write.table(icc_result, file = paste(OUTPUTDIR, "icc.csv", sep = ""), row.names = FALSE, sep = ",")

##
YL <- c(min(df_dlt$dlt), max(df_dlt$dlt))

for (j in 1:length(TYPE)) {
  g <- ggplot(data = df_dlt[df_dlt$type == TYPE[j], ], aes(x = dataid, y = dlt)) + 
    geom_violin(aes(group = dataid), draw_quantiles = 0.5) + 
    geom_point(aes(color = lang)) + 
    guides(color = "none") + 
    xlab("Collaborator") + ylab("Onset difference [sec.]\n(diff = YO - PES)") + ggtitle(paste(TITLE[TYPE[j]], "(10 seconds)")) + 
    theme_gray() +
    theme(plot.title = element_text(face = "bold", hjust = 0.5)) +
    scale_color_manual(values = LANGCOLORMAP$rgb, breaks = LANGCOLORMAP$lang_filename) + 
    ylim(YL)
  
  ggsave(file = paste(OUTPUTDIR, "onsetdiff_", TYPE[j], ".png", sep = ""),
         plot = g, width = 4, height = 3)
}