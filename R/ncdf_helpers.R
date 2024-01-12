# get metadata and data -----------------------
ncdf4_get <- function(file){
  nc <- ncdf4::nc_open(file)
  on.exit(ncdf4::nc_close(nc))
  tmp <- unclass(nc)

  dims <- names(nc$dim)

  lat_name = ifelse('lat' %in% dims, 'lat', 'latitude')
  lon_name = ifelse('lon' %in% dims, 'lon', 'longitude')
  out <- list()
  for (i in seq_along(dims)) {
    out[[dims[i]]] <- ncdf4::ncvar_get(nc, nc$dim[[dims[i]]])
  }
  if ('time' %in% names(out)){
    out$time <- sapply(out$time, convert_time)
    
  }
  vars <- names(nc$var)
  outvars <- list()
  for (i in seq_along(vars)) {
    outvars[[ vars[i] ]] <- as.vector(ncdf4::ncvar_get(nc, vars[i]))
  }
  df <- do.call("cbind.data.frame", outvars)
  rows <- length(outvars[[1]])

  out <- out[length(out):1]
  meta <- expand.grid(out, stringsAsFactors = FALSE)
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
