#' Convert a FIPS County Code to/from a County Name
#'
#' @export
#' @param county character; A county name.
#' @param code numeric; A FIPS code.
#' @param url A URL for an ERDDAP™ server. Default:
#' https://upwell.pfeg.noaa.gov/erddap/ - See [eurl()] for 
#' more information
#' @param ... Curl options passed on to [crul::verb-GET]
#' @examples  \dontrun{
#' fipscounty(code = "06053")
#' fipscounty(county = "CA, Monterey")
#' fipscounty(county = "OR, Multnomah")
#' }

fipscounty <- function(county = NULL, code = NULL, url = eurl(), ...){
  either_or_fips(county, code)
  args <- rc(list(county = county, code = code))
  cli <- crul::HttpClient$new(url = file.path(pu(url), 'convert/fipscounty.txt'), 
    opts = list(...))
  # res <- cli$get(query = args)
  response <- tryCatch(
    {
      res <- cli$get(query = args)  # Attempt to fetch
    },
    error = function(e) {
      message("Curl request failed to get FIPS country code: ", e$message)
      quit(save = "no", status = 1)  # Gracefully exit R session
    }
  )
  res$raise_for_status()
  res$parse("UTF-8")
}

either_or_fips <- function(county, code) {
  if (!xor(!is.null(county), !is.null(code))) {
    stop("Provide either county or code, not both", call. = FALSE)
  }
}
