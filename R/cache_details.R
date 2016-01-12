#' Get details of cached files
#'
#' @export
#' @param x File names
#' @param cache_path path to cached files
#' @references \url{http://upwell.pfeg.noaa.gov/erddap/index.html}
#' @author Scott Chamberlain <myrmecocystus@@gmail.com>
#' @seealso \code{\link{cache_list}}, \code{\link{cache_delete}}
#' @examples \dontrun{
#' # List details for all cached files
#' cache_details()
#'
#' # List details for specific files
#' (x <- cache_list())
#' cache_details(x$nc[1])
#' cache_details(x$csv[1])
#'
#' # For a list or character vector of files
#' ff <- cache_list()[[1]]
#' cache_details(ff[1:3])
#' cache_details(as.list(ff[1:3]))
#'
#' # List details from output of griddap or tabledap
#' ## tabledap
#' (table_res <- tabledap('erdCalCOFIfshsiz'))
#' cache_details(table_res)
#'
#' ## griddap
#' (grid_res <- griddap('noaa_esrl_027d_0fb5_5d38',
#'  time = c('2012-01-01','2012-06-12'),
#'  latitude = c(21, 18),
#'  longitude = c(-80, -75)
#' ))
#' cache_details(grid_res)
#' }
cache_details <- function(x, cache_path = "~/.rerddap") {
  UseMethod("cache_details")
}

#' @export
cache_details.default <- function(x, cache_path = "~/.rerddap") {
  cdetails(NULL, cache_path)
}

#' @export
cache_details.tabledap <- function(x, cache_path = "~/.rerddap") {
  cdetails(basename(attr(x, "path")), cache_path)
}

#' @export
cache_details.griddap_nc <- function(x, cache_path = "~/.rerddap") {
  cdetails(basename(attr(x, "path")), cache_path)
}

#' @export
cache_details.griddap_csv <- function(x, cache_path = "~/.rerddap") {
  cdetails(basename(attr(x, "path")), cache_path)
}

#' @export
cache_details.list <- function(x, cache_path = "~/.rerddap") {
  cdetails(unlist(x), cache_path)
}

#' @export
cache_details.character <- function(x, cache_path = "~/.rerddap") {
  cdetails(x, cache_path)
}

# Helper fxn
cdetails <- function(files = NULL, cache_path = "~/.rerddap") {
  if (is.null(files)) {
    files <- list.files(cache_path, full.names = TRUE)
    structure(lapply(files, file_info_), class = "rerddap_cache_info")
  } else {
    files <- file.path(cache_path, files)
    structure(lapply(files, file_info_), class = "rerddap_cache_info")
  }
}

file_info_ <- function(x) {
  tmp <- strsplit(x, '\\.')[[1]]
  ext <- tmp[length(tmp)]
  #fs <- file.size(x)
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
            info = if (!is.na(fs)) names(read.csv(x, nrows = 1, stringsAsFactors = FALSE)) else NA
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
