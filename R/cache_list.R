#' List cached files
#'
#' @export
#' @param cache_path path to cached files
#' @references \url{http://upwell.pfeg.noaa.gov/erddap/index.html}
#' @author Scott Chamberlain <myrmecocystus@@gmail.com>
#' @seealso \code{\link{cache_delete}}, \code{\link{cache_details}}
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
cache_list <- function(cache_path = "~/.rerddap") {
  nc_files <- list.files(cache_path, pattern = ".nc")
  csv_files <- list.files(cache_path, pattern = ".csv")
  structure(list(nc = nc_files, csv = csv_files), class = "rerddap_cache")
}

#' @export
print.rerddap_cache <- function(x, ...) {
  cat("<rerddap cached files>", sep = "\n")
  cat(" NetCDF files: ", strwrap(x$nc, indent = 5), sep = "\n")
  cat(" CSV files: ", strwrap(x$csv, indent = 5), sep = "\n")
}
