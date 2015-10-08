#' Convert a CF Standard Name to/from a GCMD Science Keyword
#'
#' @export
#' @param udunits character; A UDUNITS character string
#' \url{http://www.unidata.ucar.edu/software/udunits/}
#' @param ucum character; A UCUM character string \url{http://unitsofmeasure.org/ucum.html}
#' @param url Base URL of the ERDDAP server
#' @param ... Curl args passed on to \code{\link[httr]{GET}}
#' @examples  \dontrun{
#' convert_units(udunits = "degree_C meter-1")
#' convert_units(ucum = "Cel.m-1")
#' }

convert_units <- function(udunits = NULL, ucum = NULL, url="http://coastwatch.pfeg.noaa.gov", ...){
  check1notboth(udunits, ucum)
  args <- rc(list(UDUNITS = udunits, UCUM = ucum))
  res <- GET(paste0(pu(url), '/erddap/convert/units.txt'), query = args, ...)
  stop_for_status(res)
  content(res, "text")
}
