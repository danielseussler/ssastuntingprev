# script
#
# compile all data from the Madagascar 2021 DHS to one usable file
# a guide to how to compile statistics can be found in 
# https://dhsprogram.com/data/Guide-to-DHS-Statistics/index.htm#t=Nutritional_Status.htm&rhsearch=stunting&rhhlterm=stunting&rhsyns=%20

library(data.table)
library(sf)

surveydata = readRDS(file = file.path("data", "raw", "rdhs", "MDPR81FL.rds"))
surveydata = as.data.table(surveydata)

selectvars = c("hv000", "hv001", "hv002", "hv005", "hv023", "hv024", "hv025", "hv103", "hc1", "hc70")
surveydata = surveydata[, ..selectvars]

surveydata[, hc70 := as.numeric(hc70)]
surveydata = haven::as_factor(surveydata, only_labelled = TRUE)

surveydata = surveydata[hv103 == "yes" & hc1 %in% 1:59 & hc70 < 9990]

surveydata[, stunted := as.integer(hc70 < -200)]
surveydata[, svyweight := hv005 / 1e6]
surveydata[, householdid := as.factor(paste0(hv001, "C", hv002))]

setnames(surveydata, "hv001", "clusterid")
setnames(surveydata, "hv023", "strata")
setnames(surveydata, "hv024", "region")
setnames(surveydata, "hv025", "urban")

surveydata[, region := stringr::str_to_title(region)]
surveydata[, region := as.factor(region)]

# create matrix for conditional autoregressive model
madagascar_shp = rgdal::readOGR(dsn = file.path("data/raw/sdr_subnational_boundaries_2022-11-26_madagascar_2021_dhs/sdr_subnational_boundaries.shp"))
dhsregions_mat = bamlss::neighbormatrix(x = madagascar_shp, names = "DHSREGEN")

translate_names = data.frame(
  region = sort(unique(levels(surveydata$region)))
  , dhsregions = sort(colnames(dhsregions_mat))
)

colnames(dhsregions_mat)

colnames(dhsregions_mat) = 
  rownames(dhsregions_mat) = 
  translate_names$region[match(colnames(dhsregions_mat), translate_names$dhsregions)]

save(surveydata, dhsregions_mat, file = file.path("data", "processed", "MD2021DHS.rda"))
