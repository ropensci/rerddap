#' Get ERDDAP gridded data
#'
#' @export
#' @template griddap_params
#' @template griddap_egs
griddap <- function(datasetx, ..., fields = 'all', stride = 1, fmt = "nc",
  url = eurl(), store = disk(), read = TRUE, callopts = list()) {
  x <- datasetx
  calls <- names(sapply(match.call(), deparse))[-1]
  calls_vec <- "ncdf" %in% calls
  if (any(calls_vec)) {
    stop(
      "The parameter ncdf has been removed. We use ncdf4 package now internally",
         call. = FALSE)
  }

  dimargs <- list(...)
  if (length(dimargs) == 0) stop("no dimension arguments passed, see ?griddap")
  if (inherits(x, "info")) {
    url <- x$base_url
    message("info() output passed to x; setting base url to: ", url)
  } else {
    x <- as.info(x, url)
  }
  if (attr(x, "type") != "griddap")
    stop("datasetid '", attr(x, "datasetid"), "' not of type griddap")
  check_dims(dimargs, x)
  if (!is.null(dimargs$time)) {
    check_time_range(dimargs, x)
  }
  check_lat_text(dimargs)
  check_lon_text(dimargs)
  dimargs <- fix_dims(dimargs, .info = x)
  check_lon_data_range(dimargs, x)
  check_lat_data_range(dimargs, x)
  d <- attr(x, "datasetid")
  var <- field_handler(fields, x$variables$variable_name)
  dims <- dimvars(x)
  store <- toggle_store(fmt, store)
  if (all(var == "none")) {
    args <- paste0(sapply(dims, function(y) {
      parse_args(x, y, stride, dimargs, wname = TRUE)
    }), collapse = ",")
  } else {
    pargs <- sapply(dims, function(y) parse_args(x, y, stride, dimargs))
    args <- paste0(lapply(var, function(y) {
      paste0(y, paste0(pargs, collapse = ""))
    }), collapse = ",")
  }
  fmt <- match.arg(fmt, c("nc", "csv"))
  lenURL <- nchar(url)
  if (substr(url, lenURL, lenURL) != '/') {
    url <- paste0(url, '/')
  }
  resp <- erd_up_GET(url = sprintf("%sgriddap/%s.%s", url, d, fmt), dset = d,
                     args = args, store = store, fmt = fmt, callopts)
  loc <- if (store$store == "disk") resp else "memory"
  outclasses <- switch(fmt,
                       nc = c("griddap_nc", "nc", "list"),
                       csv = c("griddap_csv", "csv", "data.frame"))
  read <- toggle_read(read, store)
  structure(
    read_all(resp, fmt, read),
    class = outclasses,
    datasetid = d,
    path = loc,
    url = url_build(sprintf("%sgriddap/%s.%s", url, d, fmt), args)
  )
}

toggle_read <- function(x, store) {
  if (store$store == "memory") {
    return(TRUE)
  } else {
    return(x)
  }
}

toggle_store <- function(fmt, store) {
  if (fmt == "nc") {
    if (store$store == "memory") {
      disk()
    } else {
      store
    }
  } else {
    store
  }
}

#' @export
print.griddap_csv <- function(x, ...) {
  finfo <- file_info(attr(x, "path"))
  cat(sprintf("<ERDDAP griddap> %s", attr(x, "datasetid")), sep = "\n")
  path <- attr(x, "path")
  path2 <- if (file.exists(path)) path else "<beware: file deleted>"
  cat(sprintf("   Path: [%s]", path2), sep = "\n")
  if (attr(x, "path") != "memory") {
    cat(sprintf("   Last updated: [%s]", finfo$mtime), sep = "\n")
    cat(sprintf("   File size:    [%s mb]", finfo$size), sep = "\n")
  }
  cat(sprintf("   Dimensions:   [%s X %s]\n", NROW(x), NCOL(x)), sep = "\n")
  print(tibble::as_tibble(x))
}

#' @export
print.griddap_nc <- function(x, ...) {
  finfo <- file_info(attr(x, "path"))
  cat(sprintf("<ERDDAP griddap> %s", attr(x, "datasetid")), sep = "\n")
  path <- attr(x, "path")
  path2 <- if (file.exists(path)) path else "<beware: file deleted>"
  cat(sprintf("   Path: [%s]", path2), sep = "\n")
  if (attr(x, "path") != "memory") {
    cat(sprintf("   Last updated: [%s]", finfo$mtime), sep = "\n")
    cat(sprintf("   File size:    [%s mb]", finfo$size), sep = "\n")
  }
  cat(sprintf("   Dimensions (dims/vars):   [%s X %s]", x$summary$ndims, x$summary$nvars), sep = "\n")
  cat(sprintf("   Dim names: %s", paste0(names(x$summary$dim), collapse = ", ")), sep = "\n")
  cat(sprintf("   Variable names: %s", paste0(unname(sapply(x$summary$var, "[[", "longname")), collapse = ", ")), sep = "\n")
  cat(sprintf("   data.frame (rows/columns):   [%s X %s]", dim(x$data)[1], dim(x$data)[2]), sep = "\n\n")
  print(tibble::as_tibble(x$data))
}

field_handler <- function(x, y){
  x <- match.arg(x, c(y, "none", "all"), TRUE)
  if (length(x) == 1 && x == "all") {
    y
  } else if (all(x %in% y) || x == "none") {
    x
  }
}

check_dims <- function(dimargs, .info) {
  if (any(lengths(dimargs )!= 2)) {
    print("All coordinate bounds must be of length 2, even if same value")
    print("Present values are:") 
    print(dimargs)
    stop("rerddap halted", call. = FALSE)
  }
  if (!all(names(dimargs) %in% dimvars(.info))) {
    stop(sprintf("Some input dimensions (%s) don't match those in dataset (%s)",
                 paste0(names(dimargs), collapse = ", "),
                 paste0(dimvars(.info), collapse = ", ")), call. = FALSE)
  }
}

check_lon_text <- function(dimargs) {
  if (!is.null(dimargs$longitude)) {
    if (any(sapply(dimargs$longitude, class) == "character")) {
      txt <- dimargs$longitude[sapply(dimargs$longitude, class) == "character"]
      if (!all(grepl("last", txt))) stop("Only text values allowed are 'last' & variants on that", call. = FALSE)
    }
  }
}

check_lat_text <- function(dimargs) {
  if (!is.null(dimargs$latitude)) {
    if (any(sapply(dimargs$latitude, class) == "character")) {
      txt <- dimargs$latitude[sapply(dimargs$latitude, class) == "character"]
      if (!all(grepl("last", txt))) stop("Only text values allowed are 'last' & variants on that", call. = FALSE)
    }
  }
}

is_lon_text <- function(dimargs) {
  if (!is.null(dimargs$longitude)) {
    any(sapply(dimargs$longitude, class) == "character")
  } else {
    FALSE
  }
}

is_lat_text <- function(dimargs) {
  if (!is.null(dimargs$latitude)) {
    any(sapply(dimargs$latitude, class) == "character")
  } else {
    FALSE
  }
}

check_time_range <- function(dimargs, x) {
#  if(!class(dimargs$time) == 'character'){
  if(!is.character(dimargs$time)){
    print('time must be given as character strings')
    print('you are passing ', paste0(class(dimargs$time)))
    stop('rerddap halted', call. = FALSE)
  }
  global <- x$alldata$NC_GLOBAL
  tt <- global[ global$attribute_name %in%c('time_coverage_end','time_coverage_start'), "value", ]
  tt <- rev(tt)
  if (!('last' %in% dimargs$time)){
      if((dimargs$time[1] < tt[1]) | (dimargs$time[2] > tt[2])) {
        print('time bounds are out of range')
        print('You gave: ') 
        print(dimargs$time)
        print("Dataset times are: ")
        print(tt)
        stop('rerddap halted', call. = FALSE)
      }
  }
}


check_lon_data_range <- function(dimargs, .info) {
  if (!is.null(dimargs$longitude)) {
    val <- .info$alldata$longitude[ .info$alldata$longitude$attribute_name == "actual_range", "value"]
    val2 <- as.numeric(strtrim(strsplit(val, ",")[[1]]))
    if (!is_lon_text(dimargs)) {
      if (max(dimargs$longitude) > max(val2) || min(dimargs$longitude) < min(val2)) {
        stop(sprintf("One or both longitude values (%s) outside data range (%s)",
                     paste0(dimargs$longitude, collapse = ", "),
                     paste0(val2, collapse = ", ")), call. = FALSE)
      }
    }
  }
}

check_lat_data_range <- function(dimargs, .info) {
  if (!is.null(dimargs$latitude)) {
    val <- .info$alldata$latitude[ .info$alldata$latitude$attribute_name == "actual_range", "value"]
    val2 <- as.numeric(strtrim(strsplit(val, ",")[[1]]))
    if (!is_lat_text(dimargs)) {
      if (max(dimargs$latitude) > max(val2) || min(dimargs$latitude) < min(val2)) {
        stop(sprintf("One or both latitude values (%s) outside data range (%s)",
                     paste0(dimargs$latitude, collapse = ", "),
                     paste0(val2, collapse = ", ")), call. = FALSE)
      }
    }
  }
}

fix_dims <- function(dimargs, .info) {
  for (i in seq_along(dimargs)) {
    tmp <- dimargs[[i]]
    nm <- names(dimargs[i])
    tmp <- grep("last+", tmp, value = TRUE, invert = TRUE)
    if (nm == "time") {
      tmp <- as.Date(tmp)
    }
    
    val <- .info$alldata[[nm]][ .info$alldata[[nm]]$attribute_name == "actual_range", "value"]
    val2 <- as.numeric(strtrim(strsplit(val, ",")[[1]]))
    if (length(tmp) != 0) {
      if (which.min(val2) != which.min(tmp)) {
        dimargs[[i]] <- rev(dimargs[[i]])
      }
    }
    
    ## new
    # if (nm %in% c('latitude', 'longitude')) {
    if (nm != 'time') {
      z <- unlist(strsplit(.info$alldata[[nm]]$value[1], ","))
      spacing <- as.numeric(unlist(strsplit(z[3], "=")[[1]])[2])
      if ((!is.na(spacing)) & (spacing < 0)) {
        if (!(dimargs[[i]][1] > dimargs[[i]][2])) {
          dimargs[[i]] <- rev(dimargs[[i]])
        }
      }
    }
  }
  dimargs
}

parse_args <- function(.info, dim, s, dimargs, wname = FALSE){
  tmp <- if (dim %in% names(dimargs)) {
    dimargs[[dim]]
  } else {
    if (dim == "time") {
      times <- c(getvar(.info, "time_coverage_start"), getvar(.info, "time_coverage_end"))
      sprintf('[(%s):%s:(%s)]', times[1], s, times[2])
    } else {
      actrange <- foo(.info$alldata[[dim]], "actual_range")
      gsub("\\s+", "", strsplit(actrange, ",")[[1]])
    }
  }

  if (length(s) > 1) {
    if (!length(s) == length(dimvars(.info))) stop("Your stride vector must equal length of dimension variables", call. = FALSE)
    names(s) <- dimvars(.info)
    if (!wname) {
      sprintf('[(%s):%s:(%s)]', tmp[1], s[[dim]], tmp[2])
    } else {
      sprintf('%s[(%s):%s:(%s)]', dim, tmp[1], s[[dim]], tmp[2])
    }
  } else {
    if (!wname) {
      if (length(tmp) == 1) {
        tmp
      } else {
        sprintf('[(%s):%s:(%s)]', tmp[1], s, tmp[2])
      }
    } else {
      if (length(tmp) == 1) {
        tmp
      } else {
        sprintf('%s[(%s):%s:(%s)]', dim, tmp[1], s, tmp[2])
      }
    }
  }
}

getvar <- function(x, y){
  x$alldata$NC_GLOBAL[ x$alldata$NC_GLOBAL$attribute_name == y, "value"]
}

getvars <- function(x){
  vars <- names(x$alldata)
  vars[ !vars %in% c("NC_GLOBAL", "time", x$variables$variable_name) ]
}

getallvars <- function(x){
  vars <- names(x$alldata)
  vars[ !vars %in% "NC_GLOBAL" ]
}

dimvars <- function(x){
  vars <- names(x$alldata)
  vars[ !vars %in% c("NC_GLOBAL", x$variables$variable_name) ]
}

erd_up_GET <- function(url, dset, args, store, fmt, callopts) {
  if (length(args) > 0) url <- sprintf("%s?%s", url, args)
  url1 <- url
  url1 <- gsub('\\[', '%5B', url1)
  url1 <- gsub('\\]', '%5D', url1)
  cli <- crul::HttpClient$new(url = url1, opts = callopts)
  if (store$store == "disk") {
    # store on disk
    key <- gen_key(url, args, fmt)
    if ( file.exists(file.path(store$path, key)) ) {
      file.path(store$path, key)
    } else {
      dir.create(store$path, showWarnings = FALSE, recursive = TRUE)
      if (!store$overwrite) {
        stop('overwrite was `FALSE`, see ?disk')
      }
      res <- cli$get(disk = file.path(store$path, key))
      # delete file if error, and stop message
      err_handle(res, store, key)
      # return file path
      res$content
    }
  } else {
    # read into memory, bypass disk storage
    res <- cli$get()
    # if error stop message
    err_handle(res, store, key)
    # return response object
    res
  }
}

writepath <- function(path, d, fmt) file.path(path, paste0(d, ".", fmt))

gen_key <- function(url, args, fmt) {
  ky <- paste0(url, "?", args)
  paste0(digest::digest(ky), ".", fmt)
}

# libfile <- function() file.path(path.expand("~/.rerddap"), ".library")

# hash_file <- function(x) {
#   if (!file.exists(x)) {
#     cat("\n", file = x)
#   }
# }

# write_key <- function(path, key) {
#   hash_file(path)
#   cat("- ", key, file = path, append = TRUE)
# }

file_info <- function(x) {
  tmp <- file.info(x)
  row.names(tmp) <- NULL
  tmp2 <- tmp[,c('mtime', 'size')]
  tmp2$size <- round(tmp2$size/1000000L, 2)
  tmp2
}

strextract <- function(str, pattern) regmatches(str, regexpr(pattern, str))

strtrim <- function(str) gsub("^\\s+|\\s+$", "", str)
