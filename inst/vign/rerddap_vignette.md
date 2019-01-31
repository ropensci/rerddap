<!--
%\VignetteEngine{knitr::knitr}
%\VignetteIndexEntry{rerddap introduction}
%\VignetteEncoding{UTF-8}
-->



rerddap introduction
====================

`rerddap` is a general purpose R client for working with ERDDAP servers. ERDDAP is a server built on top of OPenDAP, which serves some NOAA data. You can get gridded data ([griddap](https://upwell.pfeg.noaa.gov/erddap/griddap/documentation.html)), which lets you query from gridded datasets, or table data ([tabledap](https://upwell.pfeg.noaa.gov/erddap/tabledap/documentation.html)) which lets you query from tabular datasets. In terms of how we interface with them, there are similarties, but some differences too. We try to make a similar interface to both data types in `rerddap`.

## NetCDF

`rerddap` supports NetCDF format, and is the default when using the `griddap()` function. NetCDF is a binary file format, and will have a much smaller footprint on your disk than csv. The binary file format means it's harder to inspect, but the `ncdf4` package makes it easy to pull data out and write data back into a NetCDF file. Note the the file extension for NetCDF files is `.nc`. Whether you choose NetCDF or csv for small files won't make much of a difference, but will with large files.

## Caching

Data files downloaded are cached in a single hidden directory `~/.rerddap` on your machine. It's hidden so that you don't accidentally delete the data, but you can still easily delete the data if you like.

When you use `griddap()` or `tabledap()` functions, we construct a MD5 hash from the base URL, and any query parameters - this way each query is separately cached. Once we have the hash, we look in `~/.rerddap` for a matching hash. If there's a match we use that file on disk - if no match, we make a http request for the data to the ERDDAP server you specify.

## ERDDAP servers

You can get a data.frame of ERDDAP servers using the function `servers()`. Most I think serve some kind of NOAA data, but there are a few that aren't NOAA data.  If you know of more ERDDAP servers, send a pull request, or let us know.

## Install

Stable version from CRAN


```r
install.packages("rerddap")
```

Or, the development version from GitHub


```r
devtools::install_github("ropensci/rerddap")
```


```r
library("rerddap")
```

## Search

First, you likely want to search for data, specify either `griddadp` or `tabledap`


```r
ed_search(query = 'size', which = "table")
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
ed_search(query = 'size', which = "grid")
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
info('erdCalCOFIlrvsiz')
#> <ERDDAP info> erdCalCOFIlrvsiz 
#>  Variables:  
#>      calcofi_species_code: 
#>          Range: 19, 9760 
#>      common_name: 
#>      cruise: 
#>      itis_tsn: 
#>      larvae_10m2: 
#>          Units: Fish larvae per ten meters squared of water sampled 
#>      larvae_count: 
...
```

## griddap (gridded) data

First, get information on a dataset to see time range, lat/long range, and variables.


```r
(out <- info('erdMBchla1day'))
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

Then query for gridded data using the `griddap()` function


```r
(res <- griddap(out,
  time = c('2015-01-01','2015-01-03'),
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

The output of `griddap()` is a list that you can explore further. Get the summary


```r
res$summary
#> $filename
#> [1] "/Users/sckott/Library/Caches/R/rerddap/4d844aa48552049c3717ac94ced5f9b8.nc"
#> 
#> $writable
#> [1] FALSE
#> 
#> $id
#> [1] 65536
#> 
#> $safemode
#> [1] FALSE
#> 
#> $format
#> [1] "NC_FORMAT_CLASSIC"
#> 
...
```

Get the dimension variables


```r
names(res$summary$dim)
#> [1] "time"      "altitude"  "latitude"  "longitude"
```

Get the data.frame (beware: you may want to just look at the `head` of the data.frame if large)


```r
head(res$data)
#>                   time lat     lon chlorophyll
#> 1 2015-01-01T12:00:00Z  14 125.000          NA
#> 2 2015-01-01T12:00:00Z  14 125.025          NA
#> 3 2015-01-01T12:00:00Z  14 125.050          NA
#> 4 2015-01-01T12:00:00Z  14 125.075          NA
#> 5 2015-01-01T12:00:00Z  14 125.100          NA
#> 6 2015-01-01T12:00:00Z  14 125.125          NA
```

## tabledap (tabular) data


```r
(out <- info('erdCalCOFIlrvsiz'))
#> <ERDDAP info> erdCalCOFIlrvsiz 
#>  Variables:  
#>      calcofi_species_code: 
#>          Range: 19, 9760 
#>      common_name: 
#>      cruise: 
#>      itis_tsn: 
#>      larvae_10m2: 
#>          Units: Fish larvae per ten meters squared of water sampled 
#>      larvae_count: 
...
```


```r
(dat <- tabledap('erdCalCOFIlrvsiz', fields=c('latitude','longitude','larvae_size',
  'scientific_name'), 'time>=2011-01-01', 'time<=2011-12-31'))
#> <ERDDAP tabledap> erdCalCOFIlrvsiz
#>    Path: [/Users/sckott/Library/Caches/R/rerddap/db7389db5b5b0ed9c426d5c13bc43d18.csv]
#>    Last updated: [2019-01-31 13:40:29]
#>    File size:    [0.07 mb]
#> # A tibble: 1,725 x 4
#>    latitude  longitude larvae_size scientific_name       
#>    <chr>     <chr>     <chr>       <chr>                 
#>  1 32.956665 -117.305  2.8         Doryteuthis opalescens
#>  2 32.956665 -117.305  3.4         Doryteuthis opalescens
#>  3 32.956665 -117.305  3.6         Doryteuthis opalescens
#>  4 32.956665 -117.305  3.1         Doryteuthis opalescens
#>  5 32.956665 -117.305  3.3         Doryteuthis opalescens
#>  6 32.956665 -117.305  3.7         Doryteuthis opalescens
#>  7 32.956665 -117.305  3.9         Doryteuthis opalescens
#>  8 32.956665 -117.305  2.7         Doryteuthis opalescens
#>  9 32.956665 -117.305  4.1         Doryteuthis opalescens
#> 10 32.956665 -117.305  2.8         Doryteuthis opalescens
#> # … with 1,715 more rows
```

Since both `griddap()` and `tabledap()` give back data.frame's, it's easy to do downstream manipulation. For example, we can use `dplyr` to filter, summarize, group, and sort:


```r
library("dplyr")
dat$larvae_size <- as.numeric(dat$larvae_size)
dat %>%
  group_by(scientific_name) %>%
  summarise(mean_size = mean(larvae_size)) %>%
  arrange(desc(mean_size))
#> # A tibble: 8 x 2
#>   scientific_name        mean_size
#>   <chr>                      <dbl>
#> 1 Anoplopoma fimbria         23.3 
#> 2 Engraulis mordax            9.26
#> 3 Sardinops sagax             7.29
#> 4 Merluccius productus        5.48
#> 5 Tactostoma macropus         5   
#> 6 Doryteuthis opalescens      3.67
#> 7 Scomber japonicus           3.4 
#> 8 Trachurus symmetricus       3.29
```
