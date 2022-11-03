library(magick)

## TODO: mojibake in rotated text (in lattice graphics), 
# may have to convert by hand


f <- list.files(path = 'figures', pattern = '\\.svg', full.names = TRUE)


convert2PNG <- function(i, .density = 300) {
  
  # source SVG
  # increase density argument for higher-res rendering
  .im <- image_read(i, density = .density)
  
  # convert -> PNG
  .im2 <- image_convert(.im, format = 'png', antialias = TRUE)
  
  # output file
  .of <- gsub(pattern = '.svg', replacement = '.png', x = i, fixed = TRUE)
  
  # save
  image_write(.im2, path = .of, format = 'png', flatten = TRUE)
  
}

sapply(f, convert2PNG)

## higher res versions 
convert2PNG('figures/cross-section.svg', .density = 300)

## Note: cross-section figure must be manually cropped


