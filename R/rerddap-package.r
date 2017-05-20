#' General purpose R client for ERDDAP servers
#'
#' @section ERDDAP info:
#' NOAA's ERDDAP service holds many datasets of interest. It's built on top of
#' OPenDAP \url{http://www.opendap.org/}. You can search for datasets via
#' \code{\link{ed_search}}, list datasets via \code{\link{ed_datasets}},
#' get information on a single dataset via \code{\link{info}}, then get
#' data you want for either tabledap type via \code{\link{tabledap}}, or
#' for griddap type via \code{\link{griddap}}.
#'
#' @section tabledap/griddap:
#' tabledap and griddap have different interfaces to query for data, so
#' \code{\link{tabledap}} and \code{\link{griddap}} are separated out as
#' separate functions even though some of the internals are the same. In
#' particular, with tabledap you can query on/subset all variables, whereas
#' with gridddap, you can only query on/subset the dimension varibles (e.g.,
#' latitude, longitude, altitude).
#'
#' @section NOTE:
#' With griddap data via \code{\link{griddap}} you can get a lot of
#' data quickly. Try small searches of a dataset to start to get a sense for
#' the data, then you can increase the amount of data you get. See
#' \code{\link{griddap}} for more details.
#'
#' @importFrom utils head read.csv read.delim URLencode
#' @importFrom httr GET write_disk stop_for_status content
#' @importFrom jsonlite fromJSON
#' @importFrom data.table rbindlist
#' @importFrom ncdf4 nc_open nc_close ncvar_get
#' @importFrom xml2 xml_text xml_find_all read_html
#' @importFrom dplyr as_data_frame bind_rows
#' @importFrom digest digest
#' @importFrom tidyr gather_
#' @importFrom maps map
#' @importFrom scales rescale col_numeric
#' @importFrom lazyeval is_formula f_text f_eval
#' @importFrom sf st_as_sf st_transform st_crs st_bbox st_graticule
#' @importFrom ggplot2 ggplot geom_sf coord_sf theme_bw scale_color_gradientn
#' scale_fill_gradientn ggtitle aes_string aes_
#' @importFrom raster raster nlayers calc ncell nrow ncol crs extent resample
#' projectRaster rasterToPolygons values plot brick setExtent isLonLat
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



#' @importFrom magrittr %>%
#' @export
magrittr::`%>%`
