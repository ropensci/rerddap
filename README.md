rerddap
=====



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
library('rerddap')
```

Some users may experience an installation error, stating to install 1 or more
packages, e.g., you may need `DBI`, in which case do, for example,
`install.packages("DBI")` before installing `rerddap`.

## Background

ERDDAP is a server built on top of OPenDAP, which serves some NOAA data. You can get gridded data ([griddap](http://upwell.pfeg.noaa.gov/erddap/griddap/documentation.html)), which lets you query from gridded datasets, or table data ([tabledap](http://upwell.pfeg.noaa.gov/erddap/tabledap/documentation.html)) which lets you query from tabular datasets. In terms of how we interface with them, there are similarties, but some differences too. We try to make a similar interface to both data types in `rerddap`.

## NetCDF

`rerddap` supports NetCDF format, and is the default when using the `griddap()` function. NetCDF is a binary file format, and will have a much smaller footprint on your disk than csv. The binary file format means it's harder to inspect, but the `ncdf4` package makes it easy to pull data out and write data back into a NetCDF file. Note the the file extension for NetCDF files is `.nc`. Whether you choose NetCDF or csv for small files won't make much of a difference, but will with large files.

## Caching

Data files downloaded are cached in a single hidden directory `~/.rerddap` on your machine. It's hidden so that you don't accidentally delete the data, but you can still easily delete the data if you like.

When you use `griddap()` or `tabledap()` functions, we construct a MD5 hash from the base URL, and any query parameters - this way each query is separately cached. Once we have the hash, we look in `~/.rerddap` for a matching hash. If there's a match we use that file on disk - if no match, we make a http request for the data to the ERDDAP server you specify.

## ERDDAP servers

You can get a data.frame of ERDDAP servers using the function `servers()`. Most I think serve some kind of NOAA data, but there are a few that aren't NOAA data.  If you know of more ERDDAP servers, send a pull request, or let us know.

## Search

First, you likely want to search for data, specify either `griddadp` or `tabledap`


```r
ed_search(query = 'size', which = "table")
#> # A tibble: 10 x 2
#>                                                                          title
#>                                                                          <chr>
#>  1                                                        CalCOFI Larvae Sizes
#>  2 Channel Islands, Kelp Forest Monitoring, Size and Frequency, Natural Habita
#>  3             NWFSC Observer Fixed Gear Data, off West Coast of US, 2002-2006
#>  4                  NWFSC Observer Trawl Data, off West Coast of US, 2002-2006
#>  5                                         CalCOFI Larvae Counts Positive Tows
#>  6                                                                CalCOFI Tows
#>  7                          GLOBEC NEP MOCNESS Plankton (MOC1) Data, 2000-2002
#>  8                      GLOBEC NEP Vertical Plankton Tow (VPT) Data, 1997-2001
#>  9                                  OBIS - ARGOS Satellite Tracking of Animals
#> 10 AN EXPERIMENTAL DATASET: Underway Sea Surface Temperature and Salinity Aboa
#> # ... with 1 more variables: dataset_id <chr>
```


```r
ed_search(query = 'size', which = "grid")
#> # A tibble: 290 x 2
#>                                                                          title
#>                                                                          <chr>
#>  1 COAWST Hindcast:MVCO/CBlast 2007:ripples with SWAN-40m res (00 dir roms) [t
#>  2 COAWST Hindcast:MVCO/CBlast 2007:ripples with SWAN-40m res (00 dir roms) [t
#>  3 COAWST Hindcast:MVCO/CBlast 2007:ripples with SWAN-40m res (00 dir roms) [t
#>  4 COAWST Hindcast:MVCO/CBlast 2007:ripples with SWAN-40m res (00 dir roms) [t
#>  5 COAWST Hindcast:MVCO/CBlast 2007:ripples with SWAN-40m res (00 dir roms) [t
#>  6 ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0001) [time][
#>  7 ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0001) [time][
#>  8 ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0001) [time][
#>  9 ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0001) [time][
#> 10 ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0001) [time][
#> # ... with 280 more rows, and 1 more variables: dataset_id <chr>
```

## Information

Then you can get information on a single dataset


```r
info('noaa_esrl_027d_0fb5_5d38')
#> <ERDDAP info> noaa_esrl_027d_0fb5_5d38
#>  Dimensions (range):
#>      time: (1850-01-01T00:00:00Z, 2014-05-01T00:00:00Z)
#>      latitude: (87.5, -87.5)
#>      longitude: (-177.5, 177.5)
#>  Variables:
#>      air:
#>          Range: -20.9, 19.5
#>          Units: degC
```

## griddap (gridded) data


```r
(out <- info('noaa_esrl_027d_0fb5_5d38'))
#> <ERDDAP info> noaa_esrl_027d_0fb5_5d38
#>  Dimensions (range):
#>      time: (1850-01-01T00:00:00Z, 2014-05-01T00:00:00Z)
#>      latitude: (87.5, -87.5)
#>      longitude: (-177.5, 177.5)
#>  Variables:
#>      air:
#>          Range: -20.9, 19.5
#>          Units: degC
```


```r
(res <- griddap(out,
  time = c('2012-01-01', '2012-01-31'),
  latitude = c(25, 20),
  longitude = c(-80, -79)
))
#> <ERDDAP griddap> noaa_esrl_027d_0fb5_5d38
#>    Path: [/Users/sacmac/Library/Caches/R/rerddap/255eef5d77931489e5282a3db6e807d9.nc]
#>    Last updated: [2017-07-11 13:30:33]
#>    File size:    [0 mb]
#>    Dimensions (dims/vars):   [3 X 1]
#>    Dim names: time, latitude, longitude
#>    Variable names: CRUTEM3: Surface Air Temperature Monthly Anomaly
#>    data.frame (rows/columns):   [4 X 4]
#> # A tibble: 4 x 4
#>                   time   lat   lon   air
#>                  <chr> <dbl> <dbl> <dbl>
#> 1 2012-01-01T00:00:00Z  27.5 -77.5    NA
#> 2 2012-01-01T00:00:00Z  22.5 -77.5    NA
#> 3 2012-02-01T00:00:00Z  27.5 -77.5     2
#> 4 2012-02-01T00:00:00Z  22.5 -77.5    NA
```

## tabledap (tabular) data


```r
(out <- info('erdCinpKfmBT'))
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
tabledap('erdCinpKfmBT', 'time>=2007-06-24', 'time<=2007-07-01')
#> <ERDDAP tabledap> erdCinpKfmBT
#>    Path: [/Users/sacmac/Library/Caches/R/rerddap/268b2474e9e613336b900d3289304bb0.csv]
#>    Last updated: [2017-07-11 13:30:37]
#>    File size:    [0.01 mb]
#> # A tibble: 37 x 53
#>                       station         longitude         latitude depth
#>  *                      <chr>             <chr>            <chr> <chr>
#>  1       Anacapa_AdmiralsReef -119.416666666667             34.0  16.0
#>  2   Anacapa_BlackSeaBassReef -119.383333333333             34.0  17.0
#>  3      Anacapa_CathedralCove -119.366666666667             34.0   6.0
#>  4       Anacapa_EastFishCamp -119.383333333333             34.0  11.0
#>  5            Anacapa_Keyhole -119.416666666667             34.0  11.0
#>  6        Anacapa_LandingCove           -119.35 34.0166666666667   5.0
#>  7         Anacapa_Lighthouse           -119.35             34.0   8.0
#>  8   SanClemente_BoyScoutCamp -118.533333333333             33.0  11.0
#>  9       SanClemente_EelPoint -118.533333333333            32.95  10.0
#> 10 SanClemente_HorseBeachCove            -118.4             32.8  13.0
#> # ... with 27 more rows, and 49 more variables: time <chr>,
#> #   Aplysia_californica_Mean_Density <chr>,
#> #   Aplysia_californica_StdDev <dbl>, Aplysia_californica_StdErr <dbl>,
#> #   Crassedoma_giganteum_Mean_Density <chr>,
#> #   Crassedoma_giganteum_StdDev <dbl>, Crassedoma_giganteum_StdErr <dbl>,
#> #   Haliotis_corrugata_Mean_Density <chr>,
#> #   Haliotis_corrugata_StdDev <dbl>, Haliotis_corrugata_StdErr <dbl>,
#> #   Haliotis_fulgens_Mean_Density <chr>, Haliotis_fulgens_StdDev <dbl>,
...
```

## Meta

* Please [report any issues or bugs](https://github.com/ropensci/rerddap/issues).
* License: MIT
* Get citation information for `rerddap` in R doing `citation(package = 'rerddap')`
* Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

[![ropensci_footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
