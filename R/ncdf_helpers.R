# get metadata and data -----------------------
ncdf4_get <- function(file){
  nc <- ncdf4::nc_open(file)
  on.exit(ncdf4::nc_close(nc))
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

  ## FIXME - generalize to expand whatever variables are in the out list
  #out2 <- out
  #out2$time <- NULL
  # meta <- do.call("expand.grid", out)
  # if ("time" %in% names(meta)) meta <- dplyr::arrange_(meta, "time", "desc(latitude)")

  if (length(out$time) == 0) {
    out$time <- NULL
    exout <- do.call("expand.grid", out)
    meta <- dplyr::arrange_(exout, names(exout)[1])
  } else {
    time <- suppressWarnings(rep(out$time, each = rows/length(out$time)))
    lat <- rep(rep(out$latitude, each = length(out$longitude)), length(out$time))
    lon <- rep(rep(out$longitude, times = length(out$latitude)), times = length(out$time))
    meta <- data.frame(time, lat, lon, stringsAsFactors = FALSE)
  }

  # make data.frame
  alldf <- if (NROW(meta) > 0) cbind(meta, df) else df

  # output
  list(summary = tmp, data = alldf)
}

# get just metadata -----------------------
ncdf_summary <- function(file) {
  nc <- ncdf4::nc_open(file, readunlim = FALSE)
  tmp <- unclass(nc)
  on.exit(ncdf4::nc_close(nc))
  list(summary = tmp, data = data.frame(NULL))
}
