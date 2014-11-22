#' Convert a CF Standard Name to/from a GCMD Science Keyword
#'
#' @export
#' @param n numeric; A unix time number.
#' @param isoTime character; A string time representation.
#' @param units character; Units to return. Default: "seconds since 1970-01-01T00:00:00Z"
#' @param url Base URL of the ERDDAP server
#' @param ... Curl args passed on to \code{\link[httr]{GET}}
#' @examples  \donttest{
#' convert_time(n = 473472000)
#' convert_time(isoTime = "1985-01-02T00:00:00Z")
#' }

convert_time <- function(n = NULL, isoTime = NULL,
  units = "seconds since 1970-01-01T00:00:00Z", url="http://coastwatch.pfeg.noaa.gov", ...)
{
  args <- rc(list(n=n, isoTime=isoTime, units=units))
  res <- GET(paste0(pu(url), '/erddap/convert/time.txt'), query = args, ...)
  stop_for_status(res)
  content(res, "text")
}
