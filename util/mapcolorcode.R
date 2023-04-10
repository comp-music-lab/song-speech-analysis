T <- read.csv("../data/LangColorMap.csv")
langfamilyset <- sort(unique(T$family))

ggColorHue <- function(n, l=65) {
  hues <- seq(15, 375, length=n+1)
  hcl(h=hues, l=l, c=100)[1:n]
}

cols <- ggColorHue(n = length(langfamilyset))

for (i in 1:length(langfamilyset)) {
  idx <- T$family == langfamilyset[i]
  T$rgb[idx] <- cols[i]
}

write.csv(file = "../data/LangColorMap.csv", T)