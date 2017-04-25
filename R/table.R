#' Get ERDDAP tabledap data.
#'
#' @export
#'
#' @param x Anything coercable to an object of class info. So the output of
#' a call to \code{\link{info}}, or a datasetid, which will internally be passed
#' through \code{\link{info}}
#' @param ... Any number of key-value pairs in quotes as query constraints.
#' See Details & examples
#' @param fields Columns to return, as a character vector
#' @param distinct If TRUE ERDDAP will sort all of the rows in the results
#' table (starting with the first requested variable, then using the second
#' requested variable if the first variable has a tie, ...), then remove all
#' non-unique rows of data. In many situations, ERDDAP can return distinct
#' values quickly and efficiently. But in some cases, ERDDAP must look through
#' all rows of the source dataset.
#' @param orderby If used, ERDDAP will sort all of the rows in the results
#' table (starting with the first variable, then using the second variable
#' if the first variable has a tie, ...). Normally, the rows of data in the
#' response table are in the order they arrived from the data source. orderBy
#' allows you to request that the results table be sorted in a specific way.
#' For example, use \code{orderby=c("stationID,time")} to get the results
#' sorted by stationID, then time. The orderby variables MUST be included in
#' the list of requested variables in the fields parameter.
#' @param orderbymax Give a vector of one or more fields, that must be included
#' in the fields parameter as well. Gives back data given constraints. ERDDAP
#' will sort all of the rows in the results table (starting with the first
#' variable, then using the second variable if the first variable has a
#' tie, ...) and then just keeps the rows where the value of the last sort
#' variable is highest (for each combination of other values).
#' @param orderbymin Same as \code{orderbymax} parameter, except returns
#' minimum value.
#' @param orderbyminmax Same as \code{orderbymax} parameter, except returns
#' two rows for every combination of the n-1 variables: one row with the
#' minimum value, and one row with the maximum value.
#' @param units One of 'udunits' (units will be described via the UDUNITS
#' standard (e.g.,degrees_C)) or 'ucum' (units will be described via the
#' UCUM standard (e.g., Cel)).
#' @param url A URL for an ERDDAP server.
#' Default: \url{https://upwell.pfeg.noaa.gov/erddap/}
#' @param store One of \code{disk} (default) or \code{memory}. You can pass
#' options to \code{disk}
#' @param callopts Further args passed on to httr::GET (must be a
#' named parameter)
#'
#' @return An object of class \code{tabledap}. This class is a thin wrapper
#' around a data.frame, so the data you get back is a data.frame with metadata
#' attached as attributes (datasetid, path (path where the csv is stored on
#' your machine), url (url for the request))
#'
#' @details
#' For key-value pair query constraints, the valid operators are =,
#' != (not equals), =~ (a regular expression test), <, <=, >, and >= . For
#' regular expressions you need to add a regular expression. For others, nothing
#' more is needed. Construct the entry like \code{'time>=2001-07-07'} with the
#' parameter on the left, value on the right, and the operator in the middle,
#' all within a set of quotes. Since ERDDAP accepts values other than \code{=},
#' we can't simply do \code{time = '2001-07-07'} as we normally would.
#'
#' Server-side functionality: Some tasks are done server side. You don't have
#' to worry about what that means. They are provided via parameters in this
#' function. See \code{distinct}, \code{orderby}, \code{orderbymax},
#' \code{orderbymin}, \code{orderbyminmax}, and \code{units}.
#'
#' Data is cached based on all parameters you use to get a dataset, including
#' base url, query parameters. If you make the same exact call in the same or
#' a different R session, as long you don't clear the cache, the function only
#' reads data from disk, and does not have to request the data from the web
#' again.
#'
#' If you run into an error like "HTTP Status 500 - There was a (temporary?)
#' problem. Wait a minute, then try again.". it's likely they are hitting
#' up against a size limit, and they should reduce the amount of data they
#' are requesting either via space, time, or variables. Pass in
#' \code{config = verbose()} to the request, and paste the URL into your
#' browser to see if the output is garbled to examine if there's a problem
#' with servers or this package
#'
#' @references  \url{https://upwell.pfeg.noaa.gov/erddap/index.html}
#' @author Scott Chamberlain <myrmecocystus@@gmail.com>
#' @examples \dontrun{
#' # Just passing the datasetid without fields gives all columns back
#' tabledap('erdCinpKfmBT')
#'
#' # Pass time constraints
#' tabledap('erdCinpKfmBT', 'time>=2007-06-24', 'time<=2007-07-01')
#'
#' # Pass in fields (i.e., columns to retrieve) & time constraints
#' tabledap('erdCalCOFIfshsiz',fields=c('longitude','latitude','fish_size',
#'    'itis_tsn'), 'time>=2001-07-07','time<=2001-07-10')
#' res <- tabledap('erdCinpKfmBT', fields=c('latitude','longitude',
#'    'Aplysia_californica_Mean_Density','Muricea_californica_Mean_Density'),
#'    'time>=2007-06-24','time<=2007-07-01')
#'
#' # Get info on a datasetid, then get data given information learned
#' info('erdCalCOFIlrvsiz')$variables
#' tabledap('erdCalCOFIlrvsiz', fields=c('latitude','longitude','larvae_size',
#'    'itis_tsn'), 'time>=2011-10-25', 'time<=2011-10-31')
#'
#' # An example workflow
#' ## Search for data
#' (out <- ed_search(query='fish', which = 'table'))
#' ## Using a datasetid, search for information on a datasetid
#' id <- "hawaii_43a8_6d6d_9052"
#' info(id)$variables
#' ## Get data from the dataset
#' tabledap(id, fields = c('scientificName', 'tsn', 'sex'))
#'
#' # Time constraint
#' ## Limit by time with date only
#' (info <- info('erdCalCOFIfshsiz'))
#' tabledap(info, fields = c('latitude','longitude','scientific_name'),
#'    'time>=2001-07-14')
#'
#' # Use distinct parameter
#' tabledap('erdCalCOFIfshsiz',
#'    fields=c('longitude','latitude','fish_size','itis_tsn'),
#'    'time>=2001-07-07','time<=2001-07-10', distinct=TRUE)
#'
#' # Use units parameter
#' ## In this example, values are the same, but sometimes they can be different
#' ## given the units value passed
#' tabledap('erdCinpKfmT', fields=c('longitude','latitude','time','temperature'),
#'    'time>=2007-09-19', 'time<=2007-09-21', units='udunits')
#' tabledap('erdCinpKfmT', fields=c('longitude','latitude','time','temperature'),
#'    'time>=2007-09-19', 'time<=2007-09-21', units='ucum')
#'
#' # Use orderby parameter
#' tabledap('erdCinpKfmT', fields=c('longitude','latitude','time','temperature'),
#'    'time>=2007-09-19', 'time<=2007-09-21', orderby='temperature')
#' # Use orderbymax parameter
#' tabledap('erdCinpKfmT', fields=c('longitude','latitude','time','temperature'),
#'    'time>=2007-09-19', 'time<=2007-09-21', orderbymax='temperature')
#' # Use orderbymin parameter
#' tabledap('erdCinpKfmT', fields=c('longitude','latitude','time','temperature'),
#'    'time>=2007-09-19', 'time<=2007-09-21', orderbymin='temperature')
#' # Use orderbyminmax parameter
#' tabledap('erdCinpKfmT', fields=c('longitude','latitude','time','temperature'),
#'    'time>=2007-09-19', 'time<=2007-09-21', orderbyminmax='temperature')
#' # Use orderbymin parameter with multiple values
#' tabledap('erdCinpKfmT',
#'    fields=c('longitude','latitude','time','depth','temperature'),
#'    'time>=2007-06-10', 'time<=2007-09-21',
#'    orderbymax=c('depth','temperature')
#' )
#'
#' # Spatial delimitation
#' tabledap('erdCalCOFIfshsiz',
#'   fields = c('latitude','longitude','scientific_name'),
#'  'latitude>=34.8', 'latitude<=35', 'longitude>=-125', 'longitude<=-124')
#'
#' # Integrate with taxize
#' out <- tabledap('erdCalCOFIfshsiz',
#'    fields = c('latitude','longitude','scientific_name','itis_tsn'))
#' tsns <- unique(out$itis_tsn[1:100])
#' library("taxize")
#' classif <- classification(tsns, db = "itis")
#' head(rbind(classif)); tail(rbind(classif))
#'
#' # Write to memory (within R), or to disk
#' (out <- info('erdCalCOFIfshsiz'))
#' ## disk, by default (to prevent bogging down system w/ large datasets)
#' ## the 2nd call is much faster as it's mostly just the time of reading
#' ## in the table from disk
#' system.time( tabledap('erdCalCOFIfshsiz', store = disk()) )
#' system.time( tabledap('erdCalCOFIfshsiz', store = disk()) )
#' ## memory
#' tabledap(x='erdCalCOFIfshsiz', store = memory())
#'
#' # use a different ERDDAP server
#' ## NOAA IOOS NERACOOS
#' url <- "http://www.neracoos.org/erddap/"
#' tabledap("E01_optics_hist", url = url)
#' }

tabledap <- function(x, ..., fields=NULL, distinct=FALSE, orderby=NULL,
  orderbymax=NULL, orderbymin=NULL, orderbyminmax=NULL, units=NULL,
  url = eurl(), store = disk(), callopts=list()) {

  x <- as.info(x, url)
  fields <- paste(fields, collapse = ",")
  url <- sprintf(paste0(url, "tabledap/%s.csv?%s"), attr(x, "datasetid"),
                 fields)
  args <- list(...)
  distinct <- if (distinct) 'distinct()' else NULL
  units <- if (!is.null(units)) {
    makevar(toupper(units), 'units("%s")')
  } else {
    units
  }
  orderby <- makevar(orderby, 'orderBy("%s")')
  orderbymax <- makevar(orderbymax, 'orderByMax("%s")')
  orderbymin <- makevar(orderbymin, 'orderByMin("%s")')
  orderbyminmax <- makevar(orderbyminmax, 'orderByMinMax("%s")')
  moreargs <- rc(list(distinct, orderby, orderbymax, orderbymin,
                      orderbyminmax, units))
  args <- c(args, moreargs)
  args <- lapply(args, URLencode, reserved = TRUE)
  args <- paste0(args, collapse = "&")
  if (!nchar(args[[1]]) == 0) {
    url <- paste0(url, '&', args)
  }
  resp <- erd_tab_GET(url, dset = attr(x, "datasetid"), store, callopts)
  loc <- if (store$store == "disk") resp else "memory"
  structure(
    read_table(resp),
    class = c("tabledap", "data.frame"),
    datasetid = attr(x, "datasetid"),
    path = loc,
    url = url
  )
}

#' @export
print.tabledap <- function(x, ...) {
  finfo <- file_info(attr(x, "path"))
  cat(sprintf("<ERDDAP tabledap> %s", attr(x, "datasetid")), sep = "\n")
  path <- attr(x, "path")
  path2 <- if (file.exists(path)) path else "<beware: file deleted>"
  cat(sprintf("   Path: [%s]", path2), sep = "\n")
  if (attr(x, "path") != "memory") {
    cat(sprintf("   Last updated: [%s]", finfo$mtime), sep = "\n")
    cat(sprintf("   File size:    [%s mb]", finfo$size), sep = "\n")
  }
  print(tibble::as_data_frame(x))
}

erd_tab_GET <- function(url, dset, store, ...) {
  if (store$store == "disk") {
    # store on disk
    key <- gen_key(url, NULL, "csv")
    if ( file.exists(file.path(store$path, key)) ) {
      file.path(store$path, key)
    } else {
      dir.create(store$path, showWarnings = FALSE, recursive = TRUE)
      res <- GET(url, write_disk(file.path(store$path, key), store$overwrite),
                 ...)
      err_handle(res, store, key)
      res$request$output$path
    }
  } else {
    res <- GET(url, ...)
    err_handle(res, store, key)
    res
  }
}

makevar <- function(x, y){
  if (!is.null(x)) {
    x <- paste0(x, collapse = ",")
    sprintf(y, x)
  } else {
    NULL
  }
}
