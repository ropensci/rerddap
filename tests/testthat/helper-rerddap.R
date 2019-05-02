# set up vcr
library("vcr")
invisible(vcr::vcr_configure(dir = "../vcr_cassettes"))

only_ascii <- function(path) {
  path <- file.path("../vcr_cassettes", paste0(path, ".yml"))
  z <- tryCatch(suppressMessages(tools::showNonASCIIfile(path)), 
    error = function(e) e)
  if (inherits(z, "error")) {
    testthat::skip("fixture file not found")
  }
  length(z) == 0
}

skip_if_non_ascii <- function(path) {
  if (only_ascii(path)) {
    return()
  }
  testthat::skip("non ascii text in fixture, skipping")
}
