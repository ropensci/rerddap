#' Convert a CF Standard Name to/from a GCMD Science Keyword
#'
#' @export
#' @param udunits character; A UDUNITS character string
#' <http://www.unidata.ucar.edu/software/udunits/>
#' @param ucum character; A UCUM character string
#' <http://unitsofmeasure.org/ucum.html>
#' @param url Base URL of the ERDDAP server. See [eurl()] for 
#' more information
#' @param ... Curl options passed on to [crul::HttpClient]
#' @examples  \dontrun{
#' convert_units(udunits = "degree_C meter-1")
#' convert_units(ucum = "Cel.m-1")
#' }

convert_units <- function(udunits = NULL, ucum = NULL, url = eurl(), ...) {
  check1notboth(udunits, ucum)
  args <- rc(list(UDUNITS = udunits, UCUM = ucum))
  cli <- crul::HttpClient$new(url = file.path(pu(url), 'convert/units.txt'), 
    opts = list(...))
  res <- cli$get(query = args)
  res$raise_for_status()
  res$parse("UTF-8")
}
