#' Options for saving ERDDAP datasets.
#'
#' @export
#' @param path Path to store files in. A directory, not a file. Default: \code{~/.rerddap}
#' @param overwrite (logical) Overwrite an existing file of the same name?
#' Default: \code{TRUE}
disk <- function(path = "~/.rerddap", overwrite = TRUE){
  list(store = "disk", path = path, overwrite = overwrite)
}

#' @export
#' @rdname disk
memory <- function() list(store = "memory")
