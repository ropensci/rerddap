#' Browse a dataset webpage.
#'
#' Note that it is an error to call this when \code{base::interactive()} returns FALSE
#'
#' @export
#'
#' @param x  datasetid or an object associated with a datasetid such \code{\link{info}}, \code{\link{griddap}} or \code{\link{tabledap}}
#' @param url A URL for an ERDDAP server. Default: \url{http://upwell.pfeg.noaa.gov/erddap/}
#' @param ... Further args passed on to \code{\link[httr]{BROWSE}} (must be a named parameter)
#' @return the value returned by \code{\link[httr]{BROWSE}}
#' @examples \dontrun{
#'  # browse by dataset_id 
#'  browse('noaa_esrl_28d5_ac3a_bb06')
#'  
#'  # browse info class
#'  my_info <- info('noaa_esrl_28d5_ac3a_bb06')
#'  browse(my_inf)
#'  
#'  # browse griddap class
#'  my_griddap <- griddap('noaa_esrl_28d5_ac3a_bb06')
#'  browse(my_griddap)
#'
#'  #browse tabledap class
#'  my_tabledap <- tabledap('erdCalCOFIfshsiz')
#'  browse(my_tabledap)
#'  }
browse <- function(x, ...){
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
browse.info <- function(x, ...){
    datasetid <- attr(x, "datasetid")
    browse(datasetid, ...)
}

#' @export
browse.tabledap <- function(x, ...){
    datasetid <- attr(x, "datasetid")
    browse(datasetid, ...)
}

#' @export
browse.griddap_nc <- function(x, ...){
    datasetid <- attr(x, "datasetid")
    browse(datasetid, ...)
}


#' @export
browse.griddap_csv <- function(x, ...){
    datasetid <- attr(x, "datasetid")
    browse(datasetid, ...)
}

#' @export
browse.default <- function(x, ...){
    att <- attributes(x)
    if (!is.null(att)){
        if ('datasetid' %in% names(att)) browse(att, ...)
    } else {
      stop(sprintf("browse method not implemented for %s.", class(x)[1]), call. = FALSE)
    }
}
