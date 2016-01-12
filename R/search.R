#' Search for ERDDAP tabledep or griddap datasets
#'
#' @export
#'
#' @param query (character) Search terms
#' @param page (integer) Page number
#' @param page_size (integer) Results per page
#' @param which (character) One of tabledep or griddap.
#' @param url A URL for an ERDDAP server. Default: \url{http://upwell.pfeg.noaa.gov/erddap/}
#' @param ... Further args passed on to \code{\link[httr]{GET}} (must be a named parameter)
#' @references  \url{http://upwell.pfeg.noaa.gov/erddap/index.html}
#' @author Scott Chamberlain <myrmecocystus@@gmail.com>
#' @examples \dontrun{
#' (out <- ed_search(query='temperature'))
#' out$alldata[[1]]
#' (out <- ed_search(query='size'))
#' out$info
#'
#' # List datasets
#' head( ed_datasets('table') )
#' head( ed_datasets('grid') )
#'
#' # use a different ERDDAP server
#' ## Marine Institute (Ireland)
#' ed_search("temperature", url = "http://erddap.marine.ie/erddap/")
#' ## Marine Domain Awareness (MDA) (Italy)
#' ed_search("temperature", url = "https://bluehub.jrc.ec.europa.eu/erddap/")
#' }

ed_search <- function(query, page=NULL, page_size=NULL, which='griddap', url = eurl(), ...){
  check_arg(query, "character")
  check_arg(page, "numeric")
  check_arg(page_size, "numeric")
  which <- match.arg(which, c("tabledap","griddap"), FALSE)
  args <- rc(list(searchFor = query, page = page, itemsPerPage = page_size))
  json <- erdddap_GET(paste0(url, 'search/index.json'), args, ...)
  colnames <- vapply(tolower(json$table$columnNames), function(z) gsub("\\s", "_", z), "", USE.NAMES = FALSE)
  dfs <- lapply(json$table$rows, function(x){
    names(x) <- colnames
    x <- x[c('title','dataset_id')]
    data.frame(x, stringsAsFactors = FALSE)
  })
  df <- data.frame(rbindlist(dfs))
  lists <- lapply(json$table$rows, setNames, nm = colnames)
  df$gd <- vapply(lists, function(x) if (x$griddap == "") "tabledap" else "griddap", character(1))
  df <- df[ df$gd == which, -3 ]
  row.names(df) <- NULL
  res <- list(info = df, alldata = lists)
  structure(res, class = "ed_search")
}

#' @export
print.ed_search <- function(x, ...){
  cat(sprintf("%s results, showing first 20", nrow(x$info)), "\n")
  print(head(x$info, n = 20))
}

table_or_grid <- function(datasetid){
  table_url <- paste0(eurl(), 'tabledap/index.json')
  tab <- toghelper(table_url)
  if (datasetid %in% tab) "tabledap" else "griddap"
}

toghelper <- function(url){
  out <- erdddap_GET(url, list(page = 1, itemsPerPage = 10000L))
  nms <- out$table$columnNames
  lists <- lapply(out$table$rows, setNames, nm = nms)
  vapply(lists, "[[", "", "Dataset ID")
}

#' @export
#' @rdname ed_search
ed_datasets <- function(which = 'tabledap', url = eurl()){
  which <- match.arg(which, c("tabledap","griddap"), FALSE)
  url <- sprintf('%s%s/index.json', url, which)
  out <- erdddap_GET(url, list(page = 1, itemsPerPage = 10000L))
  nms <- out$table$columnNames
  lists <- lapply(out$table$rows, setNames, nm = nms)
  data.frame(rbindlist(lapply(lists, data.frame, stringsAsFactors = FALSE)), stringsAsFactors = FALSE)
}
