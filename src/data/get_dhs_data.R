# script 
#
# download microdata from the Madagascar 2021 Standard DHS survey
# survey data access has to be requested at dhsprogram.com

library(rdhs)
library(data.table)

surveys = dhs_surveys(surveyIds = "MD2021DHS")
surveys

datasets = dhs_datasets(surveyIds = surveys$SurveyId, fileType = c("PR", "KR", "GE"), fileFormat = "flat")
datasets[, .(SurveyId, FileType, SurveyNum, FileDateLastModified, FileName)]

get_datasets(
  dataset_filenames = datasets$FileName
  , output_dir_root = file.path("data", "raw", "rdhs")
  , reformat = FALSE
)

get_downloaded_datasets() # check files were saved in correct folder