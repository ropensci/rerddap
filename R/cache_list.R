#' List cached files
#'
#' @export
#' @param cache_path path to cached files
#' @references \url{http://upwell.pfeg.noaa.gov/erddap/index.html}
#' @author Scott Chamberlain <myrmecocystus@@gmail.com>
#' @seealso \code{\link{cache_delete}}, \code{\link{cache_details}}
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
print.rerddap_cache <- function(x, ...) {
  cat("<rerddap cached files>", sep = "\n")
  cat(" NetCDF files: ", strwrap(x$nc, indent = 5), sep = "\n")
  cat(" CSV files: ", strwrap(x$csv, indent = 5), sep = "\n")
}
