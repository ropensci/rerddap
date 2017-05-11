# return path suffix
get_cache_path <- function(path_suffix = NULL) {
  path <- Sys.getenv("RERDDAP_CACHE_PATH_SUFFIX", "")
  if (identical(path, "")) {
    path <- getOption("rerddap_cache_path_suffix")
  }

  if (is.null(path)) {
    path <- path_suffix
  }

  return(path)
}

# setup full cache path with optional user supplied path suffix
setup_cache_path <- function(path_suffix = NULL) {
  if (is.null(path_suffix)) path_suffix <- get_cache_path()

  # If already set, nothing to do.
  if (!is.null(path_suffix)) {
    rrcache$cache_path_set(path_suffix)
    rrcache$mkdir()
    return(invisible(rrcache$cache_path_get()))
  }

  if (interactive()) {
    defpath <- rrcache$cache_path_set("rerddap")
    if (dir.exists(defpath)) {
      path <- defpath
    } else {
      prompt <- "rerddap needs to create a directory to cache files\n"
      prompt <- c(
        prompt,
        sprintf(
          "Create the '%s' directory? If not (No), a temp directory that expires after this R session will be used.",
          defpath
        )
      )
      prompt <- paste(prompt, collapse="")
      tryCatch({
        cat(prompt, "\nYes (y) or No (n)")
        ans <- scan(n = 1, quiet = TRUE, what = 'raw')
        ans <- match.arg(ans, c('yes', 'no'))
      }, condition = function(ex) {})
      path <- switch(
        ans,
        yes = {
          defpath
          rrcache$mkdir()
        },
        no = {
          rrcache$cache_path_set(path_suffix %||% "rerddap", type = "tempdir")
          rrcache$cache_path_get()
          rrcache$mkdir()
        }
      )
    }
  } else {
    defpath <- rrcache$cache_path_set("rerddap")
    if (dir.exists(defpath)) {
      path <- defpath
      message(defpath, " found - using it for caching")
    } else {
      rrcache$cache_path_set(path_suffix %||% "rerddap", type = "tempdir")
      path <- rrcache$cache_path_get()
      rrcache$mkdir()
    }
  }

  # return invisibly
  invisible(path)
}
