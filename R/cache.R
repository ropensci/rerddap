#' Manage cached files
#'
#' @export
#' @param files File names
#' @param cache_path path to cached files
#' @references \url{http://upwell.pfeg.noaa.gov/erddap/index.html}
#' @author Scott Chamberlain <myrmecocystus@@gmail.com>
#' @seealso \code{\link{cache_delete}}
#' @examples \dontrun{
#' # list files in cache
#' cache_list()
#'
#' # List info for files
#' # cache_details(files = "243b4b41e19444515986ccf9cafbb1e9.nc")
#' # cache_details(files = "476ea03d8d246d81f2de02bd40524adb.csv")
#' cache_details()
#'
#' # delete files by name in cache
#' # cache_delete(files = '9911750294a039b8b517c8bf288978ea.csv')
#' # cache_delete(files = c('9911750294a039b8b517c8bf288978ea.csv',
#' #                  'b26825b6737da13d6a52c28c8dfe690f.csv'))
#' }
cache_list <- function(cache_path = "~/.rerddap") {
  nc_files <- list.files(cache_path, pattern = ".nc")
  csv_files <- list.files(cache_path, pattern = ".csv")
  structure(list(nc = nc_files, csv = csv_files), class = "rerddap_cache")
}

#' @export
#' @rdname cache_list
cache_details <- function(files = NULL, cache_path = "~/.rerddap") {
  if (is.null(files)) {
    files <- list.files(cache_path, full.names = TRUE)
    structure(lapply(files, file_info_), class = "rerddap_cache_info")
  } else {
    files <- file.path(cache_path, files)
    structure(lapply(files, file_info_), class = "rerddap_cache_info")
  }
}

file_info_ <- function(x) {
  tmp <- strsplit(x, '\\.')[[1]]
  ext <- tmp[length(tmp)]
  fs <- file.size(x)
  switch(ext,
         nc = {
           list(type = "netcdf",
                size = if (!is.na(fs)) getsize(fs) else NA,
                info = if (!is.na(fs)) ncdf_summary(x)$summary else NA
           )
         },
         csv = {
           list(type = "csv",
                size = if (!is.na(fs)) getsize(fs) else NA,
                info = if (!is.na(fs)) names(read.csv(x, nrows = 1, stringsAsFactors = FALSE)) else NA
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
      if (!is.na(x[[i]]$info)) {
        print(x[[i]]$info)
      }
    } else {
      cat("info: (csv columns)", sep = "\n")
      if (!is.na(x[[i]]$info)) {
        print(x[[i]]$info)
      }
    }
    cat("\n")
  }
}
