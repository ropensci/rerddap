#' Convert a CF Standard Name to/from a GCMD Science Keyword
#'
#' @export
#' @param cf character; A cf standard name
#' \url{http://cfconventions.org/Data/cf-standard-names/27/build/cf-standard-name-table.html}
#' @param gcmd character; A GCMD science keyword
#' \url{http://gcmd.gsfc.nasa.gov/learn/keyword_list.html}
#' @param url Base URL of the ERDDAP server
#' @param ... Curl args passed on to \code{\link[httr]{GET}}
#' @examples  \donttest{
#' keywords(cf = "air_pressure")
#' cat(keywords(cf = "air_pressure"))
#' keywords(gcmd = "Atmosphere > Atmospheric Pressure > Sea Level Pressure")
#' cat(keywords(gcmd = "Atmosphere > Atmospheric Pressure > Sea Level Pressure"))
#' }

keywords <- function(cf = NULL, gcmd = NULL, url="http://coastwatch.pfeg.noaa.gov", ...){
  args <- rc(list(cf=cf, gcmd=gcmd))
  res <- GET(paste0(pu(url), '/erddap/convert/keywords.txt'), query = args, ...)
  stop_for_status(res)
  content(res, "text")
}
