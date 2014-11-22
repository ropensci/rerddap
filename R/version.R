#' Get ERDDAP version
#'
#' @export
#' @param url URL of the ERDDAP server
#' @param ... Curl args passed on to \code{\link[httr]{GET}}
#' @examples  \donttest{
#' version("http://coastwatch.pfeg.noaa.gov")
#' version("https://bluehub.jrc.ec.europa.eu")
#' version("http://erddap.marine.ie")
#' }
version <- function(url, ...){
  res <- GET(paste0(sub("/$|//$", "", url), '/erddap/version'), ...)
  stop_for_status(res)
  sub("\n", "", content(res, "text"))
}
