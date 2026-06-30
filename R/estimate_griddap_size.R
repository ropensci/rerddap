#' Estimate the size of a rerddap::griddap() request
#'
#' Uses coordinate metadata from an ERDDAP info() object to estimate how
#' many grid cells will be returned and the total uncompressed byte count for
#' each requested data variable.  No network request is made.
#'
#' Coordinate dimension names are taken directly from the info object using
#' the same logic as rerddap:::dimvars() — the set-difference between all
#' keys in info$alldata and the data variable names plus "NC_GLOBAL".  This
#' means any coordinate system works: geographic lat/lon, projected x/y,
#' sigma-layer depth, ROMS xi_rho/eta_rho, etc.
#'
#' Dimension constraints are passed via ... using the exact coordinate
#' variable names reported by the dataset, the same way griddap() accepts
#' them.  Each constraint is a numeric (or character for time) vector of
#' length 2: c(min, max).
#'
#' Spacing is resolved in this order for each dimension:
#'   1. User-supplied override in the spacing argument.
#'   2. For time: (t_max - t_min) / (nValues - 1) derived from the
#'      dimension's nValues row and actual_range attribute.  This correctly
#'      handles running composites where time steps are daily even though the
#'      composite window is e.g. 8 days.
#'   3. NC_GLOBAL attributes: geospatial_lat_resolution,
#'      geospatial_lon_resolution, time_coverage_resolution (ISO 8601).
#'   4. Coordinate variable attributes: point_spacing, resolution, spacing.
#'   5. For time: averageSpacing string from the nValues row as a last resort.
#'   6. If the constraint min == max the dimension contributes 1 point.
#'   7. Otherwise: NA — a warning is issued and 1 point is assumed.
#'
#' @param info    An object returned by rerddap::info().
#' @param ...     Named dimension constraints, one per coordinate variable to
#'                constrain.  Names must exactly match the coordinate variable
#'                names in the dataset (as returned by dimvars(info)).
#'                Each value is c(min, max); for time use ISO 8601 strings.
#' @param fields  Character vector of data variable names, or "all" (default).
#' @param stride  Integer scalar or named list of per-dimension stride values,
#'                using the same convention as griddap().  Default 1.
#' @param spacing Optional named list to override auto-detected spacing for
#'                one or more dimensions.  For time, supply seconds as
#'                time_sec (e.g. spacing = list(time_sec = 86400)).
#'                For other dimensions use the coordinate variable name
#'                (e.g. spacing = list(latitude = 0.01, xi_rho = 1)).
#' @param verbose Logical; print a formatted summary (default TRUE).
#'
#' @return Invisibly, a named list containing per-dimension point counts,
#'         spacing values, per-variable byte estimates, and total bytes.
#'
#' @examples
#' \dontrun{
#'   library(rerddap)
#'
#'   myURL <- "https://coastwatch.pfeg.noaa.gov/erddap/"
#'   response <- try(httr::HEAD(myURL, httr::timeout(10)), silent = TRUE)
#'   if (inherits(response, "try-error")) {
#'      stop("The ERDDAP\u2122 server is not responding")
#'   }
#'   info <- rerddap::info("erdMH1chla8day", url = myURL)
#'   estimate_griddap_size(info,
#'     latitude  = c(30, 50),
#'     longitude = c(-140, -110),
#'     time      = c("2020-01-01", "2020-12-31"))
#' }

estimate_griddap_size <- function(info,
                                  ...,
                                  fields  = "all",
                                  stride  = 1L,
                                  spacing = list(),
                                  verbose = TRUE) {
  
  # ── helpers ──────────────────────────────────────────────────────────────
  
  `%||%` <- function(a, b) if (!is.null(a)) a else b
  
  .attr <- function(var_name, attr_names) {
    if (!var_name %in% names(info$alldata)) return(NA_character_)
    df  <- info$alldata[[var_name]]
    for (a in attr_names) {
      val <- df$value[df$attribute_name == a]
      if (length(val) && !is.na(val[1L]) && nzchar(val[1L]))
        return(as.character(val[1L]))
    }
    NA_character_
  }
  
  .bytes <- function(dtype) {
    switch(tolower(as.character(dtype)),
           "float"   = , "float32" = , "real"    = 4L,
           "double"  = , "float64" = 8L,
           "int"     = , "int32"   = , "integer" = 4L,
           "short"   = , "int16"   = 2L,
           "byte"    = , "int8"    = , "ubyte"   = 1L,
           "long"    = , "int64"   = 8L,
           "ushort"  = , "uint16"  = 2L,
           "uint"    = , "uint32"  = 4L,
           "string"  = , "char"    = 1L,
           8L
    )
  }
  
  .fmt <- function(b) {
    if      (b < 1024^1) sprintf("%.1f B",  b)
    else if (b < 1024^2) sprintf("%.1f KB", b / 1024)
    else if (b < 1024^3) sprintf("%.1f MB", b / 1024^2)
    else                 sprintf("%.2f GB", b / 1024^3)
  }
  
  .iso_to_sec <- function(x) {
    if (is.null(x) || is.na(x) || !nzchar(x)) return(NA_real_)
    x <- trimws(as.character(x))
    if (!grepl("^P", x, ignore.case = TRUE)) return(NA_real_)
    body   <- sub("^P", "", x, ignore.case = TRUE)
    parts  <- strsplit(body, "T", fixed = TRUE)[[1L]]
    date_s <- parts[1L]
    time_s <- if (length(parts) > 1L) parts[2L] else ""
    rx <- function(s, unit) {
      m <- regmatches(s, regexpr(paste0("[0-9.]+(?=", unit, ")"), s, perl = TRUE))
      if (length(m)) as.numeric(m) else 0
    }
    out <- rx(date_s, "[Yy]") * 365.25 * 86400 +
      rx(date_s, "[Mm]") *  30.44 * 86400 +
      rx(date_s, "[Ww]") *      7 * 86400 +
      rx(date_s, "[Dd]") *          86400 +
      rx(time_s, "[Hh]") *           3600 +
      rx(time_s, "[Mm]") *             60 +
      rx(time_s, "[Ss]")
    if (out == 0) NA_real_ else out
  }
  
  ## Derive time spacing from (t_max - t_min) / (nValues - 1).
  ## This is the most reliable method: it reflects the actual number of time
  ## steps in the dataset regardless of whether the dataset is a running
  ## composite (daily steps) or a true N-day snapshot (N-day steps).
  .time_spacing_from_nvalues <- function(vname) {
    df <- info$alldata[[vname]]
    
    # nValues is in the row_type == "dimension" row
    dim_row <- df$value[df$row_type == "dimension"]
    if (!length(dim_row)) return(NA_real_)
    m <- regmatches(dim_row, regexpr("(?<=nValues=)[0-9]+", dim_row, perl = TRUE))
    if (!length(m)) return(NA_real_)
    nval <- as.integer(m)
    if (is.na(nval) || nval < 2L) return(NA_real_)
    
    # actual_range is "t_min, t_max" in seconds since epoch
    range_str <- df$value[df$attribute_name == "actual_range"]
    if (!length(range_str)) return(NA_real_)
    rng <- suppressWarnings(as.numeric(strsplit(range_str, ",\\s*")[[1L]]))
    if (length(rng) < 2L || any(is.na(rng))) return(NA_real_)
    
    span <- abs(rng[2L] - rng[1L])
    if (span == 0) return(NA_real_)
    span / (nval - 1L)
  }
  
  ## Parse ERDDAP averageSpacing string as a last resort,
  ## e.g. "nValues=890, evenlySpaced=false, averageSpacing=7 days 23h 40m 34s"
  .avg_spacing_to_sec <- function(vname) {
    df      <- info$alldata[[vname]]
    avg_str <- df$value[df$row_type == "dimension"]
    if (!length(avg_str)) return(NA_real_)
    m <- regmatches(avg_str, regexpr("averageSpacing=.+", avg_str))
    if (!length(m)) return(NA_real_)
    s    <- sub("averageSpacing=", "", m)
    pick <- function(pattern) {
      x <- regmatches(s, regexpr(pattern, s, perl = TRUE))
      if (length(x)) as.numeric(x) else 0
    }
    total <- pick("[0-9]+(?= days?)") * 86400 +
      pick("[0-9]+(?=h)")      *  3600 +
      pick("[0-9]+(?=m)")      *    60 +
      pick("[0-9]+(?=s)")
    if (total > 0) total else NA_real_
  }
  
  .stride_for <- function(dim_name) {
    s <- if (is.list(stride)) {
      stride[[dim_name]] %||% stride[["default"]] %||% 1L
    } else {
      as.integer(stride)
    }
    max(1L, as.integer(s))
  }
  
  # ── get dimension variable names ──────────────────────────────────────────
  dim_vars <- dimvars(info)
  
  if (length(dim_vars) == 0L)
    stop("No dimension variables found in info object. ",
         "Is this a griddap (not tabledap) dataset?")
  
  # ── collect and validate user dimension constraints ───────────────────────
  dimargs <- list(...)
  
  unknown <- setdiff(names(dimargs), dim_vars)
  if (length(unknown))
    warning("Dimension(s) not in dataset, ignoring: ",
            paste(unknown, collapse = ", "),
            "\n  Available: ", paste(dim_vars, collapse = ", "))
  
  dimargs <- dimargs[intersect(names(dimargs), dim_vars)]
  
  # ── detect whether a dimension is time-like ───────────────────────────────
  .is_time_dim <- function(vname) {
    if (tolower(vname) == "time") return(TRUE)
    units_val <- .attr(vname, "units")
    !is.na(units_val) && grepl("since", units_val, ignore.case = TRUE)
  }
  
  # ── resolve spacing for each dimension ───────────────────────────────────
  dim_spacing <- stats::setNames(lapply(dim_vars, function(vname) {
    
    ## 1. User override by coordinate name
    if (!is.null(spacing[[vname]]))
      return(list(value = abs(as.numeric(spacing[[vname]])), source = "user"))
    
    ## 2. Time dimension
    if (.is_time_dim(vname)) {
      if (!is.null(spacing[["time_sec"]]))
        return(list(value = as.numeric(spacing[["time_sec"]]),
                    source = "user (time_sec)"))
      
      # Primary: derive from (t_max - t_min) / (nValues - 1) — correctly
      # handles running composites with daily steps
      sec <- .time_spacing_from_nvalues(vname)
      if (!is.na(sec))
        return(list(value = sec, source = "nValues / actual_range"))
      
      # Secondary: NC_GLOBAL ISO 8601 duration
      raw <- .attr("NC_GLOBAL", c("time_coverage_resolution", "time_resolution"))
      sec <- .iso_to_sec(raw)
      if (!is.na(sec))
        return(list(value = sec, source = paste0("NC_GLOBAL (", raw, ")")))
      
      # Last resort: averageSpacing string in the nValues row
      sec <- .avg_spacing_to_sec(vname)
      if (!is.na(sec))
        return(list(value = sec, source = "dimension averageSpacing"))
      
      return(list(value = NA_real_, source = "unknown"))
    }
    
    ## 3. Latitude-like dimension
    if (grepl("^lat", tolower(vname))) {
      v <- suppressWarnings(as.numeric(.attr("NC_GLOBAL",
                                             c("geospatial_lat_resolution", "geospatial_lat_step"))))
      if (!is.na(v) && v > 0)
        return(list(value = abs(v), source = "NC_GLOBAL::geospatial_lat_resolution"))
    }
    
    ## 4. Longitude-like dimension
    if (grepl("^lon", tolower(vname))) {
      v <- suppressWarnings(as.numeric(.attr("NC_GLOBAL",
                                             c("geospatial_lon_resolution", "geospatial_lon_step"))))
      if (!is.na(v) && v > 0)
        return(list(value = abs(v), source = "NC_GLOBAL::geospatial_lon_resolution"))
    }
    
    ## 5. Generic: check coordinate variable's own attributes
    v <- suppressWarnings(as.numeric(.attr(vname,
                                           c("point_spacing", "resolution", "spacing",
                                             "geospatial_vertical_resolution"))))
    if (!is.na(v) && v > 0)
      return(list(value = abs(v), source = paste0(vname, "::point_spacing")))
    
    list(value = NA_real_, source = "unknown")
  }), dim_vars)
  
  # ── compute n_points for each constrained dimension ───────────────────────
  dim_npts <- stats::setNames(lapply(dim_vars, function(vname) {
    constraint <- dimargs[[vname]]
    if (is.null(constraint)) return(NA_integer_)
    
    if (length(constraint) != 2L)
      stop("Constraint for '", vname, "' must be c(min, max)")
    
    vals <- if (.is_time_dim(vname)) {
      as.numeric(as.POSIXct(constraint, tz = "UTC"))
    } else {
      as.numeric(constraint)
    }
    span <- abs(vals[2L] - vals[1L])
    if (span == 0) return(1L)
    
    sp <- dim_spacing[[vname]]$value
    if (is.na(sp) || sp <= 0) {
      warning("Spacing unknown for '", vname,
              "'; assuming 1 point. Use spacing = list(", vname,
              " = <value>) to override.")
      return(1L)
    }
    floor(span / sp) + 1L
  }), dim_vars)
  
  dim_npts_strided <- stats::setNames(lapply(dim_vars, function(vname) {
    n <- dim_npts[[vname]]
    if (is.na(n)) return(NA_integer_)
    ceiling(n / .stride_for(vname))
  }), dim_vars)
  
  constrained   <- dim_vars[!vapply(dim_npts, is.na, logical(1L))]
  unconstrained <- dim_vars[ vapply(dim_npts, is.na, logical(1L))]
  
  n_cells <- prod(unlist(dim_npts_strided[constrained]))
  
  # ── data variables ────────────────────────────────────────────────────────
  all_vars <- info$variables
  req_vars <- if (identical(fields, "all")) {
    all_vars
  } else {
    all_vars[all_vars$variable_name %in% fields, , drop = FALSE]
  }
  
  var_bytes <- stats::setNames(
    vapply(seq_len(nrow(req_vars)),
           function(i) as.numeric(n_cells) * .bytes(req_vars$data_type[i]),
           numeric(1L)),
    req_vars$variable_name)
  
  total_bytes <- sum(var_bytes)
  
  # ── verbose output ────────────────────────────────────────────────────────
  if (verbose) {
    dsid <- attr(info, "datasetid") %||% "(unknown)"
    sep  <- paste(rep("-", 65), collapse = "")
    cat("=== griddap request size estimate ===\n")
    cat("  Dataset  :", dsid, "\n")
    cat("  All dims :", paste(dim_vars, collapse = ", "), "\n\n")
    
    if (length(unconstrained))
      cat("  NOTE: unconstrained dim(s) not included in estimate:",
          paste(unconstrained, collapse = ", "), "\n\n")
    
    cat(sprintf("  %-20s  %10s  %10s  %s\n",
                "Dimension", "n_pts", "strided", "spacing / source"))
    cat(sep, "\n")
    for (vname in dim_vars) {
      n   <- dim_npts[[vname]]
      ns  <- dim_npts_strided[[vname]]
      sp  <- dim_spacing[[vname]]
      sp_str <- if (is.na(sp$value)) {
        paste0("unknown  [", sp$source, "]")
      } else if (.is_time_dim(vname)) {
        paste0(sp$value, " s  [", sp$source, "]")
      } else {
        paste0(sp$value, "  [", sp$source, "]")
      }
      cat(sprintf("  %-20s  %10s  %10s  %s\n",
                  vname,
                  if (is.na(n))  "(full)" else format(n,  big.mark = ","),
                  if (is.na(ns)) "(full)" else format(ns, big.mark = ","),
                  sp_str))
    }
    cat(sep, "\n")
    cat(sprintf("  Total cells (constrained) : %s\n\n",
                format(n_cells, big.mark = ",")))
    
    cat(sprintf("  %-30s  %-10s  %s\n", "Variable", "dtype", "size"))
    for (nm in names(var_bytes)) {
      dtype <- req_vars$data_type[req_vars$variable_name == nm]
      cat(sprintf("  %-30s  %-10s  %s\n", nm, dtype, .fmt(var_bytes[nm])))
    }
    cat(sep, "\n")
    cat(sprintf("  Estimated size (NetCDF3, no compression) : %s\n",
                .fmt(total_bytes)))
  }
  
  invisible(list(
    dim_vars         = dim_vars,
    constrained      = constrained,
    unconstrained    = unconstrained,
    dim_npts         = dim_npts,
    dim_npts_strided = dim_npts_strided,
    dim_spacing      = dim_spacing,
    n_cells          = n_cells,
    var_bytes        = var_bytes,
    total_bytes      = total_bytes,
    total_fmt        = .fmt(total_bytes)
  ))
}
