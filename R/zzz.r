# Function to get UTM zone from a single longitude and latitude pair
# originally from David LeBauer I think
# @param lon Longitude, in decimal degree style
# @param lat Latitude, in decimal degree style
long2utm <- function(lon, lat) {
  if(56 <= lat & lat < 64){
    if(0 <= lon & lon < 3){ 31 } else
      if(3 <= lon & lon < 12) { 32 } else { NULL }
  } else
  if(72 <= lat) {
    if(0 <= lon & lon < 9){ 31 } else
      if(9 <= lon & lon < 21) { 33 } else
        if(21 <= lon & lon < 33) { 35 } else
          if(33 <= lon & lon < 42) { 37 } else { NULL }
  }
  (floor((lon + 180)/6) %% 60) + 1
}

#' Check response from NOAA, including status codes, server error messages, mime-type, etc.
#' @keywords internal
check_response <- function(x){
  if(!x$status_code == 200){
    stnames <- names(content(x))
    if(!is.null(stnames)){
      if('developerMessage' %in% stnames|'message' %in% stnames){
        warning(sprintf("Error: (%s) - %s", x$status_code,
                        rc(list(content(x)$developerMessage, content(x)$message))))
      } else { warning(sprintf("Error: (%s)", x$status_code)) }
    } else { warn_for_status(x) }
  } else {
    stopifnot(x$headers$`content-type`=='application/json;charset=UTF-8')
    res <- content(x, as = 'text', encoding = "UTF-8")
    out <- jsonlite::fromJSON(res, simplifyVector = FALSE)
    if(!'results' %in% names(out)){
      if(length(out)==0){ warning("Sorry, no data found") }
    } else {
      if( class(try(out$results, silent=TRUE))=="try-error" | is.null(try(out$results, silent=TRUE)) )
        warning("Sorry, no data found")
    }
    return( out )
  }
}

#' Check response from NOAA, including status codes, server error messages, mime-type, etc.
#' @keywords internal
check_response_erddap <- function(x){
  if(!x$status_code == 200){
    html <- content(x)
    values <- xpathApply(html, "//u", xmlValue)
    error <- grep("Error", values, ignore.case = TRUE, value = TRUE)
    if(length(error) > 1) error <- error[1]
    #check specifically for no matching results error
    if(grepl("no matching results", error)) error <- 'Error: Your query produced no matching results.'

    if(!is.null(error)){
      if(grepl('Error', error)){
        warning(sprintf("(%s) - %s", x$status_code, error))
      } else { warning(sprintf("Error: (%s)", x$status_code)) }
    } else { warn_for_status(x) }
  } else {
    stopifnot(x$headers$`content-type`=='text/csv;charset=UTF-8')
    x
#     content(x, as = 'text', encoding = "UTF-8")
  }
}

rc <- function (l) Filter(Negate(is.null), l)

read_csv <- function(x){
  tmp <- read.csv(x, header = FALSE, sep = ",", stringsAsFactors=FALSE, skip = 3)
  nmz <- names(read.csv(x, header = TRUE, sep = ",", stringsAsFactors=FALSE, skip = 1, nrows=1))
  names(tmp) <- tolower(nmz)
  tmp
}

read_upwell <- function(x){
  if(is(x, "response")) {
    x <- content(x, "text")
    tmp <- read.csv(text = x, header = FALSE, sep = ",", stringsAsFactors=FALSE, skip = 2)
    nmz <- names(read.csv(text = x, header = TRUE, sep = ",", stringsAsFactors=FALSE, nrows=1))
  } else {
    tmp <- read.csv(x, header = FALSE, sep = ",", stringsAsFactors=FALSE, skip = 2)
    nmz <- names(read.csv(x, header = TRUE, sep = ",", stringsAsFactors=FALSE, nrows=1))
  }
  names(tmp) <- tolower(nmz)
  tmp
}

read_table <- function(x){
  if(is(x, "response")) {
    txt <- gsub('\n$', '', content(x, "text"))
    read.csv(text = txt, sep = ",", stringsAsFactors=FALSE,
             blank.lines.skip=FALSE)[-1, , drop=FALSE]
  } else {
    read.delim(x, sep=",", stringsAsFactors=FALSE,
               blank.lines.skip=FALSE)[-1, , drop=FALSE]
  }
}

check_key <- function(x){
  tmp <- if(is.null(x)) Sys.getenv("NOAA_KEY", "") else x
  if(tmp == "") getOption("noaakey", stop("need an API key for NOAA data")) else tmp
}

pu <- function(x) sub("/$|//$", "", x)
