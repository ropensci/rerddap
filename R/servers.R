#' ERDDAP server URLS and other info
#'
#' @export
#' @examples
#' servers()
servers <- function() {
  stats::setNames(
    data.frame(do.call("rbind", list(
    c("Marine Domain Awareness (MDA) - Italy",
      "https://bluehub.jrc.ec.europa.eu/erddap/"),
    c("Marine Institute - Ireland",
      "http://erddap.marine.ie/erddap/"),
    c("CoastWatch Caribbean/Gulf of Mexico Node",
      "http://cwcgom.aoml.noaa.gov/erddap/"),
    c("CoastWatch West Coast Node",
      "https://coastwatch.pfeg.noaa.gov/erddap/"),
    c("NOAA IOOS CeNCOOS (Central and Northern California Ocean Observing System)",
      "http://erddap.axiomalaska.com/erddap/"),
    c("NOAA IOOS NERACOOS (Northeastern Regional Association of Coastal and Ocean Observing Systems)",
      "http://www.neracoos.org/erddap/"),
    c("NOAA IOOS NGDAC (National Glider Data Assembly Center)",
      "http://data.ioos.us/gliders/erddap/"),
    c("NOAA IOOS PacIOOS (Pacific Islands Ocean Observing System) at the University of Hawaii (UH)",
      "http://oos.soest.hawaii.edu/erddap/"),
    c("NOAA IOOS SECOORA (Southeast Coastal Ocean Observing Regional Association)",
      "http://129.252.139.124/erddap/"),
    c("NOAA NCEI (National Centers for Environmental Information) / NCDDC",
      "http://ecowatch.ncddc.noaa.gov/erddap/"),
    c("NOAA OSMC (Observing System Monitoring Center)",
      "http://osmc.noaa.gov/erddap/"),
    c("NOAA UAF (Unified Access Framework)",
      "https://upwell.pfeg.noaa.gov/erddap/"),
    c("ONC (Ocean Networks Canada)",
      "http://dap.onc.uvic.ca/erddap/"),
    c("UC Davis BML (University of California at Davis, Bodega Marine Laboratory)",
      "http://bmlsc.ucdavis.edu:8080/erddap/"),
    c("R.Tech Engineering", "http://meteo.rtech.fr/erddap/"),
    c("French Research Institute for the Exploitation of the Sea",
      "http://www.ifremer.fr/erddap/index.html")
  )), stringsAsFactors = FALSE), c('name', 'url'))
}
