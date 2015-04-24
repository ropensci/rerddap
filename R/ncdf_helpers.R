# file to read netcdf data files
#' @import ncdf
ncdf_get <- function(file){
  nc <- open.ncdf(file)
  lat <- get.var.ncdf(nc, "latitude")
  long <- get.var.ncdf(nc, "longitude")
  time <- sapply(get.var.ncdf(nc, "time"), convert_time)
  vars <- names(nc$var)
  outvars <- list()
  for (i in seq_along(vars)) {
    outvars[[ vars[i] ]] <- as.vector(get.var.ncdf(nc, vars[i]))
  }
  df <- do.call("cbind.data.frame", outvars)
  rows <- length(outvars[[1]])
  meta <- data.frame(time = rep(time, each = rows/length(time)),
                     lat = rep(lat, each = rows/length(lat)),
                     long = rep(long, each = rows/length(long)),
                     stringsAsFactors = FALSE)
  alldf <- cbind(meta, df)
  invisible(close.ncdf(nc))
  alldf
}

ncdf_summary <- function(file){
  nc <- open.ncdf(file, readunlim = FALSE)
  invisible(close.ncdf(nc))
  nc
}
