rrcache <- NULL # nocov start
.onLoad <- function(libname, pkgname) {
  x <- hoardr::hoard()
  x$cache_path_set('rerddap')
  rrcache <<- x
} # nocov end
