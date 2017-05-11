library("testthat")
library("rerddap")

Sys.setenv(RERDDAP_CACHE_PATH_SUFFIX = "rerddap")

test_check("rerddap")
