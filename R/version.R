#' Get ERDDAP version
#'
#' @export
#' @param url Base URL of the ERDDAP server
#' @param ... Curl args passed on to \code{\link[httr]{GET}}
#' @examples  \donttest{
#' version("http://coastwatch.pfeg.noaa.gov")
#' version("https://bluehub.jrc.ec.europa.eu")
#' version("http://erddap.marine.ie")
#' }

version <- function(url="http://coastwatch.pfeg.noaa.gov", ...){
  res <- GET(paste(pu(url), '/erddap/version'), ...)
  stop_for_status(res)
  sub("\n", "", content(res, "text"))
}
