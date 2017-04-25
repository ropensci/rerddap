#' Browse a dataset webpage.
#'
#' Note that it is an error to call this when \code{base::interactive()}
#' returns \code{FALSE}
#'
#' @export
#'
#' @param x  datasetid or an object associated with a datasetid such
#' \code{\link{info}}, \code{\link{griddap}} or \code{\link{tabledap}}
#' @param url A URL for an ERDDAP server. Default:
#' \url{https://upwell.pfeg.noaa.gov/erddap/}
#' @param ... Further args passed on to \code{\link[httr]{BROWSE}}
#' (must be a named parameter)
#' @return the value returned by \code{\link[httr]{BROWSE}}
#' @author Ben Tupper \email{btupper@@bigelow.org}
#' @examples \dontrun{
#' # browse by dataset_id
#' browse('erdATastnhday')
#'
#' # browse info class
#' (my_info <- info('erdATastnhday'))
#' browse(my_info)
#'
#' # browse griddap class
#' my_griddap <- griddap('erdATastnhday')
#' browse(my_griddap)
#'
#' #browse tabledap class
#' my_tabledap <- tabledap('erdCalCOFIfshsiz')
#' browse(my_tabledap)
#' }
browse <- function(x, url = eurl(), ...){
  UseMethod("browse", x)
}

#' @export
browse.character <- function(x, url = eurl(), ...){
  stopifnot(interactive())
  if (missing(x)) stop("datasetid is required")
  uri <- sprintf(paste0(url, 'info/%s/index.html'), x)
  httr::BROWSE(uri, ...)
}

#' @export
browse.info <- function(x, url = eurl(), ...){
  datasetid <- attr(x, "datasetid")
  browse(datasetid, ...)
}

#' @export
browse.tabledap <- function(x, url = eurl(), ...){
  datasetid <- attr(x, "datasetid")
  browse(datasetid, ...)
}

#' @export
browse.griddap_nc <- function(x, url = eurl(), ...){
  datasetid <- attr(x, "datasetid")
  browse(datasetid, ...)
}


#' @export
browse.griddap_csv <- function(x, url = eurl(), ...){
  datasetid <- attr(x, "datasetid")
  browse(datasetid, ...)
}

#' @export
browse.default <- function(x, url = eurl(), ...){
  att <- attributes(x)
  if (!is.null(att)) {
    if ('datasetid' %in% names(att)) browse(att, ...)
  } else {
    stop(sprintf("browse method not implemented for %s.", class(x)[1]),
         call. = FALSE)
  }
}
