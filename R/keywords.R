#' Convert a CF Standard Name to/from a GCMD Science Keyword
#'
#' @export
#' @param cf character; A cf standard name
#' http://cfconventions.org/Data/cf-standard-names/27/build/cf-standard-name-table.html
#' @param gcmd character; A GCMD science keyword
#' http://gcmd.gsfc.nasa.gov/learn/keyword_list.html
#' @param url A URL for an ERDDAP server. Default:
#' https://upwell.pfeg.noaa.gov/erddap/
#' @param ... Curl args passed on to \code{\link[httr]{GET}}
#' @examples  \dontrun{
#' key_words(cf = "air_pressure")
#' cat(key_words(cf = "air_pressure"))
#' key_words(gcmd = "Atmosphere > Atmospheric Pressure > Sea Level Pressure")
#' cat(
#' key_words(gcmd = "Atmosphere > Atmospheric Pressure > Sea Level Pressure"))
#'
#' # a different ERDDAP server
#' key_words(cf = "air_pressure", url = servers()$url[5])
#' }

key_words <- function(cf = NULL, gcmd = NULL, url = eurl(), ...){
  either_or_keywords(cf, gcmd)
  args <- rc(list(cf = cf, gcmd = gcmd))
  res <- GET(paste0(pu(url), '/convert/keywords.txt'), query = args, ...)
  stop_for_status(res)
  content(res, "text")
}

either_or_keywords <- function(cf, gcmd) {
  if (!xor(!is.null(cf), !is.null(gcmd))) {
    stop("Provide either cf or gcmd, not both", call. = FALSE)
  }
}
