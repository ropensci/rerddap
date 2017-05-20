#' Visualize rerddap data
#'
#' Visualize data returned from rerddap servers. Use \code{plotdap()} to initialize
#' a plot, specify the plotting method (specifically, 'base' or 'ggplot2'),
#' and set some global options/parameters. Then use \code{add_tabledap()}
#' and/or \code{add_griddap()} to add "layers" of actual data to be visualized.
#'
#' @details The "ggplot2" method is slower than "base" (especially
#' for high-res grids/rasters), but is more flexible/extensible. Additional ggplot2
#' layers, as well as scale defaults, labels, theming, etc. may be modified via
#' the \code{add_ggplot()} function. See the mapping vignette for an introduction
#' and overview of rerrdap's visualization methods --
#' \code{browseVignettes(package = "rerddap")}.
#'
#' @param method the plotting method. Currently ggplot2 and base plotting
#' are supported.
#' @param mapData an object coercable to an sf object via \code{st_as_sf()}.
#' @param crs a coordinate reference system: integer with the epsg code,
#' or character with proj4string.
#' @param datum crs that provides datum to use when generating graticules.
#' Set to \code{NULL} to hide the graticule.
#' @param mapTitle a title for the map.
#' @param mapFill fill used for the map.
#' @param mapColor color used to draw boundaries of the map.
#' @param ... for \code{plotdap()}/\code{add_tabledap()}/\code{add_griddap()},
#' arguments passed along to \code{geom_sf()} (if \code{method='ggplot2'},
#' otherwise ignored). For \code{add_ggplot2()}, these arguments may be
#' any object of class "gg" (e.g, \code{theme()}, \code{scale_fill_gradientn()},
#' \code{geom_point()}, etc.)
#' @export
#' @seealso \code{\link{tabledap}()}, \code{\link{griddap}()}
#' @author Carson Sievert
#' @examples
#'
#' plotdap()
#' plotdap("base")
#'
#' \dontrun{
#' # tabledap examples
#' sardines <- tabledap(
#'   'FRDCPSTrawlLHHaulCatch',
#'   fields = c('latitude',  'longitude', 'time', 'scientific_name', 'subsample_count'),
#'   'time>=2010-01-01', 'time<=2012-01-01', 'scientific_name="Sardinops sagax"'
#'  )
#'
#' p <- plotdap()
#' add_tabledap(p, sardines, ~subsample_count)
#' add_tabledap(p, sardines, ~log(subsample_count))
#'
#' # using base R plotting
#' p <- plotdap("base")
#' add_tabledap(p, sardines, ~subsample_count)
#'
#' # robinson projection
#' p <- plotdap(crs = "+proj=robin")
#' add_tabledap(p, sardines, ~subsample_count)
#'
#' # griddap examples
#' murSST <- griddap(
#'   'jplMURSST41', latitude = c(22, 51), longitude = c(-140, -105),
#'   time = c('last', 'last'), fields = 'analysed_sst'
#'  )
#' p <- plotdap(crs = "+proj=robin")
#' add_griddap(p, murSST, ~analysed_sst)
#'
#' # layer tables on top of grids
#' plotdap("base") %>%
#'   add_griddap(murSST, ~sst) %>%
#'   add_tabledap(sardines, ~subsample_count)
#'
#' # multiple time periods
#' wind <- griddap(
#'   'erdQMwindmday', time = c('2016-11-16', '2017-01-16'),
#'   latitude = c(30, 50), longitude = c(210, 240),
#'   fields = 'x_wind'
#' )
#' p <- plotdap("base", mapTitle = "Average wind over time")
#' add_griddap(p, wind, ~x_wind)
#'
#'}

plotdap <- function(method = c("ggplot2", "base"),
                    mapData = maps::map('world', plot = FALSE, fill = TRUE),
                    crs = NULL, datum = sf::st_crs(4326),
                    mapTitle = NULL, mapFill = "gray80", mapColor = "gray90",
                    ...) {

  method <- match.arg(method, method)

  # packages used in both methods
  require_packages(c("sf", "maps", "lazyeval"))

  # maps is bad at namespacing
  try_require("mapdata", "plotdap")
  bgMap <- sf::st_as_sf(mapData)

  # transform background map to target projection
  if (!is.null(crs)) {
    bgMap <- sf::st_transform(bgMap, crs)
  }

  if (identical(method, "ggplot2")) {
    p <- ggplot() +
      geom_sf(data = bgMap, fill = mapFill, color = mapColor, ...) +
      theme_bw() + ggtitle(mapTitle)
    # keep track of some "global" properties...
    # this seems to be the only way to do things like train axis ranges
    # without a ggplot_build() hack...
    p2 <- list(
      ggplot = p,
      crs = sf::st_crs(bgMap),
      datum = datum
    )
    return(structure(p2, class = c("ggplotdap", class(p))))
  }

  # construct an custom object for base plotting...
  # we might do all the plotting in the print step since we won't know the
  # final x/y limits until then
  dap <- list(
    crs = sf::st_crs(bgMap),
    datum = datum,
    mapTitle = mapTitle,
    mapColor = mapColor,
    mapFill = mapFill,
    layers = list(bgMap)
  )
  structure(dap, class = "plotdap")
}


#' @param plot a \link{plotdap} object.
#' @param table a \link{tabledap} object.
#' @param var a formula defining a variable, or function of variables to visualize.
#' @param color a character string of length 1 a name in \link{colors}
#' or a vector of color codes. This defines the colorscale used to encode values
#' of \code{var}.
#' @param size the size of the symbol.
#' @param shape the shape of the symbol. For valid options, see the 'pch' values
#' section on \link{points}. \code{plot(0:25, 0:25, pch = 0:25)} also gives a
#' quick visual of the majority of possibilities.
#' @param animate whether to animate over the \code{time} variable (if it exists).
#' Currently only implemented for \code{method='ggplot2'} and requires the
#' gganimate package.
#' @param ani.args arguments passed along to \code{gganimate()}.
#' @export
#' @rdname plotdap

add_tabledap <- function(plot, table, var, color = c("#132B43", "#56B1F7"),
                         size = 1.5, shape = 19, animate = FALSE,
                         ani.args = list(filename = "ani.gif"), ...) {
  if (!is.table(table))
    stop("The `table` argument must be a `tabledap()` object", call. = FALSE)
  if (!lazyeval::is_formula(var))
    stop("The var argument must be a formula", call. = FALSE)

  # checks for naming and numeric lat/lon
  latlon_is_valid(table)
  # adjust to ensure everthing is on standard lat/lon scale
  table <- latlon_adjust(table)

  nms <- names(table)
  # convert to sf
  table <- sf::st_as_sf(
    table, crs = sf::st_crs(4326),
    coords = c(grep(lonPattern(), nms), grep(latPattern(), nms))
  )
  # transform to target projection
  if (inherits(plot$crs, "crs")) {
    table <- sf::st_transform(table, plot$crs)
  }

  # color scale
  cols <- if (length(color) == 1) colors[[color]] else color

  if (is_ggplotdap(plot)) {

    mapping <- if (animate && "time" %in% names(table) && has_gganimate()) {
      plot$animate <- TRUE
      plot$ani.args <- ani.args
      aes_(colour = var, frame = ~time)
    } else {
      aes_(colour = var)
    }

    return(
      add_ggplot(
        plot,
        geom_sf(data = table, mapping = mapping, size = size, pch = shape, ...),
        scale_color_gradientn(name = lazyeval::f_text(var), colours = cols)
      )
    )
  }


  if (animate) {
    warning(
      "Animations are currently only implemented for `method='ggplot2'`",
      call. = FALSE
    )
  }

  table <- structure(
    table, props = list(
      name = lazyeval::f_text(var),
      values = lazyeval::f_eval(var, table),
      color = cols,
      size = size,
      shape = shape
    )
  )

  plot$layers <- c(
    plot$layers, list(table)
  )

  plot
}


#' @inheritParams add_tabledap
#' @param grid a \link{griddap} object.
#' @param maxpixels integer > 0. Maximum number of cells to use for the plot.
#' If maxpixels < ncell(x), sampleRegular is used before plotting.
#' If gridded=TRUE maxpixels may be ignored to get a larger sample
#' @param time how to resolve multiple time frames. Choose one of the following:
#' \itemize{
#'   \item A function to apply to each observation at a particular location
#'   (\link{mean} is the default).
#'   \item A character string (of length 1) matching a time value.
#' }
#' @param animate whether to animate over the \code{time} variable (if it exists).
#' Currently only implemented for \code{method='ggplot2'} and requires the
#' gganimate package.
#' @param ani.args arguments passed along to \code{gganimate()}.
#' @export
#' @rdname plotdap

add_griddap <- function(plot, grid, var, fill = "viridis",
                        maxpixels = 10000, time = mean, animate = FALSE,
                        ani.args = list(filename = "ani.gif"), ...) {
  if (!is.grid(grid))
    stop("The `grid` argument must be a `griddap()` object", call. = FALSE)
  if (!lazyeval::is_formula(var))
    stop("The `var`` argument must be a formula", call. = FALSE)
  if (!is.function(time) && !is.character(time))
    stop("The `time` argument must be a function or a character string", call. = FALSE)

  # create raster object from filename; otherwise create a sensible raster from data
  r <- get_raster(grid, var)

  # checks for naming and numeric lat/lon
  latlon_is_valid(r)
  # adjust to ensure everthing is on standard lat/lon scale
  r <- latlon_adjust(r)

  # if necessary, reduce a RasterBrick to a RasterLayer
  # http://gis.stackexchange.com/questions/82390/summarize-values-from-a-raster-brick-by-latitude-bands-in-r
  if (raster::nlayers(r) > 1) {
    if (is.function(time)) {
      r <- raster::calc(r, time)
    } else {
      nm <- make.names(time)
      if (!nm %in% names(r)) {
        warning(
          "The `time` argument doesn't match any of time values.\n",
          sprintf(
            "Valid options include: '%s'",
            paste(unique(grid$data$time), collapse = "', '")
          ),
          call. = FALSE
        )
      }
      r <- r[[nm]]
    }

    if (raster::nlayers(r) > 1 && !animate) {
      stop(
        "The `time` argument hasn't reduced the raster down to a single layer.\n",
        "Either set `animate=TRUE` or provide a suitable value to `time`.",
        call. = FALSE
      )
    }
  }

  # simplify raster, if necessary
  n <- raster::ncell(r)
  if (n > maxpixels) {
    message("grid object contains more than ", maxpixels, " pixels")
    message("increase `maxpixels` for a finer resolution")
    rnew <- raster::raster(
      nrow = floor(raster::nrow(r) * sqrt(maxpixels / n)),
      ncol = floor(raster::ncol(r) * sqrt(maxpixels / n)),
      crs = raster::crs(r),
      ext = raster::extent(r)
    )
    if (inherits(r, "RasterBrick")) {
      for (i in seq_len(raster::nlayers(r))) {
        r[[i]] <- raster::resample(r[[i]], rnew, method = 'bilinear')
      }
    } else {
      r <- raster::resample(r, rnew, method = 'bilinear')
    }
  }

  # assumes we apply sf::st_crs() to plot on initiation
  if (inherits(plot$crs, "crs")) {
    r <- raster::projectRaster(r, crs = plot$crs$proj4string)
  }

  # color scale
  cols <- if (length(fill) == 1) colors[[fill]] else fill

  if (is_ggplotdap(plot)) {
    # TODO: not the most efficient approach, but it will have to do for now
    # https://twitter.com/hadleywickham/status/841763265344487424
    s <- sf::st_as_sf(raster::rasterToPolygons(r))
    vars <- setdiff(names(s), "geometry")
    sg <- sf::st_as_sf(tidyr::gather_(s, "variable", "value", vars))
    mapping <- if (animate && has_gganimate()) {
      plot$animate <- TRUE
      plot$ani.args <- ani.args
      aes_string(fill = "value", frame = "variable")
    } else {
      aes_string(fill = "value")
    }
    return(
      add_ggplot(
        plot,
        geom_sf(data = sg, mapping = mapping, size = 0, ...),
        scale_fill_gradientn(name = lazyeval::f_text(var), colors = cols)
      )
    )
  }

  if (animate) {
    warning(
      "Animations are currently only implemented for `method='ggplot2'`",
      call. = FALSE
    )
  }

  # TODO: more props!
  grid <- structure(
    r, props = list(
      name = lazyeval::f_text(var),
      values = raster::values(r),
      color = cols
    )
  )

  # Throw a warning if the grid extent overlaps with another grid?
  plot$layers <- c(
    plot$layers, list(grid)
  )

  plot
}


#' Add ggplot2 elements to a plotdap object
#'
#' @param plot a plotdap object
#' @param ... ggplot2 elements
#' @export
#' @rdname plotdap
#' @examples
#'
#' add_ggplot(
#'  plotdap(
#'    crs = "+proj=laea +y_0=0 +lon_0=155 +lat_0=-90 +ellps=WGS84 +no_defs",
#'    mapColor = "black"
#'  ),
#'  theme_bw()
#' )
#'
#'
add_ggplot <- function(plot, ...) {
  if (!is_plotdap(plot)) {
    stop(
      "The first argument to `add_ggplot()` must be a `plotdap()` object",
      call. = FALSE
    )
  }
  dots <- list(...)
  for (i in seq_along(dots)) {
    plot$ggplot <- plot$ggplot + dots[[i]]
  }
  plot
}


#' Print a ggplot plotdap object
#'
#' @param plot a ggplotdap object
#' @param ... currently unused
#' @export
print.ggplotdap <- function(plot, ...) {
  # find a sensible x/y range....assuming all the layer data is sf
  gg <- plot$ggplot
  layer_data <- lapply(gg$layers, function(y) y$layer_data(gg$data))
  bbs <- lapply(layer_data[-1], sf::st_bbox)
  xlim <- Reduce(range, lapply(bbs, "[", c("xmin", "xmax")))
  ylim <- Reduce(range, lapply(bbs, "[", c("ymin", "ymax")))
  plot <- add_ggplot(
    plot, coord_sf(
      crs = plot$crs, datum = plot$datum,
      xlim = xlim, ylim = ylim
    )
  )
  if (has_gganimate() && isTRUE(plot$animate)) {
    p <- list(p = plot$ggplot)
    print(do.call(gganimate::gganimate, c(p, plot$ani.args)))
  } else {
    print(plot$ggplot)
  }
  invisible(plot)
}



#' Print a plotdap object
#'
#' @param plot a plotdap object
#' @param ... currently unused
#' @export
print.plotdap <- function(plot, ...) {

  # remember, unlike ggplotdap, plotdap layers can have both sf and raster objs
  bbs <- lapply(plot$layers[-1], get_bbox)
  xlim <- Reduce(range, lapply(bbs, "[", c("xmin", "xmax")))
  ylim <- Reduce(range, lapply(bbs, "[", c("ymin", "ymax")))

  graticule <- sf::st_graticule(
    c(xlim[1], ylim[1], xlim[2], ylim[2]) %||% get_bbox(plot$layers[[1]]),
    crs = plot$crs,
    datum = plot$datum
  )

  # plot the background map
  plot(
    plot$layers[[1]],
    xlim = xlim,
    ylim = ylim,
    main = plot$mapTitle %||% "",
    col = plot$mapFill,
    border = plot$mapColor,
    graticule = graticule,
    #setParUsrBB = TRUE,
    bty = "n",
    ...
  )

  for (i in setdiff(seq_along(plot$layers), 1)) {
    layer <- plot$layers[[i]]
    props <- attr(layer, "props")
    rng <- range(props$values, na.rm = TRUE)
    pal <- scales::col_numeric(props$color, rng)
    breaks <- quantile(props$values, 0:4/4, na.rm = TRUE)

    # plot rasters first, otherwise we have to fiddle with legends
    if (is_raster(layer)) {
      raster::plot(
        layer,
        add = TRUE,
        legend = FALSE,
        frame.plot = FALSE,
        # TODO: where does this scaling occur? In raster::plot()?
        col = props$color,
        ...
      )
      graphics::legend(
        "bottomright",
        title = props$name,
        legend = format(breaks),
        col = pal(breaks),
        pch = 20
      )
    } else {
      # should be sf POINTS
      plot(
        layer[["geometry"]],
        add = TRUE,
        col = pal(props$values),
        pch = props$shape,
        cex = props$size
      )
      graphics::legend(
        "topright",
        title = props$name,
        legend = format(breaks),
        col = pal(breaks),
        pch = 20
      )
    }
  }
  plot
}


# ------------------------------------------------------------------------
# Internal helper functions
# ------------------------------------------------------------------------

is_plotdap <- function(x) {
  inherits(x, c("ggplotdap", "plotdap"))
}

is_ggplotdap <- function(x) {
  is_plotdap(x) && ggplot2::is.ggplot(x$ggplot)
}

is_raster <- function(x) {
  inherits(x, c("RasterLayer", "RasterBrick", "RasterStack"))
}

get_bbox <- function(x) {
  if (inherits(x, "sf")) {
    return(sf::st_bbox(x))
  }
  # TODO: support raster objects, as well?
  if (inherits(x, "RasterLayer")) {
    ext <- as.list(raster::extent(x))
    return(setNames(ext, c("xmin", "xmax", "ymin", "ymax")))
  }
  invisible()
}

get_raster <- function(grid, var) {
  times <- grid$summary$dim$time$vals
  lats <- grid$summary$dim$latitude$vals
  lons <- grid$summary$dim$longitude$vals
  ylim <- range(lats, na.rm = TRUE)
  xlim <- range(lons, na.rm = TRUE)
  ext <- raster::extent(xlim[1], xlim[2], ylim[1], ylim[2])
  r <- if (length(times) > 1) {
    # ensure values appear in the right order...
    # TODO: how to detect a south -> north ordering?
    d <- dplyr::arrange(grid$data, time, desc(lat), lon)
    b <- raster::brick(
      nl = length(times),
      nrows = length(lats),
      ncols = length(lons)
    )
    raster::values(b) <- lazyeval::f_eval(var, d)
    raster::setExtent(b, ext)
  } else {
    d <- dplyr::arrange(grid$data, desc(lat), lon)
    raster::raster(
      nrows = length(lats),
      ncols = length(lons),
      ext = ext,
      vals = lazyeval::f_eval(var, d)
    )
  }
  names(r) <- make.names(unique(grid$data$time) %||% "")
  r
}

latlon_is_valid <- function(x) {
  if (is_raster(x)) {
    if (!raster::isLonLat(x)) {
      stop(
        "raster object must have a longitude/latitude coordinate reference system (CRS)",
        call. = FALSE
      )
    }
    return(TRUE)
  }

  if (!is.numeric(latValues(x))) {
    stop("Latitudes must be numeric", call. = FALSE)
  }

  if (!is.numeric(lonValues(x))) {
    stop("Longitudes must be numeric", call. = FALSE)
  }

  invisible(TRUE)
}

latlon_adjust <- function(x) {
  # -------------------------------------------------------------------------
  # The following comments are based on a correspondence with Roy Mendelssohn:
  # -------------------------------------------------------------------------

  # We can always assume (-90 < latitude < 90),
  # but ordering may go (north -> south) rather than (south -> north)...
  # does this even really matter?

  # Longitudes can either be (0, 360) or (-180, 180)...
  # put them all on (-180, 180)
  if (is.table(x)) {

    lonIDX <- grep(lonPattern(), names(x))
    lon <- range(x[[lonIDX]], na.rm = TRUE)

    if (all(dplyr::between(lon, 0, 180))) {

      warning(
        "Can't determine whether longitude is on (0, 360) or (-180, 180) scale\n",
        "Defaulting to (-180, 180) scale...",
        call. = FALSE
      )

    } else if (all(dplyr::between(lon, 0, 360))) {

      idx <- isTRUE(lon > 180)
      x[[lonIDX]][idx] <- lon[idx] - 360

    } else if (all(dplyr::between(lon, -180, 180))) {

      # nothing to do....

    } else {

      # TODO: report the invalid values?
      warning("Invalid longitude values", call. = TRUE)

    }

    return(x)
  }

  if (is_raster(x)) {

    ext <- raster::extent(x)
    lon <- c(ext@xmin, ext@xmax)

    if (all(dplyr::between(lon, 0, 180))) {

      warning(
        "Can't determine whether longitude is on (0, 360) or (-180, 180) scale\n",
        "Defaulting to (-180, 180) scale...",
        call. = FALSE
      )

    } else if (all(dplyr::between(lon, 0, 360))) {

      newExt <- raster::extent(
        c(c(ext@xmin, ext@xmax) - 360, ext@ymin, ext@ymax)
      )
      x <- raster::setExtent(x, newExt, keepres = TRUE)

    } else if (all(dplyr::between(lon, -180, 180))) {

      # nothing to do....

    } else {

      # TODO: report the invalid values?
      warning("Invalid longitude values", call. = TRUE)

    }

    return(x)
  }

  # throw an error?
  x
}


latValues <- function(x) {
  latIDX <- grep(latPattern(), names(x))
  if (length(latIDX) != 1) {
    stop(
      "Couldn't find latitude variable. Must be named one of the following:\n",
      "'lat', 'lats', 'latitude'",
      call. = FALSE
    )
  }
  x[[latIDX]]
}

lonValues <- function(x) {
  lonIDX <- grep(lonPattern(), names(x))
  if (length(lonIDX) != 1) {
    stop(
      "Couldn't find longitude variable. Must be named one of the following:\n",
      "'lon', 'lons', 'longitude'",
      call. = FALSE
    )
  }
  if (!is.numeric(x[[lonIDX]])) {
    stop("Longitude must be numeric", call. = FALSE)
  }
  x[[lonIDX]]
}

latPattern <- function() "^lat$|^lats$|^latitude$"
lonPattern <- function() "^lon$|^lons$|^longitude$"

# ----------------------------------------------------------------------
# Maybe these should go in R/utils.R ??
# ----------------------------------------------------------------------


"%||%" <- function(x, y) {
  if (length(x) > 0) x else y
}

is.grid <- function(x) {
  inherits(x, c("griddap_nc", "griddap_csv"))
}

is.table <- function(x) {
  inherits(x, "tabledap")
}

require_packages <- function(x) {
  for (i in x) {
    if (system.file(package = i) == "") {
      stop(sprintf("Please install package: '%s'", i), call. = FALSE)
    }
  }
  invisible(TRUE)
}

# copied from ggplot2:::try_require...thanks Hadley
try_require <- function(package, fun) {
  if (requireNamespace(package, quietly = TRUE)) {
    library(package, character.only = TRUE)
    return(invisible())
  }
  stop("Package `", package, "` required for `", fun, "`.\n",
       "Please install and try again.", call. = FALSE)
}

has_gganimate <- function() {
  if (system.file(package = "gganimate") != "") {
    if (packageVersion("gganimate") > "0.1") {
      return(TRUE)
    }
  }
  stop(
    "This functionality requires a recent version of the gganimate package.\n",
    "Please install via devtools:\n",
    "devtools::install_github('dgrtwo/gganimate')",
    call. = FALSE
  )
  FALSE
}


# This is likely WRONG, SAD!
# rescale_lims <- function(x, .info = info(attr(x, "datasetid"))) {
#
#   # lat/lon can be on different ranges (e.g. [-180, 180] vs [0, 360])
#   # put them on the usual [-180, 180]/[-90, 90] scales
#   for (i in c("latitude", "longitude")) {
#     default <- if (i == "latitude") c(-90, 90) else c(-180, 180)
#     domain <- tryCatch({
#       d <- .info$alldata[[i]]
#       rng <- d[d$attribute_name == "actual_range", "value"]
#       as.numeric(strtrim(strsplit(rng, ",")[[1]]))
#     }, error = function(e) default)
#
#     if (is.table(x)) {
#       x[[i]] <- scales::rescale(x[[i]], default, domain)
#     } else {
#       # griddap
#       x$summary$dim[[i]]$vals <- scales::rescale(
#         x$summary$dim[[i]]$vals, default, domain
#       )
#       # assumes latitude/longitude are abbreviated to lat/lon in the data frame (I think that is safe?)
#       abbr <- substr(i, 1, 3)
#       x$data[, abbr] <- scales::rescale(
#         x$data[, abbr], c(-180, 180), domain
#       )
#     }
#   }
#   x
# }
