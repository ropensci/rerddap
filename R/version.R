#' Get ERDDAP version
#'
#' @export
#' @param url A URL for an ERDDAP server. Default:
#' <https://upwell.pfeg.noaa.gov/erddap/>. See [eurl()] for 
#' more information
#' @param ... Curl options passed on to [crul::verb-GET]
#' @examples \dontrun{
#' version()
#' ss <- servers()
#' version(ss$url[2])
#' version(ss$url[3])
#' }
version <- function(url = eurl(), ...){
  cli <- crul::HttpClient$new(url = file.path(pu(url), 'version'), 
    opts = list(...))
  res <- cli$get()
  res$raise_for_status()
  sub("\n", "", res$parse("UTF-8"))
}
