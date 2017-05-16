get_cache_path <- function() { # nocov start
  path <- Sys.getenv("RERDDAP_CACHE_PATH", "")
  if (identical(path, "")) {
    path <- getOption("rerddap_cache_path")
  }
  return(path)
} # nocov end
