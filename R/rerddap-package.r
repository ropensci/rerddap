#' General purpose R client for ERDDAP servers
#'
#' @section ERDDAP info:
#' NOAA's ERDDAP service holds many datasets of interest. It's built on top of
#' OPenDAP <http://www.opendap.org/>. You can search for datasets via
#' [ed_search()], list datasets via [ed_datasets()],
#' get information on a single dataset via [info()], then get
#' data you want for either tabledap type via [tabledap()], or
#' for griddap type via [griddap()]
#'
#' @section tabledap/griddap:
#' tabledap and griddap have different interfaces to query for data, so
#' [tabledap()] and [griddap()] are separated out as
#' separate functions even though some of the internals are the same. In
#' particular, with tabledap you can query on/subset all variables, whereas
#' with gridddap, you can only query on/subset the dimension varibles (e.g.,
#' latitude, longitude, altitude).
#'
#' @section NOTE:
#' With griddap data via [griddap()] you can get a lot of
#' data quickly. Try small searches of a dataset to start to get a sense for
#' the data, then you can increase the amount of data you get. See
#' [griddap()] for more details.
#'
#' @importFrom utils head read.csv read.delim URLencode
#' @importFrom crul HttpClient
#' @importFrom jsonlite fromJSON
#' @importFrom data.table rbindlist
#' @importFrom ncdf4 nc_open nc_close ncvar_get
#' @importFrom xml2 xml_text xml_find_all read_html xml_find_first
#' @importFrom dplyr as_data_frame bind_rows
#' @importFrom digest digest
#' @importFrom hoardr hoard
#' @name rerddap-package
#' @aliases rerddap
#' @docType package
#' @author Scott Chamberlain \email{myrmecocystus@@gmail.com}
#' @keywords package
NULL

#' institutions
#'
#' @docType data
#' @keywords datasets
#' @format A character vector
#' @name institutions
NULL

#' ioos_categories
#'
#' @docType data
#' @keywords datasets
#' @format A character vector
#' @name ioos_categories
NULL

#' keywords
#'
#' @docType data
#' @keywords datasets
#' @format A character vector
#' @name keywords
NULL

#' longnames
#'
#' @docType data
#' @keywords datasets
#' @format A character vector
#' @name longnames
NULL

#' standardnames
#'
#' @docType data
#' @keywords datasets
#' @format A character vector
#' @name standardnames
NULL

#' variablenames
#'
#' @docType data
#' @keywords datasets
#' @format A character vector
#' @name variablenames
NULL
