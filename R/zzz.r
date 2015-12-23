# Function to get UTM zone from a single longitude and latitude pair
# originally from David LeBauer I think
# @param lon Longitude, in decimal degree style
# @param lat Latitude, in decimal degree style
long2utm <- function(lon, lat) {
  if (56 <= lat & lat < 64) {
    if (0 <= lon & lon < 3) { 31 } else
      if (3 <= lon & lon < 12) { 32 } else { NULL }
  } else {
    if (72 <= lat) {
      if (0 <= lon & lon < 9) { 31 } else
        if (9 <= lon & lon < 21) { 33 } else
          if (21 <= lon & lon < 33) { 35 } else
            if (33 <= lon & lon < 42) { 37 } else { NULL }
    }
    (floor((lon + 180)/6) %% 60) + 1
  }
}

rc <- function(l) Filter(Negate(is.null), l)

read_csv <- function(x){
  tmp <- read.csv(x, header = FALSE, sep = ",", stringsAsFactors = FALSE, skip = 3)
  nmz <- names(read.csv(x, header = TRUE, sep = ",", stringsAsFactors = FALSE, skip = 1, nrows = 1))
  names(tmp) <- tolower(nmz)
  tmp
}

read_data <- function(x, nrows = -1){
  if (is(x, "response")) {
    x <- content(x, "text")
    tmp <- read.csv(text = x, header = FALSE, sep = ",", stringsAsFactors = FALSE, skip = 2, nrows = nrows)
    nmz <- names(read.csv(text = x, header = TRUE, sep = ",", stringsAsFactors = FALSE, nrows = 1))
  } else {
    tmp <- read.csv(x, header = FALSE, sep = ",", stringsAsFactors = FALSE, skip = 2, nrows = nrows)
    nmz <- names(read.csv(x, header = TRUE, sep = ",", stringsAsFactors = FALSE, nrows = 1))
  }
  setNames(tmp, tolower(nmz))
}

read_all <- function(x, fmt, read) {
  switch(fmt,
         csv = {
           if (read) {
             read_data(x)
           } else {
             read_data(x, 10)
           }
         },
         nc = {
           if (read) {
             ncdf4_get(x)
           } else {
             ncdf_summary(x)
           }
         }
  )
}

read_table <- function(x){
  if (is(x, "response")) {
    txt <- gsub('\n$', '', content(x, "text"))
    read.csv(text = txt, sep = ",", stringsAsFactors = FALSE,
             blank.lines.skip = FALSE)[-1, , drop = FALSE]
  } else {
    read.delim(x, sep = ",", stringsAsFactors = FALSE,
               blank.lines.skip = FALSE)[-1, , drop = FALSE]
  }
}

check_key <- function(x){
  tmp <- if (is.null(x)) {
    Sys.getenv("NOAA_KEY", "")
  } else {
    x
  }

  if (tmp == "") {
    getOption("noaakey", stop("need an API key for NOAA data"))
  } else {
    tmp
  }
}

pu <- function(x) sub("/$|//$", "", x)

err_handle <- function(x, store, key) {
  if (x$status_code > 201) {
    tt <- content(x, "text")
    mssg <- xml_text(xml_find_all(read_html(tt), "//h1"))
    if (store$store != "memory") unlink(file.path(store$path, key))
    stop(paste0(mssg, collapse = "\n\n"), call. = FALSE)
  }
}

err_handle2 <- function(x) {
  if (x$status_code > 201) {
    tt <- content(x, "text")
    mssg <- xml_text(xml_find_all(read_html(tt), "//h1"))
    stop(paste0(mssg, collapse = "\n\n"), call. = FALSE)
  }
}

erdddap_GET <- function(url, args = NULL, ...) {
  tt <- GET(url, query = args, ...)
  err_handle2(tt)
  stopifnot(tt$headers$`content-type` == 'application/json;charset=UTF-8')
  out <- content(tt, as = "text")
  jsonlite::fromJSON(out, FALSE)
}
