#' Setup cache path
#'
#' @export
#' @param full_path (character) the full path to use for storing cached
#' files.
#' @param temp_dir (logical) if \code{TRUE} use a randomly assigned
#' \code{tempdir} (and \code{full_path} is ignored), if \code{FALSE}, you
#' can use \code{full_path}.
#' @family cache
#' @return the full cache path, a directory (character)
#' @details On opening,  by default a temporary directory is created for caching
#' files.  To have files cached elsewhere,  give the full path of where to
#' cache files.  Adding \code{temp_dir = TRUE} will again use a temporary
#' dirctory for cacheing.
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
cache_setup <- function(full_path = NULL, temp_dir = FALSE) {
  if (!is.null(full_path)) rrcache$cache_path_set(full_path = full_path)
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
