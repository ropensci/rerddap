#' Get ERDDAP version
#'
#' @export
#' @param url A URL for an ERDDAP server. Default:
#' \url{https://upwell.pfeg.noaa.gov/erddap/}
#' @param ... Curl args passed on to \code{\link[httr]{GET}}
#' @examples \dontrun{
#' version()
#' ss <- servers()
#' version(ss$url[1])
#' version(ss$url[2])
#' version(ss$url[3])
#' }
version <- function(url = eurl(), ...){
  res <- GET(paste0(pu(url), '/version'), ...)
  stop_for_status(res)
  sub("\n", "", content(res, "text"))
}
