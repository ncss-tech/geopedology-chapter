library(aqp)
library(soilDB)
# library(DBI)
# library(RSQLite)

## recent snapshot, requires more work to consolidate properties
# db <- dbConnect(RSQLite::SQLite(), 'E:/NASIS-KSSL-LDM/LDM/LDM-compact.sqlite')
# 
# qq <- "
# SELECT
# hzn_top, hzn_bot, hzn_desgn, sand_total AS sand, silt_total AS silt, clay_total AS clay
# FROM layer
# JOIN physical ON layer.labsampnum = physical.labsampnum
# WHERE hzn_desgn LIKE 'B%x%' 
# ;"
# 
# # run query
# bx <- dbGetQuery(db, qq)
# 
# # close connection
# dbDisconnect(db)
# 


sql <- "
SELECT
pedon_key, pedlabsampnum, pedoniid, upedonid, longitude_decimal_degrees, latitude_decimal_degrees,
CASE WHEN corr_name IS NULL THEN samp_name ELSE corr_name END AS taxonname
FROM
lab_combine_nasis_ncss
WHERE CASE WHEN corr_name IS NULL THEN samp_name ELSE corr_name END = 'clarksville'

;"

pedons <- SDA_query(sql)

# 171
nrow(pedons)

## TODO
# get layer, physical, chemical data




# older snapshot, simpler packaging
# 166
s <- fetchKSSL(series = 'clarksville', returnMorphologicData = TRUE, simplifyColors = TRUE)
length(s)
x <- s$SPC

saveRDS(x, file = 'clarksville-all-KSSL.rds')


## All clarksville NASIS pedons
x <- fetchNASIS(from = 'pedons', SS = TRUE, rmHzErrors = TRUE, nullFragsAreZero = TRUE, soilColorState = 'moist', lab = FALSE, fill = FALSE)

saveRDS(x, file = 'clarksville-all-pedons.rds')




