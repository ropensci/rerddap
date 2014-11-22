#' Convert a FIPS County Code to/from a County Name
#'
#' @export
#' @param county character; A county name.
#' @param code numeric; A FIPS code.
#' @param url Base URL of the ERDDAP server
#' @param ... Curl args passed on to \code{\link[httr]{GET}}
#' @examples  \donttest{
#' fipscounty(code = "06053")
#' fipscounty(county = "CA, Monterey")
#' fipscounty(county = "OR, Multnomah")
#' }

fipscounty <- function(county = NULL, code = NULL, url="http://coastwatch.pfeg.noaa.gov", ...){
  args <- rc(list(county=county, code=code))
  res <- GET(paste0(pu(url), '/erddap/convert/fipscounty.txt'), query = args, ...)
  stop_for_status(res)
  content(res, "text")
}
