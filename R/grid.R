#' Get ERDDAP griddap data.
#'
#' @export
#'
#' @param x Anything coercable to an object of class info. So the output of a call to
#' \code{\link{info}}, or a datasetid, which will internally be passed through
#' \code{\link{info}}
#' @param ... Dimension arguments. See examples. Can be any 1 or more of the dimensions
#' for the particular dataset - and the dimensions vary by dataset. For each dimension,
#' pass in a vector of length two, with min and max value desired.
#' @param fields (character) Fields to return, in a character vector.
#' @param stride (integer) How many values to get. 1 = get every value, 2 = get
#' every other value, etc. Default: 1 (i.e., get every value)
#' @param fmt (character) One of csv or nc (for netcdf). Default: nc
#' @param ncdf (character) One of ncdf or ncdf4. If ncdf, use the package
#' \code{\link{ncdf}} to read netcdf files. If ncdf4, use the package
#' \code{ncdf4}. \code{\link{ncdf}} package is required for this package to be
#' installed, and should be easily installable across platforms. However, \code{ncdf4}
#' is likely not installable on Windows OS's. Ignored if \code{fmt = "csv"}. Default: ncdf
#' @param url A URL for an ERDDAP server. Default: \url{http://upwell.pfeg.noaa.gov/erddap/}
#' @param store One of \code{\link{disk}} (default) or \code{\link{memory}}. You
#' can pass options to \code{\link{disk}}
#' @param read (logical) Read data into memory or not. Does not apply when \code{store}
#' parameter is set to memory (which reads data into memory). For large csv, or
#' especially netcdf files, you may want to set this to \code{FALSE}, which simply
#' returns a summary of the dataset - and you can read in data piecemeal later.
#' Default: \code{TRUE}
#' @param callopts Pass on curl options to \code{\link[httr]{GET}}
#'
#' @return An object of class \code{griddap_csv} if csv chosen or \code{griddap_nc}
#' if nc file format chosen. These two classes are a thin wrapper around a data.frame,
#' so the data you get back is a data.frame with metadata attached as
#' attributes, along with a summary of the netcdf file (if \code{fmt="nc"}). If
#' \code{read=FALSE}, you get back an empty data.frame.
#'
#' @details Details:
#'
#' @section Dimensions and Variables:
#' ERDDAP grid dap data has this concept of dimenions vs. variables. Dimensions are things
#' like time, latitude, longitude, altitude, and depth. Whereas variables are the measured
#' variables, e.g., temperature, salinity, air.
#'
#' You can't separately adjust values for dimensions for different variables. So, here's
#' how it's gonna work:
#'
#' Pass in lower and upper limits you want for each dimension as a vector (e.g., \code{c(1,2)}),
#' or leave to defaults (i.e., don't pass anything to a dimension). Then pick which variables
#' you want returned via the \code{fields} parameter. If you don't pass in options to the
#' \code{fields} parameter, you get all variables back.
#'
#' To get the dimensions and variables, along with other metadata for a dataset, run
#' \code{\link{info}}, and each will be shown, with their min and max values, and some
#' other metadata.
#'
#' @section Where does the data go?:
#' You can choose where data is stored. Be careful though. You can easily get a
#' single file of hundreds of MB's (upper limit: 2 GB) in size with a single request.
#' To the \code{store} parameter, pass \code{\link{memory}} if you want to store the data
#' in memory (saved as a data.frame), or pass \code{\link{disk}} if you want to store on
#' disk in a file. Note that \code{\link{memory}} and \code{\link{disk}} are not
#' character strings, but function calls. \code{\link{memory}} does not accept any
#' inputs, while \code{\link{disk}} does. Possibly will add other options, like
#' \dQuote{sql} for storing in a SQL database.
#'
#' @references  \url{http://upwell.pfeg.noaa.gov/erddap/rest.html}
#' @author Scott Chamberlain <myrmecocystus@@gmail.com>
#' @examples \dontrun{
#' # single variable dataset
#' ## You can pass in the outpu of a call to info
#' (out <- info('noaa_esrl_027d_0fb5_5d38'))
#' (res <- griddap(out,
#'  time = c('2012-01-01','2012-06-12'),
#'  latitude = c(21, 18),
#'  longitude = c(-80, -75)
#' ))
#' ## Or, pass in a dataset id
#' (res <- griddap('noaa_esrl_027d_0fb5_5d38',
#'  time = c('2012-01-01','2012-06-12'),
#'  latitude = c(21, 18),
#'  longitude = c(-80, -75)
#' ))
#'
#' # multi-variable dataset
#' (out <- info('noaa_gfdl_5081_7d4a_7570'))
#' (res <- griddap(out,
#'  time = c('2005-11-01','2006-01-01'),
#'  latitude = c(20, 21),
#'  longitude = c(10, 11),
#'  read = FALSE
#' ))
#' (res <- griddap(out, time = c('2005-11-01','2006-01-01'), latitude = c(20, 21),
#'    longitude = c(10, 11), fields = 'uo'))
#' (res <- griddap(out, time = c('2005-11-01','2006-01-01'), latitude = c(20, 21),
#'    longitude = c(10, 11), fields = 'uo', stride = c(1,2,1,2)))
#' (res <- griddap(out, time = c('2005-11-01','2006-01-01'), latitude = c(20, 21),
#'    longitude = c(10, 11), fields = c('uo','so')))
#'
#' # multi-variable dataset
#' (out <- info('noaa_gfdl_3c96_7879_a9d3'))
#' (res <- griddap(out,
#'  time = c('2005-11-01','2005-11-10'),
#'  latitude = c(20, 21),
#'  longitude = c(2, 3)
#' ))
#'
#' # Write to memory (within R), or to disk
#' (out <- info('erdQSwindmday'))
#' ## disk, by default (to prevent bogging down system w/ large datasets)
#' ## you can also pass in path and overwrite options to disk()
#' (res <- griddap(out,
#'  time = c('2006-07-11','2006-07-20'),
#'  longitude = c(166, 170),
#'  store = disk()
#' ))
#' ## the 2nd call is much faster as it's mostly just the time of reading in the table from disk
#' system.time( griddap(out,
#'  time = c('2006-07-11','2006-07-15'),
#'  longitude = c(10, 15),
#'  store = disk()
#' ) )
#' system.time( griddap(out,
#'  time = c('2006-07-11','2006-07-15'),
#'  longitude = c(10, 15),
#'  store = disk()
#' ) )
#'
#' ## memory
#' (res <- griddap("noaa_gfdl_3c96_7879_a9d3",
#'  time = c('2005-11-01','2005-11-10'),
#'  latitude = c(20, 21),
#'  longitude = c(4, 5),
#'  store = memory()
#' ))
#'
#' ## Use ncdf4 package to parse data
#' info("hawaii_463b_5b04_35b7")
#' (res <- griddap("hawaii_463b_5b04_35b7",
#'  time = c('2015-01-01','2015-01-03'),
#'  latitude = c(14, 15),
#'  longitude = c(75, 76),
#'  ncdf = "ncdf4"
#' ))
#'
#' # Get data in csv format
#' ## by default, we get netcdf format data
#' (res <- griddap('noaa_gfdl_5081_7d4a_7570',
#'  time = c('2005-11-01','2005-11-06'),
#'  latitude = c(20, 21),
#'  longitude = c(10, 11),
#'  fmt = "csv"
#' ))
#'
#' # Use a different ERDDAP server url
#' ## NOAA IOOS PacIOOS
#' url = "http://oos.soest.hawaii.edu/erddap/"
#' out <- info("NOAA_DHW", url = url)
#' (res <- griddap(out,
#'  time = c('2005-11-01','2006-01-01'),
#'  latitude = c(21, 20),
#'  longitude = c(10, 11)
#' ))
#' ## pass directly into griddap()
#' griddap("NOAA_DHW", url = url,
#'  time = c('2005-11-01','2006-01-01'),
#'  latitude = c(21, 20),
#'  longitude = c(10, 11)
#' )
#'
#' # You don't have to pass in all of the dimensions
#' ## They do have to be named!
#' griddap(out, time = c('2005-11-01','2005-11-03'))
#'
#' # Using 'last'
#' ## with time
#' griddap('noaa_gfdl_5081_7d4a_7570',
#'  time = c('last-5','last'),
#'  latitude = c(21, 18),
#'  longitude = c(3, 5)
#' )
#' ## with latitude
#' griddap('noaa_gfdl_5081_7d4a_7570',
#'   time = c('2008-01-01','2009-01-01'),
#'   latitude = c('last', 'last'),
#'   longitude = c(3, 5)
#' )
#' ## with longitude
#' griddap('noaa_gfdl_5081_7d4a_7570',
#'  time = c('2008-01-01','2009-01-01'),
#'  latitude = c(21, 18),
#'  longitude = c('last', 'last')
#' )
#'
#' # Toggle dimension variables (e.g., lat, long, time, depth)
#' (res <- griddap(x = "noaa_esrl_027d_0fb5_5d38",
#'  time = c('2012-01-01','2012-06-12'),
#'  latitude = c(21, 18),
#'  longitude = c(-80, -75),
#'  dim_fields = "latitude"
#' ))
#' }

griddap <- function(x, ..., fields = 'all', dim_fields = NULL, stride = 1, fmt = "nc",
  ncdf = "ncdf", url = eurl(), store = disk(), read = TRUE, callopts = list()) {

  x <- as.info(x, url)
  dimargs <- list(...)
  check_dims(dimargs, x)
  check_lat_text(dimargs)
  check_lon_text(dimargs)
  dimargs <- fix_dims(dimargs, .info = x)
  check_lon_data_range(dimargs, x)
  check_lat_data_range(dimargs, x)
  d <- attr(x, "datasetid")
  var <- field_handler(fields, x$variables$variable_name)
  dims <- dimvars(x)
  dims <- dim_field_handler(dims, dim_fields)
  store <- toggle_store(fmt, store)
  if (all(var == "none")) {
    args <- paste0(sapply(dims, function(y) parse_args(x, y, stride, dimargs, wname = TRUE)), collapse = ",")
  } else {
    pargs <- sapply(dims, function(y) parse_args(x, y, stride, dimargs))
    args <- paste0(lapply(var, function(y) paste0(y, paste0(pargs, collapse = ""))), collapse = ",")
  }
  fmt <- match.arg(fmt, c("nc", "csv"))
  resp <- erd_up_GET(url = sprintf("%sgriddap/%s.%s", url, d, fmt), dset = d,
                     args = args, store = store, fmt = fmt, callopts)
  loc <- if (store$store == "disk") resp else "memory"
  outclasses <- switch(fmt,
                       nc = c("griddap_nc", "nc"),
                       csv = c("griddap_csv", "csv", "data.frame"))
  read <- toggle_read(read, store)
  structure(read_all(resp, fmt, read, ncdf), class = outclasses, datasetid = d, path = loc)
}

toggle_read <- function(x, store) {
  if (store$store == "memory") {
    return(TRUE)
  } else {
    return(x)
  }
}

toggle_store <- function(fmt, store) {
  if (fmt == "nc") {
    if (store$store == "memory") {
      disk()
    } else {
      store
    }
  } else {
    store
  }
}

#' @export
print.griddap_csv <- function(x, ..., n = 10){
  finfo <- file_info(attr(x, "path"))
  cat(sprintf("<ERDDAP griddap> %s", attr(x, "datasetid")), sep = "\n")
  path <- attr(x, "path")
  path2 <- if (file.exists(path)) path else "<beware: file deleted>"
  cat(sprintf("   Path: [%s]", path2), sep = "\n")
  if (attr(x, "path") != "memory") {
    cat(sprintf("   Last updated: [%s]", finfo$mtime), sep = "\n")
    cat(sprintf("   File size:    [%s mb]", finfo$size), sep = "\n")
  }
  cat(sprintf("   Dimensions:   [%s X %s]\n", NROW(x), NCOL(x)), sep = "\n")
  trunc_mat(x, n = n)
}

#' @export
print.griddap_nc <- function(x, ..., n = 10){
  finfo <- file_info(attr(x, "path"))
  cat(sprintf("<ERDDAP griddap> %s", attr(x, "datasetid")), sep = "\n")
  path <- attr(x, "path")
  path2 <- if (file.exists(path)) path else "<beware: file deleted>"
  cat(sprintf("   Path: [%s]", path2), sep = "\n")
  if (attr(x, "path") != "memory") {
    cat(sprintf("   Last updated: [%s]", finfo$mtime), sep = "\n")
    cat(sprintf("   File size:    [%s mb]", finfo$size), sep = "\n")
  }
  cat(sprintf("   Dimensions (dims/vars):   [%s X %s]", x$summary$ndims, x$summary$nvars), sep = "\n")
  cat(sprintf("   Dim names: %s", paste0(names(x$summary$dim), collapse = ", ")), sep = "\n")
  cat(sprintf("   Variable names: %s", paste0(unname(sapply(x$summary$var, "[[", "longname")), collapse = ", ")), sep = "\n")
  cat(sprintf("   data.frame (rows/columns):   [%s X %s]", dim(x$data)[1], dim(x$data)[2]), sep = "\n\n")
  trunc_mat(x$data, n = n)
}

field_handler <- function(x, y){
  x <- match.arg(x, c(y, "none", "all"), TRUE)
  if (length(x) == 1 && x == "all") {
    y
  } else if (all(x %in% y) || x == "none") {
    x
  }
}

dim_field_handler <- function(x, y){
  if (is.null(y)) {
    return(x)
  } else {
    for (i in seq_along(y)) {
      if (!y[i] %in% x) {
        stop(sprintf("You're selected dimension var '%s' \n   is not in the available set of [%s]",
                     y[i], paste0(x, collapse = ", ")), call. = FALSE)
      }
    }
    return(y)
  }
}

check_dims <- function(dimargs, .info) {
  if (!all(names(dimargs) %in% dimvars(.info))) {
    stop(sprintf("Some input dimensions (%s) don't match those in dataset (%s)",
                 paste0(names(dimargs), collapse = ", "),
                 paste0(dimvars(.info), collapse = ", ")), call. = FALSE)
  }
}

check_lon_text <- function(dimargs) {
  if (!is.null(dimargs$longitude)) {
    if (any(sapply(dimargs$longitude, class) == "character")) {
      txt <- dimargs$longitude[sapply(dimargs$longitude, class) == "character"]
      if (!all(grepl("last", txt))) stop("Only text values allowed are 'last' & variants on that", call. = FALSE)
    }
  }
}

check_lat_text <- function(dimargs) {
  if (!is.null(dimargs$latitude)) {
    if (any(sapply(dimargs$latitude, class) == "character")) {
      txt <- dimargs$latitude[sapply(dimargs$latitude, class) == "character"]
      if (!all(grepl("last", txt))) stop("Only text values allowed are 'last' & variants on that", call. = FALSE)
    }
  }
}

is_lon_text <- function(dimargs) {
  if (!is.null(dimargs$longitude)) {
    any(sapply(dimargs$longitude, class) == "character")
  } else {
    FALSE
  }
}

is_lat_text <- function(dimargs) {
  if (!is.null(dimargs$latitude)) {
    any(sapply(dimargs$latitude, class) == "character")
  } else {
    FALSE
  }
}

check_lon_data_range <- function(dimargs, .info) {
  if (!is.null(dimargs$longitude)) {
    val <- .info$alldata$longitude[ .info$alldata$longitude$attribute_name == "actual_range", "value"]
    val2 <- as.numeric(strtrim(strsplit(val, ",")[[1]]))
    if (!is_lon_text(dimargs)) {
      if (max(dimargs$longitude) > max(val2) || min(dimargs$longitude) < min(val2)) {
        stop(sprintf("One or both longitude values (%s) outside data range (%s)",
                     paste0(dimargs$longitude, collapse = ", "),
                     paste0(val2, collapse = ", ")), call. = FALSE)
      }
    }
  }
}

check_lat_data_range <- function(dimargs, .info) {
  if (!is.null(dimargs$latitude)) {
    val <- .info$alldata$latitude[ .info$alldata$latitude$attribute_name == "actual_range", "value"]
    val2 <- as.numeric(strtrim(strsplit(val, ",")[[1]]))
    if (!is_lat_text(dimargs)) {
      if (max(dimargs$latitude) > max(val2) || min(dimargs$latitude) < min(val2)) {
        stop(sprintf("One or both latitude values (%s) outside data range (%s)",
                     paste0(dimargs$latitude, collapse = ", "),
                     paste0(val2, collapse = ", ")), call. = FALSE)
      }
    }
  }
}

fix_dims <- function(dimargs, .info) {
  for (i in seq_along(dimargs)) {
    tmp <- dimargs[[i]]
    nm <- names(dimargs[i])
    tmp <- grep("last+", tmp, value = TRUE, invert = TRUE)
    if (nm == "time") {
      tmp <- as.Date(tmp)
    }
    val <- .info$alldata[[nm]][ .info$alldata[[nm]]$attribute_name == "actual_range", "value"]
    val2 <- as.numeric(strtrim(strsplit(val, ",")[[1]]))
    if (length(tmp) != 0) {
      if (which.min(val2) != which.min(tmp)) {
        dimargs[[i]] <- rev(dimargs[[i]])
      }
    }
  }
  dimargs
}

# which_min <- function(x) {
#   if (is(x, "character")) {
#     grep(min(tmp), tmp)
#   } else {
#     which.min(x)
#   }
# }

parse_args <- function(.info, dim, s, dimargs, wname = FALSE){
  tmp <- if (dim %in% names(dimargs)) {
    dimargs[[dim]]
  } else {
    if (dim == "time") {
      times <- c(getvar(.info, "time_coverage_start"), getvar(.info, "time_coverage_end"))
      sprintf('[(%s):%s:(%s)]', times[1], s, times[2])
    } else {
      actrange <- foo(.info$alldata[[dim]], "actual_range")
      gsub("\\s+", "", strsplit(actrange, ",")[[1]])
    }
  }

  if (length(s) > 1) {
    if (!length(s) == length(dimvars(.info))) stop("Your stride vector must equal length of dimension variables", call. = FALSE)
    names(s) <- dimvars(.info)
    if (!wname) {
      sprintf('[(%s):%s:(%s)]', tmp[1], s[[dim]], tmp[2])
    } else {
      sprintf('%s[(%s):%s:(%s)]', dim, tmp[1], s[[dim]], tmp[2])
    }
  } else {
    if (!wname) {
      if (length(tmp) == 1) {
        tmp
      } else {
        sprintf('[(%s):%s:(%s)]', tmp[1], s, tmp[2])
      }
    } else {
      if (length(tmp) == 1) {
        tmp
      } else {
        sprintf('%s[(%s):%s:(%s)]', dim, tmp[1], s, tmp[2])
      }
    }
  }
}

getvar <- function(x, y){
  x$alldata$NC_GLOBAL[ x$alldata$NC_GLOBAL$attribute_name == y, "value"]
}

getvars <- function(x){
  vars <- names(x$alldata)
  vars[ !vars %in% c("NC_GLOBAL", "time", x$variables$variable_name) ]
}

getallvars <- function(x){
  vars <- names(x$alldata)
  vars[ !vars %in% "NC_GLOBAL" ]
}

dimvars <- function(x){
  vars <- names(x$alldata)
  vars[ !vars %in% c("NC_GLOBAL", x$variables$variable_name) ]
}

erd_up_GET <- function(url, dset, args, store, fmt, ...){
  if (store$store == "disk") {
    # store on disk
    key <- gen_key(url, args, fmt)
    if ( file.exists(file.path(store$path, key)) ) {
      file.path(store$path, key)
    } else {
      dir.create(store$path, showWarnings = FALSE, recursive = TRUE)
      res <- GET(url, query = args, write_disk(file.path(store$path, key), store$overwrite), ...)
      # delete file if error, and stop message
      err_handle(res, store, key)
      # return file path
      res$request$output$path
    }
  } else {
    # read into memory, bypass disk storage
    res <- GET(url, query = args, ...)
    # if error stop message
    err_handle(res, store, key)
    # return response object
    res
  }
}

writepath <- function(path, d, fmt) file.path(path, paste0(d, ".", fmt))

gen_key <- function(url, args, fmt) {
  ky <- paste0(url, "?", args)
  paste0(digest::digest(ky), ".", fmt)
}

# libfile <- function() file.path(path.expand("~/.rerddap"), ".library")

# hash_file <- function(x) {
#   if (!file.exists(x)) {
#     cat("\n", file = x)
#   }
# }

# write_key <- function(path, key) {
#   hash_file(path)
#   cat("- ", key, file = path, append = TRUE)
# }

file_info <- function(x) {
  tmp <- file.info(x)
  row.names(tmp) <- NULL
  tmp2 <- tmp[,c('mtime', 'size')]
  tmp2$size <- round(tmp2$size/1000000L, 2)
  tmp2
}

strextract <- function(str, pattern) regmatches(str, regexpr(pattern, str))

strtrim <- function(str) gsub("^\\s+|\\s+$", "", str)
