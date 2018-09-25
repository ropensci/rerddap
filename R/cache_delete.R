#' Delete cached files
#'
#' @export
#' @param x File names
#' @param force (logical) Should files be force deleted? Default: \code{FALSE}
#' @family cache
#' @examples \dontrun{
#' # delete files by name in cache
#' # cache_delete('9911750294a039b8b517c8bf288978ea.csv')
#' # cache_delete(c('9911750294a039b8b517c8bf288978ea.csv',
#' #                'b26825b6737da13d6a52c28c8dfe690f.csv'))
#'
#' # You can delete from the output of griddap or tabledap fxns
#' ## tabledap
#' (table_res <- tabledap('erdCinpKfmBT'))
#' cache_delete(table_res)
#'
#' ## griddap
#' (out <- info('erdQMekm14day'))
#' (grid_res <- griddap(out,
#'  time = c('2015-12-28','2016-01-01'),
#'  latitude = c(24, 23),
#'  longitude = c(88, 90)
#' ))
#' cache_delete(grid_res)
#' }
cache_delete <- function(x, force = FALSE) {
  UseMethod("cache_delete")
}

#' @export
cache_delete.tabledap <- function(x, force = FALSE) {
  cdel(basename(attr(x, "path")), force)
}

#' @export
cache_delete.griddap_nc <- function(x, force = FALSE) {
  cdel(basename(attr(x, "path")), force)
}

#' @export
cache_delete.griddap_csv <- function(x, force = FALSE) {
  cdel(basename(attr(x, "path")), force)
}

#' @export
cache_delete.list <- function(x, force = FALSE) {
  cdel(unlist(x), force)
}

#' @export
cache_delete.character <- function(x, force = FALSE) {
  cdel(x, force)
}

# cache_delete helper
cdel <- function(files, force = FALSE) {
  files <- file.path(rrcache$cache_path_get(), files)
  if (!all(file.exists(files))) {
    stop("These files don't exist or can't be found: \n",
         strwrap(files[!file.exists(files)], indent = 5), call. = FALSE)
  }
  unlink(files, force = force)
}

#' @export
#' @rdname cache_delete
cache_delete_all <- function(force = FALSE) {
  files <- list.files(rrcache$cache_path_get(), full.names = TRUE)
  unlink(files, force = force)
}
