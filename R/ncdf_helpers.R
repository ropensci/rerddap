# ncdf helper functions -----------------------
# get metadata and data -----------------------
# ncdf
ncdf_get <- function(file){
  nc <- open.ncdf(file)
  dims <- names(nc$dim)
  out <- list()
  for (i in seq_along(dims)) {
    out[[dims[i]]] <- get.var.ncdf(nc, nc$dim[[dims[i]]])
  }
  out$time <- sapply(out$time, convert_time)
  vars <- names(nc$var)
  outvars <- list()
  for (i in seq_along(vars)) {
    outvars[[ vars[i] ]] <- as.vector(get.var.ncdf(nc, vars[i]))
  }
  df <- do.call("cbind.data.frame", outvars)
  rows <- length(outvars[[1]])
  # dimdat <- lapply(out, function(z) rep(z, each = rows/length(z)))
  # meta <- data.frame(dimdat, stringsAsFactors = FALSE)
  time <- rep(out$time, each = rows/length(out$time))
  # lat <- rep(rep(out$latitude, each = length(out$latitude)), times = length(out$time))
  # lon <- rep(rep(out$longitude, times = length(out$longitude)), times = length(out$time))
  lat <- rep(rep(out$latitude, each = length(out$longitude)), length(out$time))
  lon <- rep(rep(out$longitude, times = length(out$latitude)), times = length(out$time))
  meta <- data.frame(time, lat, lon, stringsAsFactors = FALSE)
  alldf <- cbind(meta, df)
  invisible(close.ncdf(nc))
  list(summary = nc, data = alldf)
}

# ncdf4
ncdf4_get <- function(file){
  check4ncdf4()
  nc <- ncdf4::nc_open(file)
  tmp <- unclass(nc)

  dims <- names(nc$dim)
  out <- list()
  for (i in seq_along(dims)) {
    out[[dims[i]]] <- ncdf4::ncvar_get(nc, nc$dim[[dims[i]]])
  }
  out$time <- sapply(out$time, convert_time)
  vars <- names(nc$var)
  outvars <- list()
  for (i in seq_along(vars)) {
    outvars[[ vars[i] ]] <- as.vector(ncdf4::ncvar_get(nc, vars[i]))
  }
  df <- do.call("cbind.data.frame", outvars)
  rows <- length(outvars[[1]])
  # out <- lapply(out, function(z) rep(z, each = rows/length(z)))
  # meta <- data.frame(out, stringsAsFactors = FALSE)
  time <- rep(out$time, each = rows/length(out$time))
  # lat <- rep(rep(out$latitude, each = length(out$latitude)), times = length(out$time))
  # lon <- rep(rep(out$longitude, times = length(out$longitude)), times = length(out$time))
  lat <- rep(rep(out$latitude, each = length(out$longitude)), length(out$time))
  lon <- rep(rep(out$longitude, times = length(out$latitude)), times = length(out$time))
  meta <- data.frame(time, lat, lon, stringsAsFactors = FALSE)
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
