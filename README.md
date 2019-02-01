rerddap
=====



[![cran checks](https://cranchecks.info/badges/worst/rerddap)](https://cranchecks.info/pkgs/rerddap)
[![Build Status](https://travis-ci.org/ropensci/rerddap.svg?branch=master)](https://travis-ci.org/ropensci/rerddap)
[![Build status](https://ci.appveyor.com/api/projects/status/nw858vlk4wx05mxm?svg=true)](https://ci.appveyor.com/project/sckott/rerddap)
[![codecov.io](https://codecov.io/github/ropensci/rerddap/coverage.svg?branch=master)](https://codecov.io/github/ropensci/rerddap?branch=master)
[![rstudio mirror downloads](http://cranlogs.r-pkg.org/badges/rerddap)](https://github.com/metacran/cranlogs.app)
[![cran version](http://www.r-pkg.org/badges/version/rerddap)](https://cran.r-project.org/package=rerddap)

`rerddap` is a general purpose R client for working with ERDDAP servers.

## Installation

From CRAN


```r
install.packages("rerddap")
```

Or development version from GitHub


```r
devtools::install_github("ropensci/rerddap")
```


```r
library("rerddap")
```

Some users may experience an installation error, stating to install 1 or more 
packages, e.g., you may need `DBI`, in which case do, for example, 
`install.packages("DBI")` before installing `rerddap`.

## Background

ERDDAP is a server built on top of OPenDAP, which serves some NOAA data. You can get gridded data ([griddap](https://upwell.pfeg.noaa.gov/erddap/griddap/documentation.html)), which lets you query from gridded datasets, or table data ([tabledap](https://upwell.pfeg.noaa.gov/erddap/tabledap/documentation.html)) which lets you query from tabular datasets. In terms of how we interface with them, there are similarties, but some differences too. We try to make a similar interface to both data types in `rerddap`.

## NetCDF

`rerddap` supports NetCDF format, and is the default when using the `griddap()` function. NetCDF is a binary file format, and will have a much smaller footprint on your disk than csv. The binary file format means it's harder to inspect, but the `ncdf4` package makes it easy to pull data out and write data back into a NetCDF file. Note the the file extension for NetCDF files is `.nc`. Whether you choose NetCDF or csv for small files won't make much of a difference, but will with large files.

## Caching

Data files downloaded are cached in a single directory on your machine determined by the [hoardr][] package. When you use `griddap()` or `tabledap()` functions, we construct a MD5 hash from the base URL, and any query parameters - this way each query is separately cached. Once we have the hash, we look in the cache directory for a matching hash. If there's a match we use that file on disk - if no match, we make a http request for the data to the ERDDAP server you specify.

## ERDDAP servers

You can get a data.frame of ERDDAP servers using the function `servers()`. Most I think serve some kind of NOAA data, but there are a few that aren't NOAA data.  If you know of more ERDDAP servers, send a pull request, or let us know.

## Search

First, you likely want to search for data, specify either `griddadp` or `tabledap`


```r
ed_search(query = "size", which = "table")
#> # A tibble: 9 x 2
#>   title                                                    dataset_id      
#>   <chr>                                                    <chr>           
#> 1 CalCOFI Larvae Sizes                                     erdCalCOFIlrvsiz
#> 2 Channel Islands, Kelp Forest Monitoring, Size and Frequ… erdCinpKfmSFNH  
#> 3 CalCOFI Larvae Counts Positive Tows                      erdCalCOFIlrvcn…
#> 4 CalCOFI Tows                                             erdCalCOFItows  
#> 5 NWFSC Observer Fixed Gear Data, off West Coast of US, 2… nwioosObsFixed2…
#> 6 NWFSC Observer Trawl Data, off West Coast of US, 2002-2… nwioosObsTrawl2…
#> 7 GLOBEC NEP MOCNESS Plankton (MOC1) Data, 2000-2002       erdGlobecMoc1   
#> 8 GLOBEC NEP Vertical Plankton Tow (VPT) Data, 1997-2001   erdGlobecVpt    
#> 9 AN EXPERIMENTAL DATASET: Underway Sea Surface Temperatu… nodcPJJU
```


```r
ed_search(query = "size", which = "grid")
#> # A tibble: 11 x 2
#>    title                                              dataset_id           
#>    <chr>                                              <chr>                
#>  1 Extended AVHRR Polar Pathfinder Fundamental Clima… noaa_ngdc_da08_dcdf_…
#>  2 Extended AVHRR Polar Pathfinder Fundamental Clima… noaa_ngdc_0fe5_a4b9_…
#>  3 Extended AVHRR Polar Pathfinder Fundamental Clima… noaa_ngdc_5253_bf9e_…
#>  4 Extended AVHRR Polar Pathfinder Fundamental Clima… noaa_ngdc_0f24_2f8c_…
#>  5 Archived Suite of NOAA Coral Reef Watch Operation… noaa_nodc_9f8b_ab7e_…
#>  6 Archived Suite of NOAA Coral Reef Watch Operation… noaa_nodc_da4e_3fc9_…
#>  7 USGS COAWST Forecast, US East Coast and Gulf of M… whoi_geoport_62d0_9d…
#>  8 USGS COAWST Forecast, US East Coast and Gulf of M… whoi_geoport_7dd7_db…
#>  9 USGS COAWST Forecast, US East Coast and Gulf of M… whoi_geoport_a4fb_2c…
#> 10 USGS COAWST Forecast, US East Coast and Gulf of M… whoi_geoport_ed12_89…
#> 11 USGS COAWST Forecast, US East Coast and Gulf of M… whoi_geoport_61c3_0b…
```

## Information

Then you can get information on a single dataset


```r
info("erdMBchla1day")
#> <ERDDAP info> erdMBchla1day 
#>  Dimensions (range):  
#>      time: (2006-01-01T12:00:00Z, 2019-01-30T12:00:00Z) 
#>      altitude: (0.0, 0.0) 
#>      latitude: (-45.0, 65.0) 
#>      longitude: (120.0, 320.0) 
#>  Variables:  
#>      chlorophyll: 
#>          Units: mg m-3
```

## griddap (gridded) data


```r
(out <- info("erdMBchla1day"))
#> <ERDDAP info> erdMBchla1day 
#>  Dimensions (range):  
#>      time: (2006-01-01T12:00:00Z, 2019-01-30T12:00:00Z) 
#>      altitude: (0.0, 0.0) 
#>      latitude: (-45.0, 65.0) 
#>      longitude: (120.0, 320.0) 
#>  Variables:  
#>      chlorophyll: 
#>          Units: mg m-3
```


```r
(res <- griddap(out,
  time = c("2015-01-01", "2015-01-03"),
  latitude = c(14, 15),
  longitude = c(125, 126)
))
#> <ERDDAP griddap> erdMBchla1day
#>    Path: [/Users/sckott/Library/Caches/R/rerddap/4d844aa48552049c3717ac94ced5f9b8.nc]
#>    Last updated: [2019-01-31 13:39:37]
#>    File size:    [0.03 mb]
#>    Dimensions (dims/vars):   [4 X 1]
#>    Dim names: time, altitude, latitude, longitude
#>    Variable names: Chlorophyll Concentration in Sea Water
#>    data.frame (rows/columns):   [5043 X 4]
#> # A tibble: 5,043 x 4
#>    time                   lat   lon chlorophyll
#>    <chr>                <dbl> <dbl>       <dbl>
#>  1 2015-01-01T12:00:00Z    14  125           NA
#>  2 2015-01-01T12:00:00Z    14  125.          NA
#>  3 2015-01-01T12:00:00Z    14  125.          NA
#>  4 2015-01-01T12:00:00Z    14  125.          NA
#>  5 2015-01-01T12:00:00Z    14  125.          NA
#>  6 2015-01-01T12:00:00Z    14  125.          NA
#>  7 2015-01-01T12:00:00Z    14  125.          NA
#>  8 2015-01-01T12:00:00Z    14  125.          NA
#>  9 2015-01-01T12:00:00Z    14  125.          NA
#> 10 2015-01-01T12:00:00Z    14  125.          NA
#> # … with 5,033 more rows
```

## tabledap (tabular) data


```r
(out <- info("erdCinpKfmBT"))
#> <ERDDAP info> erdCinpKfmBT 
#>  Variables:  
#>      Aplysia_californica_Mean_Density: 
#>          Range: 0.0, 0.95 
#>          Units: m-2 
#>      Aplysia_californica_StdDev: 
#>          Range: 0.0, 0.35 
#>      Aplysia_californica_StdErr: 
#>          Range: 0.0, 0.1 
#>      Crassedoma_giganteum_Mean_Density: 
#>          Range: 0.0, 0.92 
#>          Units: m-2 
#>      Crassedoma_giganteum_StdDev: 
#>          Range: 0.0, 0.71 
#>      Crassedoma_giganteum_StdErr: 
...
```


```r
tabledap("erdCinpKfmBT", "time>=2007-06-24", "time<=2007-07-01")
#> <ERDDAP tabledap> erdCinpKfmBT
#>    Path: [/Users/sckott/Library/Caches/R/rerddap/268b2474e9e613336b900d3289304bb0.csv]
#>    Last updated: [2019-01-31 13:39:39]
#>    File size:    [0.01 mb]
#> # A tibble: 37 x 53
#>    station longitude latitude depth time  Aplysia_califor… Aplysia_califor…
#>    <chr>   <chr>     <chr>    <chr> <chr> <chr>                       <dbl>
#>  1 Anacap… -119.416… 34.0     16.0  2007… 0.009722223                  0.01
#>  2 Anacap… -119.383… 34.0     17.0  2007… 0.0                          0   
#>  3 Anacap… -119.366… 34.0     6.0   2007… 0.0                          0   
#>  4 Anacap… -119.383… 34.0     11.0  2007… 0.16                         0.17
#>  5 Anacap… -119.416… 34.0     11.0  2007… 0.03                         0.01
#>  6 Anacap… -119.35   34.0166… 5.0   2007… 0.0                          0   
#>  7 Anacap… -119.35   34.0     8.0   2007… 0.008333334                  0.01
#>  8 SanCle… -118.533… 33.0     11.0  2007… NaN                        NaN   
#>  9 SanCle… -118.533… 32.95    10.0  2007… NaN                        NaN   
#> 10 SanCle… -118.4    32.8     13.0  2007… NaN                        NaN   
#> # … with 27 more rows, and 46 more variables:
#> #   Aplysia_californica_StdErr <dbl>,
#> #   Crassedoma_giganteum_Mean_Density <chr>,
#> #   Crassedoma_giganteum_StdDev <dbl>, Crassedoma_giganteum_StdErr <dbl>,
#> #   Haliotis_corrugata_Mean_Density <chr>,
#> #   Haliotis_corrugata_StdDev <dbl>, Haliotis_corrugata_StdErr <dbl>,
#> #   Haliotis_fulgens_Mean_Density <chr>, Haliotis_fulgens_StdDev <dbl>,
#> #   Haliotis_fulgens_StdErr <dbl>, Haliotis_rufescens_Mean_Density <chr>,
...
```

## Meta

* Please [report any issues or bugs](https://github.com/ropensci/rerddap/issues).
* License: MIT
* Get citation information for `rerddap` in R doing `citation(package = 'rerddap')`
* Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

[![ropensci_footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)

[hoardr]: https://github.com/ropensci/hoardr
