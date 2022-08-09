##
library("ggplot2")
library("sf")
library("rnaturalearth")
library("rnaturalearthdata")
library("grid")
library("gridExtra")

##
INTERVAL <- 5

##
collabT_full <- read.csv('./data/CollaboratorsTable.csv')
collabT <- collabT_full[collabT_full$Confirmed == 'Y', ]

langlabel <- unique(data.frame(Lang = collabT$Native.fluent.language.name.by.collaborator,
                               Family = collabT$Language.family.according.to.Glottolog,
                        Longitude = collabT$Longitude, Latitude = collabT$Latitude, ID = 0))
idx <- sort(langlabel$Family, decreasing = FALSE, index=T)$ix
langlabel <- langlabel[idx, ]
langlabel$ID <- 1:nrow(langlabel)

dodge <- TRUE
while (dodge) {
  dodge <- FALSE
  
  for (i in 1:nrow(langlabel)) {
    fun_i <- function(x) sqrt(sum((as.numeric(x) - as.numeric(langlabel[i, 3:4]))^2))
    d <- apply(langlabel[, 3:4], MARGIN = 1, FUN = fun_i)
    
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
  geom_sf(color = "black", fill = "blue") +
  geom_point(data = langlabel, aes(x=Longitude, y=Latitude),
             size = 3.6, shape = 21, fill = "white") +
  geom_text(data = langlabel, aes(x=Longitude, y=Latitude, label=ID),
            size = 2.2, color = "darkblue", check_overlap = FALSE) + 
  xlab("") + ylab("") + ylim(c(-60.5, 75)) + 
  theme(axis.ticks.x = element_blank(), axis.text.x = element_blank())

##
FamilyList <- unique(langlabel$Family)
langtable <- vector(mode = "list", length = length(FamilyList))
for (i in 1:length(FamilyList)) {
  idx <- langlabel$Family == FamilyList[i]
  langtable[[i]] <- tableGrob(cbind(langlabel[idx, 5], langlabel[idx, 1]))
}

##
g <- grid.arrange(grobs = langtable, nrow = 3, ncol = 6)

##
ggsave(file = "./output/CollabMap.png", plot = gobj, width = 8, height = 7)