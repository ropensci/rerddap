#' Get details of cached files
#'
#' @export
#' @param x File names
#' @family cache
#' @details Can be used to list details for all files, both .nc and .csv
#' types, or details for just individual files of class \code{tabledap},
#' \code{griddap_nc}, and \code{griddap_csv}
#' @examples \dontrun{
#' # List details for all cached files
#' cache_details()
#' }
cache_details <- function(x) {
  UseMethod("cache_details")
}

#' @export
cache_details.default <- function(x) {
  cdetails(NULL)
}

#' @export
cache_details.tabledap <- function(x) {
  cdetails(basename(attr(x, "path")))
}

#' @export
cache_details.griddap_nc <- function(x) {
  cdetails(basename(attr(x, "path")))
}

#' @export
cache_details.griddap_csv <- function(x) {
  cdetails(basename(attr(x, "path")))
}

#' @export
cache_details.list <- function(x) {
  cdetails(unlist(x))
}

#' @export
cache_details.character <- function(x) {
  cdetails(x)
}

# Helper fxn
cdetails <- function(files = NULL) {
  setup_cache_path()
  if (is.null(files)) {
    files <- list.files(rrcache$cache_path_get(), full.names = TRUE)
    structure(lapply(files, file_info_), class = "rerddap_cache_info")
  } else {
    files <- file.path(rrcache$cache_path_get(), files)
    structure(lapply(files, file_info_), class = "rerddap_cache_info")
  }
}

file_info_ <- function(x) {
  tmp <- strsplit(x, '\\.')[[1]]
  ext <- tmp[length(tmp)]
  fs <- file.info(x)$size
  switch(ext,
     nc = {
       list(type = "netcdf",
            size = if (!is.na(fs)) getsize(fs) else NA,
            info = if (!is.na(fs)) ncdf_summary(x)$summary else NA
       )
     },
     csv = {
       list(type = "csv",
            size = if (!is.na(fs)) getsize(fs) else NA,
            info = if (!is.na(fs))
              names(read.csv(x, nrows = 1, stringsAsFactors = FALSE)) else NA
       )
     }
  )
}

getsize <- function(x) {
  round(x/10 ^ 6, 3)
}

#' @export
print.rerddap_cache_info <- function(x, ...) {
  cat("<rerddap cached files>", sep = "\n")
  for (i in seq_along(x)) {
    cat(paste0("Type: ", x[[i]]$type), sep = "\n")
    cat(paste0("Size: ", x[[i]]$size, " mb"), sep = "\n")
    if (x[[i]]$type == "netcdf") {
      cat("info: ", sep = "\n")
      if (!any(is.na(x[[i]]$info))) {
        print(x[[i]]$info)
      }
    } else {
      cat("info: (csv columns)", sep = "\n")
      if (!any(is.na(x[[i]]$info))) {
        print(x[[i]]$info)
      }
    }
    cat("\n")
  }
}
