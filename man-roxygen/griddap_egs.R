#' @examples \dontrun{
#' # single variable dataset
#' ## You can pass in the outpu of a call to info
#' (out <- info('erdVHNchlamday'))
#' ## Or, pass in a dataset id
#' (res <- griddap('erdVHNchlamday',
#'  time = c('2015-04-01','2015-04-10'),
#'  latitude = c(18, 21),
#'  longitude = c(-120, -119)
#' ))
#'
#' # multi-variable dataset
#' (out <- info('erdQMekm14day'))
#' (res <- griddap(out,
#'  time = c('2015-12-28','2016-01-01'),
#'  latitude = c(24, 23),
#'  longitude = c(88, 90)
#' ))
#' (res <- griddap(out, time = c('2015-12-28','2016-01-01'),
#'    latitude = c(24, 23), longitude = c(88, 90), fields = 'mod_current'))
#' (res <- griddap(out, time = c('2015-12-28','2016-01-01'),
#'    latitude = c(24, 23), longitude = c(88, 90), fields = 'mod_current',
#'    stride = c(1,2,1,2)))
#' (res <- griddap(out, time = c('2015-12-28','2016-01-01'),
#'    latitude = c(24, 23), longitude = c(88, 90),
#'    fields = c('mod_current','u_current')))
#'
#'
#' # Write to memory (within R), or to disk
#' (out <- info('erdQSwindmday'))
#' ## disk, by default (to prevent bogging down system w/ large datasets)
#' ## you can also pass in path and overwrite options to disk()
#' (res <- griddap(out,
#'  time = c('2006-07-11','2006-07-20'),
#'  longitude = c(166, 170),
#'  store = disk()
#' ))
#' ## the 2nd call is much faster as it's mostly just the time of reading in
#' ## the table from disk
#' system.time( griddap(out,
#'  time = c('2006-07-11','2006-07-15'),
#'  longitude = c(10, 15),
#'  store = disk()
#' ) )
#' system.time( griddap(out,
#'  time = c('2006-07-11','2006-07-15'),
#'  longitude = c(10, 15),
#'  store = disk()
#' ) )
#'
#' ## memory
#' (res <- griddap("erdMBchla1day",
#'  time = c('2015-01-01','2015-01-03'),
#'  latitude = c(14, 15),
#'  longitude = c(125, 126),
#'  store = memory()
#' ))
#'
#' ## Use ncdf4 package to parse data
#' info("erdMBchla1day")
#' (res <- griddap("erdMBchla1day",
#'  time = c('2015-01-01','2015-01-03'),
#'  latitude = c(14, 15),
#'  longitude = c(125, 126)
#' ))
#'
#' # Get data in csv format
#' ## by default, we get netcdf format data
#' (res <- griddap('erdMBchla1day',
#'  time = c('2015-01-01','2015-01-03'),
#'  latitude = c(14, 15),
#'  longitude = c(125, 126),
#'  fmt = "csv"
#' ))
#'
#' # Use a different ERDDAP server url
#' ## NOAA IOOS PacIOOS
#' url = "http://oos.soest.hawaii.edu/erddap/"
#' out <- info("NOAA_DHW_5km", url = url)
#' (res <- griddap(out,
#'  time = c('2015-11-01','2015-11-03'),
#'  latitude = c(21, 20),
#'  longitude = c(10, 11)
#' ))
#' ## pass directly into griddap()
#' griddap("NOAA_DHW_5km", url = url,
#'  time = c('2015-11-01','2015-11-03'),
#'  latitude = c(21, 20),
#'  longitude = c(10, 11)
#' )
#'
#' # Using 'last'
#' ## with time
#' griddap('erdVHNchlamday',
#'  time = c('last-5','last'),
#'  latitude = c(18, 21),
#'  longitude = c(-120, -119)
#' )
#' ## with latitude
#' griddap('erdVHNchlamday',
#'   time = c('2015-04-01','2015-04-10'),
#'   latitude = c('last', 'last'),
#'   longitude = c(-120, -119)
#' )
#' ## with longitude
#' griddap('erdVHNchlamday',
#'   time = c('2015-04-01','2015-04-10'),
#'   latitude = c(18, 21),
#'   longitude = c('last', 'last')
#' )
#' }
