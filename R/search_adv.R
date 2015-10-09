#' Advanced search for ERDDAP tabledep or griddap datasets
#'
#' @export
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
#' @param minLat,maxLat (numeric) Minimum and maximum latitude, between -90 and 90
#' @param minLon,maxLon (numeric) Minimum and maximum longitude. Some datasets have
#' longitude values within -180 to 180, others use 0 to 360. If you specify min and max
#' Longitude within -180 to 180 (or 0 to 360), ERDDAP will only find datasets that
#' match the values you specify. Consider doing one search: longitude -180 to 360,
#' or two searches: longitude -180 to 180, and 0 to 360.
#' @param minTime,maxTime (numeric/character) Minimum and maximum time. Time string with
#' the format "yyyy-MM-ddTHH:mm:ssZ, (e.g., 2009-01-21T23:00:00Z). If you specify something,
#' you must include at least yyyy-MM-dd; you can omit Z, :ss, :mm, :HH, and T. Always use
#' UTC (GMT/Zulu) time. Or specify the number of seconds since 1970-01-01T00:00:00Z.
#' @param url A URL for an ERDDAP server. Default: \url{http://upwell.pfeg.noaa.gov/erddap/}
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
#'
#' # use a different URL
#' ed_search_adv(query = 'temperature', url = servers()$url[6])
#' }

ed_search_adv <- function(query = NULL, page = 1, page_size = 1000, protocol = NULL,
                      cdm_data_type = NULL, institution = NULL, ioos_category = NULL,
                      keywords = NULL, long_name = NULL, standard_name = NULL,
                      variableName = NULL, maxLat = NULL, minLon = NULL, maxLon = NULL,
                      minLat = NULL, minTime = NULL, maxTime = NULL, url = eurl(), ...) {

  check_args(query, page, page_size, protocol, cdm_data_type, institution,
             ioos_category, keywords, long_name, standard_name, variableName,
             maxLat, minLon, maxLon, minLat, minTime, maxTime)
  args <- rc(list(searchFor = query, page = page, itemsPerPage = page_size,
                  protocol = protocol, cdm_data_type = cdm_data_type,
                  institution = institution, ioos_category = ioos_category,
                  keywords = keywords, long_name = long_name, standard_name = standard_name,
                  variableName = variableName, maxLat = maxLat, minLon = minLon,
                  maxLon = maxLon, minLat = minLat, minTime = minTime, maxTime = maxTime))
  json <- erdddap_GET(paste0(url, 'search/advanced.json'), args, ...)
  colnames <- vapply(tolower(json$table$columnNames), function(z) gsub("\\s", "_", z), "", USE.NAMES = FALSE)
  dfs <- lapply(json$table$rows, function(x){
    names(x) <- colnames
    x <- x[c('title', 'dataset_id')]
    dplyr::as_data_frame(x)
  })
  df <- dplyr::rbind_all(dfs)
  lists <- lapply(json$table$rows, setNames, nm = colnames)
  res <- list(info = df, alldata = lists)
  structure(res, class = "ed_search_adv")
}

#' @export
print.ed_search_adv <- function(x, ...){
  cat(sprintf("%s results, showing first 20", nrow(x$info)), "\n")
  print(head(x$info, n = 20))
}

check_args <- function(query, page, page_size, protocol, cdm_data_type, institution,
  ioos_category, keywords, long_name, standard_name,
  variableName, maxLat, minLon, maxLon, minLat, minTime, maxTime) {

  check_arg(query, "character")
  check_arg(page, "numeric")
  check_arg(page_size, "numeric")
  check_arg(protocol, "character")
  check_arg(cdm_data_type, "character")
  check_arg(institution, "character")
  check_arg(ioos_category, "character")
  check_arg(keywords, "character")
  check_arg(long_name, "character")
  check_arg(standard_name, "character")
  check_arg(variableName, "character")
  check_arg(maxLat, "numeric")
  check_arg(minLon, "numeric")
  check_arg(maxLon, "numeric")
  check_arg(minLat, "numeric")
  check_arg(minTime, c("numeric", "character"))
  check_arg(maxTime, c("numeric", "character"))
}

check_arg <- function(x, class) {
  var <- deparse(substitute(x))
  if (!is.null(x)) {
    if (!class(x) %in% class) {
      if (length(class) > 1) class <- paste0(class, collapse = ", ")
      stop(var, " not of class ", class, call. = FALSE)
    }
  }
}
