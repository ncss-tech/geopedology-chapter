library(aqp)
library(lattice)
library(soilDB)


p <- contrastChart(m = '7.5YR 4/3', hues = c('5YR', '7.5YR', '10YR'))
p <- update(p, scales = list(cex = 1))


svglite::svglite(filename = 'figures/contast-chart.svg', width = 15, height = 6.8)
print(p)
dev.off()


contrastChart(m = '7.5YR 4/3', hues = '7.5YR')
contrastChart(m = '7.5YR 4/3', hues = c('5YR', '7.5YR', '10YR'))

p <- contrastChart(m = '7.5YR 4/3', hues = c('5YR', '7.5YR'), style = 'CC')
latticeExtra::useOuterStrips(p, strip.left = strip.custom(bg = grey(0.85)), strip = strip.custom(bg = grey(0.85)))

p


p <- contrastChart(m = '7.5YR 4/3', hues = c('5YR', '7.5YR', '10YR', '7.5Y'), thresh = 15)
update(p, sub = 'color chips with dE00(7.5YR 4/3) < 15')


##
##



s <- 'musick'
x <- fetchOSD(s, colorState = 'dry')
y <- fetchOSD(s, colorState = 'moist')

idx <- 2:8
x <- x[, idx]
y <- y[, idx]

m1 <- sprintf("%s %s/%s", x$hue, x$value, x$chroma)
m2 <- sprintf("%s %s/%s", y$hue, y$value, y$chroma)

cc <- colorContrast(m1, m2)

svglite::svglite(filename = 'figures/contrast-class-dE00.svg', width = 10, height = 3.5)
colorContrastPlot(m1, m2, labels=c('Dry', 'Moist'), d.cex = 1, col.cex = 1)
dev.off()

# caption with hz designation
x$hzname


