#' Convert a FIPS County Code to/from a County Name
#'
#' @export
#' @param county character; A county name.
#' @param code numeric; A FIPS code.
#' @param url A URL for an ERDDAP server. Default:
#' \url{https://upwell.pfeg.noaa.gov/erddap/}
#' @param ... Curl args passed on to \code{\link[httr]{GET}}
#' @examples  \dontrun{
#' fipscounty(code = "06053")
#' fipscounty(county = "CA, Monterey")
#' fipscounty(county = "OR, Multnomah")
#' }

fipscounty <- function(county = NULL, code = NULL, url = eurl(), ...){
  either_or_fips(county, code)
  args <- rc(list(county = county, code = code))
  res <- GET(paste0(pu(url), '/convert/fipscounty.txt'), query = args, ...)
  stop_for_status(res)
  content(res, "text")
}

either_or_fips <- function(county, code) {
  if (!xor(!is.null(county), !is.null(code))) {
    stop("Provide either county or code, not both", call. = FALSE)
  }
}
