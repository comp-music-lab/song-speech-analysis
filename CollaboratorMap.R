##
library(ggplot2)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(gridExtra)
library(grid)

##
INTERVAL <- 6

##
collabT <- read.csv('./data/CollaboratorsPlotData.csv')

langlabel <- data.frame(Lang = collabT$ProvidedLanguageName,
                        LangAdditional = collabT$GlottologL1Name,
                        Family = collabT$LanguageFamily,
                        Longitude = collabT$Longitude,
                        Latitude = collabT$Latitude,
                        Place = collabT$PlaceName,
                        Flag = collabT$Choice,
                        ID = 0)

langlabel$Lang[langlabel$Lang == "Hebrew"] <- langlabel$LangAdditional[langlabel$Lang == "Hebrew"]
langlabel$Lang[langlabel$Lang == "Amami dialect"] <- langlabel$LangAdditional[langlabel$Lang == "Amami dialect"]
langlabel$Lang[langlabel$Lang == "Arabic"] <- langlabel$LangAdditional[langlabel$Lang == "Arabic"]
langlabel$Lang[langlabel$Lang == "Persian"] <- langlabel$LangAdditional[langlabel$Lang == "Persian"]
langlabel$Lang[langlabel$Lang == "Farsi"] <- langlabel$LangAdditional[langlabel$Lang == "Farsi"]
langlabel$Lang[langlabel$Lang == "Euskera (Basque)"] <- langlabel$LangAdditional[langlabel$Lang == "Euskera (Basque)"]
langlabel$Lang[langlabel$Lang == "Brazilian Portuguese"] <- langlabel$LangAdditional[langlabel$Lang == "Portuguese"]

langlabel <- langlabel[order(langlabel$Family, langlabel$Lang, langlabel$Place), ]
langlabel <- langlabel[langlabel$Flag == 1, ]
langlabel$ID <- 1:nrow(langlabel)

dodge <- TRUE
while (dodge) {
  dodge <- FALSE
  
  for (i in 1:nrow(langlabel)) {
    fun_i <- function(x) sqrt(sum((as.numeric(x) - as.numeric(langlabel[i, 4:5]))^2))
    d <- apply(langlabel[, 4:5], MARGIN = 1, FUN = fun_i)
    
    st <- sort(d, decreasing = FALSE, index = TRUE)
    d_st <- st$x
    idx <- st$ix
    
    j <- 2
    if (d_st[j] < INTERVAL) {
      dir <- sign(langlabel$Latitude[i] - langlabel$Latitude[idx[j]])
      if (dir == 0) {
        dir <- 1
      }
      langlabel$Latitude[i] <- langlabel$Latitude[i] + sqrt(INTERVAL + 1)*dir
      
      dir <- sign(langlabel$Longitude[i] - langlabel$Longitude[idx[j]])
      if (dir == 0) {
        dir <- 1
      }
      langlabel$Longitude[i] <- langlabel$Longitude[i] + sqrt(INTERVAL + 1)*dir
      
      dodge <- TRUE
    }
  }
}

print("dodging...OK")

##
theme_set(theme_bw())
world <- ne_countries(scale = "medium", returnclass = "sf")

##
gobj<- ggplot(data = world) +
  geom_sf(fill= "darkolivegreen1") +
  geom_point(data = langlabel, aes(x = Longitude, y = Latitude, fill = Family),
             size = 3.6, shape = 21) +
  geom_text(data = langlabel, aes(x=Longitude, y=Latitude, label=ID),
            size = 2.2, color = "darkblue", check_overlap = FALSE) + 
  xlab("") + ylab("") + ylim(c(-50.5, 75)) + 
  theme(axis.ticks.x = element_blank(), axis.text.x = element_blank(), legend.title = element_blank()) +
  theme(panel.background = element_rect(fill = "aliceblue"))

##
FamilyList <- unique(langlabel$Family)
langtable <- vector(mode = "list", length = length(FamilyList))
for (i in 1:length(FamilyList)) {
  idx <- langlabel$Family == FamilyList[i]
  langtable[[i]] <- tableGrob(cbind(langlabel[idx, 5], langlabel[idx, 1]))
}

##
ggsave(file = "./output/CollabMap.png", plot = gobj, width = 8, height = 7)

##
ggColorHue <- function(n, l=65) {
  hues <- seq(15, 375, length=n+1)
  hcl(h=hues, l=l, c=100)[1:n]
}

cols <- ggColorHue(n = length(unique(langlabel$Family)))
col2rgb(cols)
scales::show_col(cols)