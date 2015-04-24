#' Get ERDDAP griddap data.
#'
#' @export
#'
#' @param x Anything coercable to an object of class info. So the output of a call to
#' \code{info}, or a datasetid, which will internally be passed through \code{\link{info}}
#' @param ... Dimension arguments.
#' @param fields Fields to return, a character vector.
#' @param stride (integer) How many values to get. 1 = get every value, 2 = get
#' every other value, etc. Default: 1 (i.e., get every value)
#' @param fmt (character) One of csv (default) or ncdf
#' @param url A URL for an ERDDAP server. Default: \url{http://upwell.pfeg.noaa.gov/erddap/}
#' @param store One of \code{\link{disk}} (default) or \code{\link{memory}}. You
#' can pass options to \code{\link{disk}}
#' @param callopts Pass on curl options to \code{\link[httr]{GET}}
#'
#' @details Details:
#'
#' @section Dimensions and Variables:
#' ERDDAP grid dap data has this concept of dimenions vs. variables. So, dimensions are things
#' like time, latitude, longitude, and altitude. Whereas variables are the measured variables,
#' e.g., temperature, salinity, and air.
#'
#' You can't separately adjust values for dimensions for different variables. So, here's how it's
#' gonna work:
#'
#' Pass in lower and upper limits you want for each dimension as a vector (e.g., \code{c(1,2)}),
#' or leave to defaults (i.e., don't pass anything to a dimension). Then pick which variables
#' you want returned via the \code{fields} parameter. If you don't pass in options to the
#' \code{fields} parameter, you get all variables back.
#'
#' To get the dimensions and variables, along with other metadata for a dataset, run
#' \code{info}, and each will be shown, with their min and max values, and some
#' other metadata.
#'
#' @section Where does the data go?:
#' You can choose where data is stored. Be careful though. You can easily get a single file of
#' hundreds of MB's or GB's in size with a single request. To the store parameter, pass
#' \dQuote{memory} if you want to store the data in memory (saved as a data.frame), or
#' pass \dQuote{disk} if you want to store on disk in a file. Possibly will add other options,
#' like \dQuote{sql} for storing in a SQL database, though that option would need to be expanded
#' to various SQL DB options though.
#' @references  \url{http://upwell.pfeg.noaa.gov/erddap/index.html}
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
#'  longitude = c(10, 11)
#' ))
#' (res <- griddap(out, time = c('2005-11-01','2006-01-01'), latitude = c(20, 21),
#' longitude = c(10, 11), fields = 'uo'))
#' (res <- griddap(out, time = c('2005-11-01','2006-01-01'), latitude = c(20, 21),
#' longitude = c(10, 11), fields = 'uo', stride=c(1,2,1,2)))
#' (res <- griddap(out, time = c('2005-11-01','2006-01-01'), latitude = c(20, 21),
#' longitude = c(10, 11), fields = c('uo','so')))
#' (res <- griddap(out, time = c('2005-09-01','2006-01-01'), latitude = c(20, 21),
#' longitude = c(10, 11), fields = 'none'))
#'
#' # multi-variable dataset
#' ## this one also has a 0-360 longitude system, BLARGH!!!
#' (out <- info('noaa_gfdl_3c96_7879_a9d3'))
#' (res <- griddap(out,
#'  time = c('2005-11-01','2006-01-01'),
#'  latitude = c(20, 22),
#'  longitude = c(-80, -75)
#' ))
#' (res <- griddap(out,
#'  time = c('2005-11-01','2006-01-01'),
#'  latitude = c(20, 22),
#'  longitude = c(-80, -75),
#'  depth = c(5, 50)
#' ))
#'
#' # Write to memory (within R), or to disk
#' (out <- info('erdAKssta3day'))
#' ## disk, by default (to prevent bogging down system w/ large datasets)
#' ## you can also pass in path and overwrite options to disk()
#' (res <- griddap(out,
#'  time = c('2006-06-01','2007-06-12'),
#'  latitude = c(45, 50),
#'  longitude = c(166, 180),
#'  store = disk()
#' ))
#' ## the 2nd call is much faster as it's mostly just the time of reading in the table from disk
#' system.time( griddap(out,
#'  time = c('2012-06-01','2012-06-12'),
#'  latitude = c(20, 21),
#'  longitude = c(-80, -75),
#'  store = disk()
#' ) )
#' system.time( griddap(out,
#'  time = c('2012-06-01','2012-06-12'),
#'  latitude = c(20, 21),
#'  longitude = c(-80, -75),
#'  store = disk()
#' ) )
#'
#' ## memory
#' (res <- griddap(out,
#'  time = c('2012-06-01','2012-06-12'),
#'  latitude = c(20, 21),
#'  longitude = c(-80, -75),
#'  store = memory()
#' ))
#'
#' ## netcdf
#' (res <- griddap(out,
#'  time = c('2012-01-01','2012-06-12'),
#'  latitude = c(21, 14),
#'  longitude = c(-80, -75),
#'  fmt = "nc"
#' ))
#'
#' (res <- griddap('noaa_gfdl_5081_7d4a_7570',
#'  time = c('2005-11-01','2006-01-01'),
#'  latitude = c(20, 21),
#'  longitude = c(10, 11),
#'  fmt = "nc"
#' ))
#' }

griddap <- function(x, ..., fields = 'all', stride = 1, fmt = "nc", url = eurl(),
                    store = disk(), callopts = list()) {
  x <- as.info(x)
  dimargs <- list(...)
  d <- attr(x, "datasetid")
  var <- field_handler(fields, x$variables$variable_name)
  dims <- dimvars(x)
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
  structure(read_all(resp, fmt), class = outclasses, datasetid = d, path = loc)
}

#' @export
print.griddap_csv <- function(x, ..., n = 10){
  finfo <- file_info(attr(x, "path"))
  cat(sprintf("<NOAA ERDDAP griddap> %s", attr(x, "datasetid")), sep = "\n")
  cat(sprintf("   Path: [%s]", attr(x, "path")), sep = "\n")
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
  cat(sprintf("<NOAA ERDDAP griddap> %s", attr(x, "datasetid")), sep = "\n")
  cat(sprintf("   Path: [%s]", attr(x, "path")), sep = "\n")
  if (attr(x, "path") != "memory") {
    cat(sprintf("   Last updated: [%s]", finfo$mtime), sep = "\n")
    cat(sprintf("   File size:    [%s mb]", finfo$size), sep = "\n")
  }
  cat(sprintf("   Dimensions (dims/vars):   [%s X %s]", x$ndims, x$nvars), sep = "\n")
  cat(sprintf("   Dim names: %s", paste0(names(x$dim), collapse = ", ")), sep = "\n")
  cat(sprintf("   Variable names: %s", paste0(unname(sapply(x$var, "[[", "longname")), collapse = ", ")))
}

field_handler <- function(x, y){
  x <- match.arg(x, c(y, "none", "all"), TRUE)
  if (length(x) == 1 && x == "all") {
    y
  } else if (all(x %in% y) || x == "none") {
    x
  }
}

parse_args <- function(.info, dim, s, dimargs, wname=FALSE){
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
    if (!wname)
      sprintf('[(%s):%s:(%s)]', tmp[1], s, tmp[2])
    else
      sprintf('%s[(%s):%s:(%s)]', dim, tmp[1], s, tmp[2])
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
    # fpath <- path.expand(file.path(store$path, paste0(dset, ".", fmt)))
    key <- gen_key(url, args, fmt)
    if ( file.exists(file.path(store$path, key)) ) {
      file.path(store$path, key)
    } else {
      dir.create(store$path, showWarnings = FALSE, recursive = TRUE)
      res <- GET(url, query = args, write_disk(file.path(store$path, key), store$overwrite), ...)
      res$request$writer[[1]]
    }
  } else {
    # read into memory, bypass disk storage
    GET(url, query = args, ...)
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
