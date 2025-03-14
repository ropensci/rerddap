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
  surl <- "https://irishmarineinstitute.github.io/awesome-erddap/erddaps.json"
  # tt <- crul::HttpClient$new(url = surl, opts = list(...))$get()
  response <- tryCatch(
    {
      tt <- crul::HttpClient$new(url = surl, opts = list(...))$get()  # Attempt to fetch
    },
    error = function(e) {
      message("Curl request failed to get server list: ", e$message)
      quit(save = "no", status = 1)  # Gracefully exit R session
    }
  )
  tt$raise_for_status()
  tibble::as_tibble(jsonlite::fromJSON(tt$parse("UTF-8")))
}
