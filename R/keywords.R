#' Convert a CF Standard Name to/from a GCMD Science Keyword
#'
#' @export
#' @param cf character; A cf standard name
#' http://cfconventions.org/Data/cf-standard-names/27/build/cf-standard-name-table.html
#' @param gcmd character; A GCMD science keyword
#' http://gcmd.gsfc.nasa.gov/learn/keyword_list.html
#' @param url A URL for an ERDDAP server. Default:
#' https://upwell.pfeg.noaa.gov/erddap/. See [eurl()] for 
#' more information
#' @param ... Curl options passed on to [crul::verb-GET]
#' @examples  \dontrun{
#' key_words(cf = "air_pressure")
#' cat(key_words(cf = "air_pressure"))
#'
#' # a different ERDDAP server
#' # key_words(cf = "air_pressure", url = servers()$url[6])
#' }

key_words <- function(cf = NULL, gcmd = NULL, url = eurl(), ...){
  either_or_keywords(cf, gcmd)
  args <- rc(list(cf = cf, gcmd = gcmd))
  cli <- crul::HttpClient$new(url = file.path(pu(url), 'convert/keywords.txt'), 
    opts = list(...))
  res <- cli$get(query = args)
  res$raise_for_status()
  res$parse("UTF-8")
}

either_or_keywords <- function(cf, gcmd) {
  if (!xor(!is.null(cf), !is.null(gcmd))) {
    stop("Provide either cf or gcmd, not both", call. = FALSE)
  }
}
