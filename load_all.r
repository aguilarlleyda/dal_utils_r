#source globals first
source("R/globals.R")

#source function files
files <- list.files("R", full.names = TRUE, pattern = "\\.r$")
files <- files[!grepl("globals\\.r$", files)]  #exclude already loaded globals
sapply(files, source)