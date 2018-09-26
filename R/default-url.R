#' Default ERDDAP server URL
#' 
#' @details default url is https://upwell.pfeg.noaa.gov/erddap/
#' 
#' You can set a default using an environment variable so you 
#' don't have to pass anything to the URL parameter in your 
#' function calls. 
#' 
#' In your .Renviron file or similar set a URL for the environment 
#' variable `RERDDAP_DEFAULT_URL`, like
#' `RERDDAP_DEFAULT_URL=https://upwell.pfeg.noaa.gov/erddap/`
#' 
#' It's important that you include a trailing slash in your URL
#'
#' @export
#' @examples
#' eurl()
#' Sys.setenv(RERDDAP_DEFAULT_URL = "https://google.com")
#' Sys.getenv("RERDDAP_DEFAULT_URL")
#' eurl()
#' Sys.unsetenv("RERDDAP_DEFAULT_URL")
#' eurl()
eurl <- function() {
  def_url <- "https://upwell.pfeg.noaa.gov/erddap/"
  url <- Sys.getenv("RERDDAP_DEFAULT_URL", "")
  if (identical(url, "")) return(def_url)
  url <- check_url(url)
  return(url)
}

check_url <- function(x) {
  # check if has scheme or not
  if (!grepl("https?://", x)) stop("Not a proper url")
  # add trailing slash if not present
  if (!grepl("\\/$", x)) paste0(x, "/") else x
}
