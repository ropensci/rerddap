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
  tmp <- read.csv(x, header = FALSE, sep = ",", stringsAsFactors = FALSE,
                  skip = 3)
  nmz <- names(read.csv(x, header = TRUE, sep = ",", stringsAsFactors = FALSE,
                        skip = 1, nrows = 1))
  names(tmp) <- tolower(nmz)
  tmp
}

read_data <- function(x, nrows = -1){
  if (inherits(x, "HttpResponse")) {
    x <- x$parse("UTF-8")
    tmp <- read.csv(text = x, header = FALSE, sep = ",",
                    stringsAsFactors = FALSE, skip = 2, nrows = nrows)
    nmz <- names(read.csv(text = x, header = TRUE, sep = ",",
                          stringsAsFactors = FALSE, nrows = 1))
  } else {
    tmp <- read.csv(x, header = FALSE, sep = ",", stringsAsFactors = FALSE,
                    skip = 2, nrows = nrows)
    nmz <- names(read.csv(x, header = TRUE, sep = ",",
                          stringsAsFactors = FALSE, nrows = 1))
  }
  stats::setNames(tmp, tolower(nmz))
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

read_table <- function(x, fmt){
  if (inherits(x, "HttpResponse")) {
    txt <- gsub('\n$', '', x$parse("UTF-8"))
    read.csv(text = txt, sep = ",", stringsAsFactors = FALSE,
             blank.lines.skip = FALSE)[-1, , drop = FALSE]
  } else {
    if (fmt =='csv') {
      read.delim(x, sep = ",", stringsAsFactors = FALSE,
                 blank.lines.skip = FALSE)[-1, , drop = FALSE]
    }  else {
      temp_data <- nanoparquet::read_parquet(x)[-1, , drop = FALSE]
    }
  }
}

replace_value_with_na <- function(x, fillValue) {
  if (is.numeric(x)) {
    test_value <- as.numeric(fillValue)
    x[x == test_value] <- NA
  }
  return(x)
}


pu <- function(x) sub("/$|//$", "", x)

strect <- function (str, pattern) regmatches(str, regexpr(pattern, str))

err_handle <- function(x, store, key) {
  if (x$status_code > 201) {
    tt <- if (store$store == "disk") x$content else x$parse("UTF-8")
    html <- tryCatch(read_html(tt), error = function(e) e)
    if (inherits(html, "error")) {
      mssg <- tt
    } else {
      mssg <- xml_text(xml_find_all(html, '//body//p[text()[contains(., "Error") or contains(., "error")]]')) %||% ""
      mssg <- sub("Message\\s", "", mssg)
      if (!nzchar(mssg)) {
        mssg <- strect(xml_text(xml_find_first(html, '//body')), "Query error.+")
      }
    }
    if (store$store != "memory") unlink(file.path(store$path, key))
    stop(paste0(mssg, collapse = "\n\n"), call. = FALSE)
  }
}

err_handle2 <- function(x) {
  if (x$status_code > 201) {
    tt <- x$parse("UTF-8")
    mssg <- xml_text(xml_find_all(read_html(tt), "//h1"))
    stop(paste0(mssg, collapse = "\n\n"), call. = FALSE)
  }
}

erdddap_GET <- function(url, args = NULL, ...) {
  cli <- crul::HttpClient$new(url = url, opts = list(...))
  tt <- cli$get(query = args)
  err_handle2(tt)
  stopifnot(tt$response_headers$`content-type` == 'application/json;charset=UTF-8')
  out <- tt$parse("UTF-8")
  jsonlite::fromJSON(out, FALSE)
}

url_build <- function(url, args = NULL) {
  if (is.null(args)) return(url)
  paste0(url, "?", args)
}

`%||%` <- function (x, y) {
  if (is.null(x) || length(x) == 0) y else x
}
