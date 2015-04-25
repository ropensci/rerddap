#' Get ERDDAP version
#'
#' @export
#' @param url A URL for an ERDDAP server. Default: \url{http://upwell.pfeg.noaa.gov/erddap/}
#' @param ... Curl args passed on to \code{\link[httr]{GET}}
#' @examples \dontrun{
#' version()
#' version(servers()$url[1])
#' version(servers()$url[2])
#' version(servers()$url[3])
#' }
version <- function(url = eurl(), ...){
  res <- GET(paste0(pu(url), '/version'), ...)
  stop_for_status(res)
  sub("\n", "", content(res, "text"))
}
