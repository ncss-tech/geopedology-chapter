library(magick)

## TODO: mojibake in rotated text (in lattice graphics), 
# may have to convert by hand


f <- list.files(path = 'figures', pattern = '\\.svg', full.names = TRUE)


convert2PNG <- function(i) {
  
  # source SVG
  # increase density argument for higher-res rendering
  .im <- image_read(i, density = 120)
  
  # convert -> PNG
  .im2 <- image_convert(.im, format = 'png', antialias = TRUE)
  
  # output file
  .of <- gsub(pattern = '.svg', replacement = '.png', x = i, fixed = TRUE)
  
  # save
  image_write(.im2, path = .of, format = 'png', flatten = TRUE)
  
}

sapply(f, convert2PNG)

