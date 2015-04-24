# ncdf helper functions -----------------------
# get metadata and data -----------------------
# ncdf
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
  list(summary = nc, data = alldf)
}

# ncdf4
ncdf4_get <- function(file){
  check4ncdf4()
  nc <- ncdf4::nc_open(file)
  tmp <- unclass(nc)
  lat <- ncdf4::ncvar_get(nc, "latitude")
  long <- ncdf4::ncvar_get(nc, "longitude")
  time <- sapply(ncdf4::ncvar_get(nc, "time"), convert_time)
  vars <- names(nc$var)
  outvars <- list()
  for (i in seq_along(vars)) {
    outvars[[ vars[i] ]] <- as.vector(ncdf4::ncvar_get(nc, vars[i]))
  }
  df <- do.call("cbind.data.frame", outvars)
  rows <- length(outvars[[1]])
  meta <- data.frame(time = rep(time, each = rows/length(time)),
                     lat = rep(lat, each = rows/length(lat)),
                     long = rep(long, each = rows/length(long)),
                     stringsAsFactors = FALSE)
  alldf <- cbind(meta, df)
  on.exit(ncdf4::nc_close(nc))
  list(summary = tmp, data = alldf)
}

# get just metadata -----------------------
# ncdf
ncdf_summary <- function(file){
  nc <- open.ncdf(file, readunlim = FALSE)
  invisible(close.ncdf(nc))
  list(summary = nc, data = data.frame(NULL))
}

# ncdf4
ncdf4_summary <- function(file){
  check4ncdf4()
  nc <- ncdf4::nc_open(file, readunlim = FALSE)
  tmp <- unclass(nc)
  on.exit(ncdf4::nc_close(nc))
  list(summary = tmp, data = data.frame(NULL))
}

# check for ncdf4
check4ncdf4 <- function() {
  if (!requireNamespace("ncdf4", quietly = TRUE)) {
    stop("Please install ncdf4", call. = FALSE)
  }
}
