#' Options for saving ERDDAP datasets.
#'
#' @export
#' @param path Path to store files in. A directory, not a file.
#' Default: the root cache path, see \code{\link{cache_setup}}
#' @param overwrite (logical) Overwrite an existing file of the same name?
#' Default: \code{TRUE}
disk <- function(path = NULL, overwrite = TRUE) {
  path <- setup_cache_path(path_suffix = path)
  if (is.null(path)) {
    # path is NULL - use cache path already setup
    path <- rrcache$cache_path_get()
  }
  list(store = "disk", path = path, overwrite = overwrite)
}

#' @export
#' @rdname disk
memory <- function() list(store = "memory")
