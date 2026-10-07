#' Get ERDDAP™ version
#'
#' @export
#' @param url A URL for an ERDDAP™ server. Default:
#' https://upwell.pfeg.noaa.gov/erddap/ - See [eurl()] for 
#' more information
#' @param ... Curl options passed on to [crul::verb-GET]
#' @examples \dontrun{
#' version()
#' ss <- servers()
#' version(ss$url[2])
#' version(ss$url[3])
#' }
version <- function(url = eurl(), ...){
  fn_env <- environment()
  cli <- crul::HttpClient$new(url = file.path(pu(url), 'version'), 
    opts = list(...))
  res <- tryCatch(
    cli$get(),
    error = function(e) {
      cli::cli_abort(
        "Curl request failed to get version from {.url {url}}.",
        class  = "rerddap_http_error",
        parent = e,
        call   = fn_env
      )
    }
  )
  res$raise_for_status()
  sub("\n", "", res$parse("UTF-8"))
}
