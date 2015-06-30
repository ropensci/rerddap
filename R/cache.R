#' Manage cached files
#'
#' @export
#' @param files File names
#' @param cache_path path to cached files
#' @param force (logical) Should files be force deleted? Default: \code{FALSE}
#' @references \url{http://upwell.pfeg.noaa.gov/erddap/index.html}
#' @author Scott Chamberlain <myrmecocystus@@gmail.com>
#' @examples \dontrun{
#' # list files in cache
#' cache_list()
#'
#' # List info for files
#' cache_info(files = "243b4b41e19444515986ccf9cafbb1e9.nc")
#' cache_info(files = "476ea03d8d246d81f2de02bd40524adb.csv")
#' cache_info()
#'
#' # delete files by name in cache
#' cache_delete(files = '9911750294a039b8b517c8bf288978ea.csv')
#' cache_delete(files = c('9911750294a039b8b517c8bf288978ea.csv',
#'                  'b26825b6737da13d6a52c28c8dfe690f.csv'))
#'
#' # delete all files in cache
#' cache_delete_all()
#' }
cache_list <- function(cache_path = "~/.rerddap") {
  nc_files <- list.files(cache_path, pattern = ".nc")
  csv_files <- list.files(cache_path, pattern = ".csv")
  structure(list(nc = nc_files, csv = csv_files), class = "rerddap_cache")
}

#' @export
#' @rdname cache_list
cache_delete <- function(files, cache_path = "~/.rerddap", force = FALSE) {
  files <- file.path(cache_path, files)
  if (!all(file.exists(files))) {
    stop("These files don't exist or can't be found: \n", strwrap(files[!file.exists(files)], indent = 5), call. = FALSE)
  }
  unlink(files, force = force)
}

#' @export
#' @rdname cache_list
cache_delete_all <- function(cache_path = "~/.rerddap", force = FALSE) {
  files <- list.files(cache_path, full.names = TRUE)
  unlink(files, force = force)
}

#' @export
#' @rdname cache_list
cache_info <- function(files, cache_path = "~/.rerddap") {
  if (missing(files)) {
    files <- list.files(cache_path, full.names = TRUE)
    structure(lapply(files, file_info), class = "rerddap_cache_info")
  } else {
    files <- file.path(cache_path, files)
    structure(lapply(files, file_info), class = "rerddap_cache_info")
  }
}

file_info <- function(x) {
  tmp <- strsplit(x, '\\.')[[1]]
  ext <- tmp[length(tmp)]
  switch(ext,
         nc = {
           list(type = "netcdf",
                size = getsize(file.size(x)),
                info = ncdf_summary(x)$summary
           )
         },
         csv = {
           list(type = "csv",
                size = getsize(file.size(x)),
                info = names(read.csv(x, nrows = 1, stringsAsFactors = FALSE))
           )
         }
  )
}

getsize <- function(x) {
  round(x/10 ^ 6, 3)
}

#' @export
print.rerddap_cache <- function(x, ...) {
  cat("<rerddap cached files>", sep = "\n")
  cat(" NetCDF files: ", strwrap(x$nc, indent = 5), sep = "\n")
  cat(" CSV files: ", strwrap(x$csv, indent = 5), sep = "\n")
}

#' @export
print.rerddap_cache_info <- function(x, ...) {
  cat("<rerddap cached files>", sep = "\n")
  for (i in seq_along(x)) {
    cat(paste0("Type: ", x[[i]]$type), sep = "\n")
    cat(paste0("Size: ", x[[i]]$size, " mb"), sep = "\n")
    if (x[[i]]$type == "netcdf") {
      cat("info: ", sep = "\n")
      print(x[[i]]$info)
    } else {
      cat("info: (csv columns)", sep = "\n")
      print(x[[i]]$info)
    }
    cat("\n")
  }
}
