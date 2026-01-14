#' @title global_search
#' @description Search for ERDDAP™ tabledap or griddap datasets from a list
#' of ERDDAP™ servers based on search terms.
#' @param query (character) Search terms
#' @param server_list (list of character) List of ERDDAP™ servers to search
#' @param which_service (character) One of tabledep or griddap.
#' @return If successful a dataframe wih columns:
#'  \itemize{
#'     \item title - the dataset title
#'     \item dataset_id - the datasetid on that ERDDAP™ server
#'     \item url - base url of dataset ERDDAP™ server
#'  }
#'  if urls are valid,  no match is found,  will return no match found
#'  else returns error message
#' @details Uses the 'reddap' function ed_search() to search over
#' the list of servers
#' @examples
#' # get list of servers know by
#' # https://irishmarineinstitute.github.io/awesome-erddap
#' # e_servers <- servers()$url
#' # select a couple to search
#' # e_servers <- e_servers[c(1, 40)]
#' # to meet CRAN time limits will only search 1 place
#' e_servers <- "https://coastwatch.pfeg.noaa.gov/erddap/"
#' test_query <- 'C-HARM v1 2-Day Forecast'
#' query_results <- global_search(test_query, e_servers, "griddap")
#' @seealso
#'  \code{\link[crul]{HttpClient}}
#' @rdname global_search
#' @export
global_search <- function(query, server_list, which_service) {
  #  check that input is of correct type
  check_arg(query, "character")
  check_arg(server_list, "character")
  check_arg(which_service, "character")
  which_service <- match.arg(which_service, c("tabledap","griddap"), FALSE)
  search_url <- list()
  for (iserv in seq(1, length(server_list))) {
    # set which server
    my_serv <- server_list[iserv]
    good_url <- TRUE
    # will do two tests on the server
    # First is if erddap is not in URL
    test_url <- grepl('erddap', my_serv, fixed = TRUE)
    if (!test_url) {   # erddap not in url
      print(paste('server URL ', my_serv), ' does not contain "erddap"')
      print('will be removed from server list')
      good_url <- FALSE
    }
    #  test if URL reachable
    if (good_url) {
      test_url <- crul::HttpClient$new(my_serv)
      test_url_head <- try(test_url$head(), silent = TRUE)
      if (suppressWarnings(class(test_url_head)[1] == 'try-error'))  {
        print(paste(' server URL', my_serv, ' not responding'))
        good_url <- FALSE
      }
    }
    # good URL, responding, make query
    if (good_url){
      temp_list <- try(ed_search(query = query, url = my_serv,
                                 which = which_service),
                       silent = TRUE)
      class_error <- suppressWarnings(class(temp_list)[1]  == 'try-error')
      if(!class_error) {
        temp_list <- temp_list$info
        temp_names <- names(temp_list)
        temp_list$url <- rep(my_serv, nrow(temp_list))
        names(temp_list) <- c(temp_names, 'url')
        search_url <- rbind(search_url, temp_list)
      }
    }
  }
  if(length(search_url) == 0) {
    print('no search results found')
    return('no search results found')
  } else {
    return(search_url)
  }
}

