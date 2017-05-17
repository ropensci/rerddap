#' List cached files
#'
#' @export
#' @family cache
#' @examples \dontrun{
#' # list files in cache
#' (x <- cache_list())
#'
#' # List info for files
#' cache_details(x$nc[1])
#' cache_details(x$csv[1])
#' cache_details()
#'
#' # delete files by name in cache
#' # cache_delete(x$nc[1])
#' # cache_delete(x$nc[2:3])
#' }
cache_list <- function() {
  nc_files <- list.files(rrcache$cache_path_get(), pattern = ".nc")
  csv_files <- list.files(rrcache$cache_path_get(), pattern = ".csv")
  structure(list(nc = nc_files, csv = csv_files), class = "rerddap_cache")
}

#' @export
print.rerddap_cache <- function(x, ...) {
  cat("<rerddap cached files>", sep = "\n")
  cat(" NetCDF files: ", strwrap(x$nc, indent = 5), sep = "\n")
  cat(" CSV files: ", strwrap(x$csv, indent = 5), sep = "\n")
}
