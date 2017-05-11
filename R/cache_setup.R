#' Setup cache path
#'
#' @export
#' @param path_suffix (character) the path suffix to be use for storing
#' cached files
#' @family cache
#' @return the full cache path, a directory (character)
#' @details Looks first if the user has set a cache path suffix in an
#' env var or R option. If not found, proceeds to use a temp directory
#' if not in interactive mode, but if interactive, asks user to setup a
#' default cache location that will work across sessions (but user can say
#' no, in which case a temp directory will be used, and each package
#' start will require cache setup again)
#' @examples \dontrun{
#' # default path
#' cache_setup()
#'
#' # you can define your own path
#' cache_setup(path = "foobar")
#'
#' # cache info
#' cache_info()
#' }
cache_setup <- function(path_suffix = NULL) {
  setup_cache_path(path_suffix = path_suffix)
}

#' @export
#' @rdname cache_setup
cache_info <- function() {
  list(
    path = rrcache$cache_path_get(),
    no_files = length(rrcache$list())
  )
}
