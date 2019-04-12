# get metadata and data -----------------------
ncdf4_get <- function(file){
  nc <- ncdf4::nc_open(file)
  on.exit(ncdf4::nc_close(nc))
  tmp <- unclass(nc)

  dims <- names(nc$dim)

  # check if likely on a lat/lon grid, or not; if not, throw message
  if (
    !any(c('lat', 'latitude') %in% dims) && 
    !any(c('lon', 'longitude') %in% dims)
  ) {
    warning("data not on lat/lon grid - not reading in data; see help")
    return(list(summary = tmp, data = data.frame(NULL)))
  }

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

  if (length(out$time) == 0) {
    out$time <- NULL
    exout <- do.call("expand.grid", out)
    meta <- dplyr::arrange_(exout, names(exout)[1])
  } else {
    time <- suppressWarnings(rep(out$time, each = rows/length(out$time)))
    lat <- rep(rep(out$latitude, each = length(out$longitude)),
               length(out$time))
    lon <- rep(rep(out$longitude, times = length(out$latitude)),
               times = length(out$time))
    # check for other dimensions besides time,lat,lon
    tll <- c("time", "latitude", "longitude")
    remain_out <- list()
    if (!all(names(out) %in% tll)) {
      remain <- out[!names(out) %in% tll]
      remain_out <- list()
      for (i in seq_along(remain)) {
        result <- rep(remain[[i]],
          each = length(out$longitude) * length(out$latitude))
        remain_out[[ names(remain)[i] ]] <- result
      }
    }
    meta <- data.frame(time, lat, lon, stringsAsFactors = FALSE)
    if (length(remain_out) != 0) {
      for (i in seq_along(remain_out)) 
        meta[[names(remain_out)[i]]] <- remain_out[[i]]
    }
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
