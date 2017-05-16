library("testthat")
library("rerddap")

#Sys.setenv(RERDDAP_CACHE_PATH_SUFFIX = "rerddap")
cache_setup(temp_dir = TRUE)

test_check("rerddap")
