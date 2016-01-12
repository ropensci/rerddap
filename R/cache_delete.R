#' Delete cached files
#'
#' @export
#' @param x File names
#' @param cache_path path to cached files
#' @param force (logical) Should files be force deleted? Default: \code{FALSE}
#' @references \url{http://upwell.pfeg.noaa.gov/erddap/index.html}
#' @author Scott Chamberlain <myrmecocystus@@gmail.com>
#' @seealso \code{\link{cache_list}}, \code{\link{cache_details}}
#' @examples \dontrun{
#' # delete files by name in cache
#' # cache_delete('9911750294a039b8b517c8bf288978ea.csv')
#' # cache_delete(c('9911750294a039b8b517c8bf288978ea.csv',
#' #                'b26825b6737da13d6a52c28c8dfe690f.csv'))
#'
#' # You can delete from the output of griddap or tabledap fxns
#' ## tabledap
#' (table_res <- tabledap('erdCalCOFIfshsiz'))
#' cache_delete(table_res)
#'
#' ## griddap
#' (grid_res <- griddap('noaa_esrl_027d_0fb5_5d38',
#'  time = c('2012-01-01','2012-06-12'),
#'  latitude = c(21, 18),
#'  longitude = c(-80, -75)
#' ))
#' cache_delete(grid_res)
#' }
cache_delete <- function(x, cache_path = "~/.rerddap", force = FALSE) {
  UseMethod("cache_delete")
}

#' @export
cache_delete.tabledap <- function(x, cache_path = "~/.rerddap", force = FALSE) {
  cdel(basename(attr(x, "path")), cache_path, force)
}

#' @export
cache_delete.griddap_nc <- function(x, cache_path = "~/.rerddap", force = FALSE) {
  cdel(basename(attr(x, "path")), cache_path, force)
}

#' @export
cache_delete.griddap_csv <- function(x, cache_path = "~/.rerddap", force = FALSE) {
  cdel(basename(attr(x, "path")), cache_path, force)
}

#' @export
cache_delete.list <- function(x, cache_path = "~/.rerddap", force = FALSE) {
  cdel(unlist(x), cache_path, force)
}

#' @export
cache_delete.character <- function(x, cache_path = "~/.rerddap", force = FALSE) {
  cdel(x, cache_path, force)
}

# cache_delete helper
cdel <- function(files, cache_path = "~/.rerddap", force = FALSE) {
  files <- file.path(cache_path, files)
  if (!all(file.exists(files))) {
    stop("These files don't exist or can't be found: \n", strwrap(files[!file.exists(files)], indent = 5), call. = FALSE)
  }
  unlink(files, force = force)
}

#' @export
#' @rdname cache_delete
cache_delete_all <- function(cache_path = "~/.rerddap", force = FALSE) {
  files <- list.files(cache_path, full.names = TRUE)
  unlink(files, force = force)
}
