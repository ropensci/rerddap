#' @examples \dontrun{
#' # single variable dataset
#' ## You can pass in the outpu of a call to info
#' (out <- info('noaa_esrl_027d_0fb5_5d38'))
#' (res <- griddap(out,
#'  time = c('2012-01-01','2012-06-12'),
#'  latitude = c(21, 18),
#'  longitude = c(-80, -75)
#' ))
#' ## Or, pass in a dataset id
#' (res <- griddap('noaa_esrl_027d_0fb5_5d38',
#'  time = c('2012-01-01','2012-06-12'),
#'  latitude = c(21, 18),
#'  longitude = c(-80, -75)
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
#' (out <- info('noaa_esrl_4965_b6d4_7198'))
#' (res <- griddap(out,
#'  time = c('1990-10-01', '1991-02-01'),
#'  latitude = c(20, 21),
#'  longitude = c(2, 5)
#' ))
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
#' (res <- griddap("hawaii_463b_5b04_35b7",
#'  time = c('2015-01-01','2015-01-03'),
#'  latitude = c(14, 15),
#'  longitude = c(75, 76),
#'  store = memory()
#' ))
#'
#' ## Use ncdf4 package to parse data
#' info("hawaii_463b_5b04_35b7")
#' (res <- griddap("hawaii_463b_5b04_35b7",
#'  time = c('2015-01-01','2015-01-03'),
#'  latitude = c(14, 15),
#'  longitude = c(75, 76)
#' ))
#'
#' # Get data in csv format
#' ## by default, we get netcdf format data
#' (res <- griddap('hawaii_463b_5b04_35b7',
#'  time = c('2015-01-01','2015-01-03'),
#'  latitude = c(14, 15),
#'  longitude = c(75, 76),
#'  fmt = "csv"
#' ))
#'
#' # Use a different ERDDAP server url
#' ## NOAA IOOS PacIOOS
#' url = "http://oos.soest.hawaii.edu/erddap/"
#' out <- info("NOAA_DHW", url = url)
#' (res <- griddap(out,
#'  time = c('2005-11-01','2006-01-01'),
#'  latitude = c(21, 20),
#'  longitude = c(10, 11)
#' ))
#' ## pass directly into griddap()
#' griddap("NOAA_DHW", url = url,
#'  time = c('2005-11-01','2006-01-01'),
#'  latitude = c(21, 20),
#'  longitude = c(10, 11)
#' )
#'
#' # You don't have to pass in all of the dimensions
#' ## They do have to be named!
#' griddap(out, time = c('2005-11-01','2005-11-03'))
#'
#' # Using 'last'
#' ## with time
#' griddap('noaa_esrl_fce0_4aad_340a',
#'  time = c('last-5','last'),
#'  latitude = c(21, 18),
#'  longitude = c(3, 5)
#' )
#' ## with latitude
#' griddap('noaa_esrl_fce0_4aad_340a',
#'   time = c('2008-01-01','2009-01-01'),
#'   latitude = c('last', 'last'),
#'   longitude = c(3, 5)
#' )
#' ## with longitude
#' griddap('noaa_esrl_fce0_4aad_340a',
#'  time = c('2008-01-01','2009-01-01'),
#'  latitude = c(21, 18),
#'  longitude = c('last', 'last')
#' )
#' }
