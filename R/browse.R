#' Browse a dataset webpage.
#'
#' Note that it is an error to call this when `base::interactive()`
#' returns `FALSE`
#'
#' @export
#'
#' @param x  datasetid or an object associated with a datasetid such
#' [info()], [griddap()] or [tabledap()]
#' @param url A URL for an ERDDAP server. Default:
#' https://upwell.pfeg.noaa.gov/erddap/ - See [eurl()] for 
#' more information
#' @param ... Further args passed on to `utils::browseURL`
#' (must be a named parameter)
#' @return if in interactive mode, opens a URL in your default browser; 
#' if not, then returns an error
#' @author Ben Tupper \email{btupper@@bigelow.org}
#' @examples \dontrun{
#' if (interactive()) {
#' # browse by dataset_id
#' browse('erdATastnhday')
#'
#' # browse info class
#' my_info <- info('erdATastnhday')
#' browse(my_info)
#'
#' # browse tabledap class
#' my_tabledap <- tabledap('erdCalCOFIlrvsiz', fields=c('latitude','longitude','larvae_size',
#'    'itis_tsn'), 'time>=2011-10-25', 'time<=2011-10-31')
#' browse(my_tabledap)
#' }}
browse <- function(x, url = eurl(), ...){
  UseMethod("browse", x)
}

#' @export
browse.character <- function(x, url = eurl(), ...){
  stopifnot(interactive())
  if (missing(x)) stop("datasetid is required")
  uri <- sprintf(paste0(url, 'info/%s/index.html'), x)
  utils::browseURL(uri)
}

#' @export
browse.info <- function(x, url = eurl(), ...){
  stopifnot(interactive())
  datasetid <- attr(x, "datasetid")
  browse(datasetid, ...)
}

#' @export
browse.tabledap <- function(x, url = eurl(), ...){
  stopifnot(interactive())
  datasetid <- attr(x, "datasetid")
  browse(datasetid, ...)
}

#' @export
browse.griddap_nc <- function(x, url = eurl(), ...){
  stopifnot(interactive())
  datasetid <- attr(x, "datasetid")
  browse(datasetid, ...)
}


#' @export
browse.griddap_csv <- function(x, url = eurl(), ...){
  stopifnot(interactive())
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
