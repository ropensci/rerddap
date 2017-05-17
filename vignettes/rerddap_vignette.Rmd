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
#> # A tibble: 10 x 2
#>                                                                          title
#>                                                                          <chr>
#>  1                                                        CalCOFI Larvae Sizes
#>  2 Channel Islands, Kelp Forest Monitoring, Size and Frequency, Natural Habita
#>  3                          GLOBEC NEP MOCNESS Plankton (MOC1) Data, 2000-2002
#>  4                      GLOBEC NEP Vertical Plankton Tow (VPT) Data, 1997-2001
#>  5                                         CalCOFI Larvae Counts Positive Tows
#>  6                                                                CalCOFI Tows
#>  7                                  OBIS - ARGOS Satellite Tracking of Animals
#>  8             NWFSC Observer Fixed Gear Data, off West Coast of US, 2002-2006
#>  9                  NWFSC Observer Trawl Data, off West Coast of US, 2002-2006
#> 10 AN EXPERIMENTAL DATASET: Underway Sea Surface Temperature and Salinity Aboa
#> # ... with 1 more variables: dataset_id <chr>
```


```r
ed_search(query = 'size', which = "grid")
#> # A tibble: 347 x 2
#>                                                                          title
#>                                                                          <chr>
#>  1 ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0001) [time][
#>  2 ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0001) [time][
#>  3 ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0001) [time][
#>  4 ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0001) [time][
#>  5 ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0001) [time][
#>  6 ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0002) [time][
#>  7 ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0002) [time][
#>  8 ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0002) [time][
#>  9 ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0002) [time][
#> 10 ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0002) [time][
#> # ... with 337 more rows, and 1 more variables: dataset_id <chr>
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
#>      larvae_1000m3: 
#>          Units: Fish larvae per 1,000 cubic meters of water sampled 
#>      larvae_10m2: 
...
```

## griddap (gridded) data

First, get information on a dataset to see time range, lat/long range, and variables.


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

Then query for gridded data using the `griddap()` function


```r
(res <- griddap(out,
  time = c('2012-01-01', '2012-01-30'),
  latitude = c(21, 10),
  longitude = c(-80, -70)
))
#> <ERDDAP griddap> noaa_esrl_027d_0fb5_5d38
#>    Path: [/Users/sacmac/Library/Caches/R/rerddap/1a664ce4d6af316b611ac5a74a68d704.nc]
#>    Last updated: [2017-05-11 09:00:03]
#>    File size:    [0 mb]
#>    Dimensions (dims/vars):   [3 X 1]
#>    Dim names: time, latitude, longitude
#>    Variable names: CRUTEM3: Surface Air Temperature Monthly Anomaly
#>    data.frame (rows/columns):   [18 X 4]
#> # A tibble: 18 x 4
#>                    time   lat   lon   air
#>                   <chr> <dbl> <dbl> <dbl>
#>  1 2012-01-01T00:00:00Z  22.5 -77.5    NA
#>  2 2012-01-01T00:00:00Z  22.5 -72.5    NA
#>  3 2012-01-01T00:00:00Z  22.5 -67.5    NA
#>  4 2012-01-01T00:00:00Z  17.5 -77.5 -0.10
#>  5 2012-01-01T00:00:00Z  17.5 -72.5    NA
#>  6 2012-01-01T00:00:00Z  17.5 -67.5 -0.20
#>  7 2012-01-01T00:00:00Z  12.5 -77.5  0.20
#>  8 2012-01-01T00:00:00Z  12.5 -72.5    NA
#>  9 2012-01-01T00:00:00Z  12.5 -67.5  0.30
#> 10 2012-02-01T00:00:00Z  22.5 -77.5    NA
#> 11 2012-02-01T00:00:00Z  22.5 -72.5    NA
#> 12 2012-02-01T00:00:00Z  22.5 -67.5    NA
#> 13 2012-02-01T00:00:00Z  17.5 -77.5  0.40
#> 14 2012-02-01T00:00:00Z  17.5 -72.5    NA
#> 15 2012-02-01T00:00:00Z  17.5 -67.5  0.20
#> 16 2012-02-01T00:00:00Z  12.5 -77.5  0.00
#> 17 2012-02-01T00:00:00Z  12.5 -72.5    NA
#> 18 2012-02-01T00:00:00Z  12.5 -67.5  0.32
```

The output of `griddap()` is a list that you can explore further. Get the summary


```r
res$summary
#> $filename
#> [1] "/Users/sacmac/Library/Caches/R/rerddap/1a664ce4d6af316b611ac5a74a68d704.nc"
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
#> [1] "time"      "latitude"  "longitude"
```

Get the data.frame (beware: you may want to just look at the `head` of the data.frame if large)


```r
res$data
#>                    time  lat   lon   air
#> 1  2012-01-01T00:00:00Z 22.5 -77.5    NA
#> 2  2012-01-01T00:00:00Z 22.5 -72.5    NA
#> 3  2012-01-01T00:00:00Z 22.5 -67.5    NA
#> 4  2012-01-01T00:00:00Z 17.5 -77.5 -0.10
#> 5  2012-01-01T00:00:00Z 17.5 -72.5    NA
#> 6  2012-01-01T00:00:00Z 17.5 -67.5 -0.20
#> 7  2012-01-01T00:00:00Z 12.5 -77.5  0.20
#> 8  2012-01-01T00:00:00Z 12.5 -72.5    NA
#> 9  2012-01-01T00:00:00Z 12.5 -67.5  0.30
#> 10 2012-02-01T00:00:00Z 22.5 -77.5    NA
#> 11 2012-02-01T00:00:00Z 22.5 -72.5    NA
#> 12 2012-02-01T00:00:00Z 22.5 -67.5    NA
#> 13 2012-02-01T00:00:00Z 17.5 -77.5  0.40
#> 14 2012-02-01T00:00:00Z 17.5 -72.5    NA
#> 15 2012-02-01T00:00:00Z 17.5 -67.5  0.20
#> 16 2012-02-01T00:00:00Z 12.5 -77.5  0.00
#> 17 2012-02-01T00:00:00Z 12.5 -72.5    NA
#> 18 2012-02-01T00:00:00Z 12.5 -67.5  0.32
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
#>      larvae_1000m3: 
#>          Units: Fish larvae per 1,000 cubic meters of water sampled 
#>      larvae_10m2: 
...
```


```r
(dat <- tabledap('erdCalCOFIlrvsiz', fields=c('latitude','longitude','larvae_size',
  'scientific_name'), 'time>=2011-01-01', 'time<=2011-12-31'))
#> <ERDDAP tabledap> erdCalCOFIlrvsiz
#>    Path: [/Users/sacmac/Library/Caches/R/rerddap/db7389db5b5b0ed9c426d5c13bc43d18.csv]
#>    Last updated: [2017-05-11 09:04:58]
#>    File size:    [0.05 mb]
#> # A tibble: 1,217 x 4
#>     latitude longitude larvae_size        scientific_name
#>  *     <chr>     <chr>       <chr>                  <chr>
#>  1 32.956665  -117.305         4.5       Engraulis mordax
#>  2 32.956665  -117.305         2.9 Doryteuthis opalescens
#>  3 32.956665  -117.305         2.7 Doryteuthis opalescens
#>  4 32.956665  -117.305         3.3 Doryteuthis opalescens
#>  5 32.956665  -117.305         3.0 Doryteuthis opalescens
#>  6 32.956665  -117.305         3.7 Doryteuthis opalescens
#>  7 32.956665  -117.305         3.4 Doryteuthis opalescens
#>  8 32.956665  -117.305         3.2 Doryteuthis opalescens
#>  9 32.956665  -117.305         2.8 Doryteuthis opalescens
#> 10 32.956665  -117.305         3.6 Doryteuthis opalescens
#> # ... with 1,207 more rows
```

Since both `griddap()` and `tabledap()` give back data.frame's, it's easy to do downstream manipulation. For example, we can use `dplyr` to filter, summarize, group, and sort:


```r
library("dplyr")
dat$larvae_size <- as.numeric(dat$larvae_size)
dat %>%
  group_by(scientific_name) %>%
  summarise(mean_size = mean(larvae_size)) %>%
  arrange(desc(mean_size))
#> # A tibble: 6 x 2
#>          scientific_name mean_size
#>                    <chr>     <dbl>
#> 1       Engraulis mordax  8.446067
#> 2        Sardinops sagax  5.828738
#> 3   Merluccius productus  5.512176
#> 4 Doryteuthis opalescens  3.653363
#> 5      Scomber japonicus  3.400000
#> 6  Trachurus symmetricus  3.264444
```
