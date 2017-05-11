rrcache <- NULL
.onLoad <- function(libname, pkgname) {
  rrcache <<- hoardr::hoard()
}
