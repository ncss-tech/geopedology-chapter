library(aqp)
library(lattice)


p <- contrastChart(m = '7.5YR 4/3', hues = c('5YR', '7.5YR', '10YR'))
p <- update(p, scales = list(cex = 1))


svglite::svglite(filename = 'figures/contast-chart.svg', width = 15, height = 6.8)
print(p)
dev.off()

