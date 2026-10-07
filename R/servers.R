#' ERDDAP™ server URLS and other info
#'
#' @export
#' @param ... curl options passed on to [crul::verb-GET]
#' @return data.frame with 3 columns:
#' 
#' - name (character): ERDDAP™ name
#' - url (character): ERDDAP™ url
#' - public (logical): whether it's public or not
#' 
#' @examples \dontrun{
#' servers()
#' }
servers <- function(...) {
  fn_env <- environment()
  surl <- "https://irishmarineinstitute.github.io/awesome-erddap/erddaps.json"
  tt <- tryCatch(
    crul::HttpClient$new(url = surl, opts = list(...))$get(),
    error = function(e) {
      cli::cli_abort(
        "Curl request failed to get server list from {.url {surl}}.",
        class  = "rerddap_http_error",
        parent = e,
        call   = fn_env
      )
    }
  )
  tt$raise_for_status()
  tibble::as_tibble(jsonlite::fromJSON(tt$parse("UTF-8")))
}
