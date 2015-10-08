.onLoad <- function(libname, pkgname) {
  op <- options()
  op.rerddap <- list(
    rerddap.digits = 10L
  )
  toset <- !(names(op.rerddap) %in% names(op))
  if (any(toset)) options(op.rerddap[toset])

  options(digits = getOption("rerddap.digits"))

  invisible()
}
