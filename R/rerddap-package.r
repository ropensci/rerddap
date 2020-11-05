#' @title rerddap
#' @description General purpose R client for ERDDAP servers
#' @section ERDDAP info:
#' NOAA's ERDDAP service holds many datasets of interest. It's built on top of
#' OPenDAP. You can search for datasets via
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
#' @section Data size:
#' With griddap data via [griddap()] you can get a lot of
#' data quickly. Try small searches of a dataset to start to get a sense for
#' the data, then you can increase the amount of data you get. See
#' [griddap()] for more details.
#' 
#' @section Caching:
#' \pkg{rerddap} by default caches the requests you make, so that if you happen to 
#' make the same request again, the data is restored from the cache, rather than 
#' having to go out and retrieve it remotely.  For most applications, this is good, 
#' as it can speed things up when doing a lot of request in a script, and works 
#' because in most cases an ERDDAP request is "idempotent".  This means that the 
#' the request will always return the same thing no matter what requests came 
#' before - it doesn't depend on state. However this is not true if the 
#' script uses either "last" in [griddap()] or "now" in [tabledap()] as these 
#' will return different values as time elapses and data are added to the 
#' datasets.  While it is desirable to have ERDDAP purely idempotent,  the 
#' "last" and "now" constructs are very helpful for people using ERDDAP 
#' in dashboards, webpages, regular input to models and the like, and the 
#' benefits far outweigh the problems.  However, if you are using either "last" 
#' or "now" in an \pkg{rerddap} based script, you want to be very careful to 
#' clear the \pkg{rerddap} cache, otherwise the request will be viewed as the 
#' same,  and the data from the last request, rather than the latest data, 
#' will be returned.
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
#' @importFrom tidync hyper_tibble hyper_dims hyper_vars
#' @name rerddap-package
#' @aliases rerddap
#' @docType package
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
