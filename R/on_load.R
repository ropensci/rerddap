rrcache <- NULL # nocov start
.onLoad <- function(libname, pkgname) {
  x <- hoardr::hoard()
  x$cache_path_set(path = 'rerddap', type = 'tempdir')
  rrcache <<- x
} # nocov end
