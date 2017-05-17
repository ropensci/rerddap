#' Setup cache path
#'
#' @export
#' @param path_suffix (character) the path suffix to use for storing cached
#' files, appended to user cache dir.
#' @param temp_dir (logical) if \code{TRUE} use a randomly assigned
#' \code{tempdir} (and \code{path_suffix} is ignored), if \code{FALSE}, you
#' can use \code{path_suffix}.
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
#' # set a tempdir - better for programming with to avoid prompt
#' cache_setup(temp_dir = TRUE)
#'
#' # cache info
#' cache_info()
#' }
cache_setup <- function(path_suffix = NULL, temp_dir = FALSE) {
  if (is.null(path_suffix)) path_suffix <- get_cache_path()
  if (!is.null(path_suffix)) rrcache$cache_path_set(path_suffix)
  if (temp_dir) rrcache$cache_path_set("rerddap", type = "tempdir")
  rrcache$cache_path_get()
}

#' @export
#' @rdname cache_setup
cache_info <- function() {
  list(
    path = rrcache$cache_path_get(),
    no_files = length(rrcache$list())
  )
}
