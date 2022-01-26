library(munsell)
library(munsellinterpol)
library(aqp)
library(farver)

m <- '10YR 4/6'

# identical
parseMunsell(m)
munsell::mnsl2hex(m)


parseMunsell(m, return_triplets = TRUE)

munsellinterpol::MunsellTosRGB(m, maxSignal = 1)

munsellinterpol::MunsellTosRGB('10YR 4.4/6.6', maxSignal = 1)



compare_colour(
  from = cbind(0.504304, 0.3518937, 0.1301201) * 255, 
  to = cbind(0.4985223, 0.3475911, 0.1283604) * 255, 
  white_from = 'D65', white_to = 'D65', 
  method = 'CIE2000', 
  from_space = 'rgb'
)




