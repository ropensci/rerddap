#' Advanced search for ERDDAP tabledep or griddap datasets
#'
#' @export
#' @importFrom dplyr as_data_frame rbind_all
#'
#' @param query (character) Search terms
#' @param page (integer) Page number. Default: 1
#' @param page_size (integer) Results per page: Default: 1000
#' @param protocol (character) One of any (default), tabledep or griddap
#' @param cdm_data_type (character) One of grid, other, point, profile, timeseries,
#' timeseriesprofile, trajectory, trajectoryprofile
#' @param institution (character) An institution. See the dataset \code{institutions}.
#' @param ioos_category (character) An ioos category See the dataset \code{ioos_categories}.
#' @param keywords (character) A keywords. See the dataset \code{keywords}.
#' @param long_name (character) A long name. See the dataset \code{longnames}.
#' @param standard_name (character) A standar dname. See the dataset \code{standardnames}.
#' @param variableName (character) A variable name. See the dataset \code{variablenames}.
#' @param maxLat (numeric) Maximum latitude
#' @param minLon (numeric) Minimum longitude
#' @param maxLon (numeric) Maximum longitude
#' @param minLat (numeric) Minimum latitude
#' @param minTime (numeric) Minimum time
#' @param maxTime (numeric) Maximum time
#' @param ... Further args passed on to \code{\link[httr]{GET}} (must be a named parameter)
#' @references  \url{http://upwell.pfeg.noaa.gov/erddap/index.html}
#' @author Scott Chamberlain <myrmecocystus@@gmail.com>
#' @examples \dontrun{
#' ed_search_adv(query = 'temperature')
#' ed_search_adv(query = 'temperature', protocol = "griddap")
#' ed_search_adv(query = 'temperature', protocol = "tabledap")
#' ed_search_adv(maxLat = 63, minLon = -107, maxLon = -87, minLat = 50, protocol = "griddap")
#' ed_search_adv(maxLat = 63, minLon = -107, maxLon = -87, minLat = 50, protocol = "tabledap")
#' ed_search_adv(minTime = "2010-01-01T00:00:00Z", maxTime="2010-02-01T00:00:00Z")
#' (out <- ed_search_adv(maxLat = 63, minLon = -107, maxLon = -87, minLat = 50,
#'              minTime = "2010-01-01T00:00:00Z", maxTime="2010-02-01T00:00:00Z"))
#' out$alldata[[1]]
#' ed_search_adv(variableName = 'upwelling')
#' ed_search_adv(query = 'upwelling', protocol = "tabledap")
#' }

ed_search_adv <- function(query = NULL, page = 1, page_size = 1000, protocol = NULL,
                      cdm_data_type = NULL, institution = NULL, ioos_category = NULL,
                      keywords = NULL, long_name = NULL, standard_name = NULL,
                      variableName = NULL, maxLat = NULL, minLon = NULL, maxLon = NULL,
                      minLat = NULL, minTime = NULL, maxTime = NULL, ...) {

  args <- rc(list(searchFor = query, page = page, itemsPerPage = page_size,
                  protocol = protocol, cdm_data_type = cdm_data_type,
                  institution = institution, ioos_category = ioos_category,
                  keywords = keywords, long_name = long_name, standard_name = standard_name,
                  variableName = variableName, maxLat = maxLat, minLon = minLon,
                  maxLon = maxLon, minLat = minLat, minTime = minTime, maxTime = maxTime))
  json <- erdddap_GET(paste0(eurl(), 'search/advanced.json'), args, ...)
  colnames <- vapply(tolower(json$table$columnNames), function(z) gsub("\\s", "_", z), "", USE.NAMES = FALSE)
  dfs <- lapply(json$table$rows, function(x){
    names(x) <- colnames
    x <- x[c('title', 'dataset_id')]
    as_data_frame(x)
  })
  df <- rbind_all(dfs)
  lists <- lapply(json$table$rows, setNames, nm = colnames)
  res <- list(info = df, alldata = lists)
  structure(res, class = "ed_search_adv")
}

#' @export
print.ed_search_adv <- function(x, ...){
  cat(sprintf("%s results, showing first 20", nrow(x$info)), "\n")
  print(head(x$info, n = 20))
}
