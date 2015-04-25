rerddap
=====



[![Build Status](https://travis-ci.org/ropensci/rerddap.svg?branch=master)](https://travis-ci.org/ropensci/rerddap)
[![Build status](https://ci.appveyor.com/api/projects/status/nw858vlk4wx05mxm?svg=true)](https://ci.appveyor.com/project/sckott/rerddap)
[![Coverage Status](https://coveralls.io/repos/ropensci/rerddap/badge.svg)](https://coveralls.io/r/ropensci/rerddap)

`rerddap` is a general purpose R client for working with ERDDAP servers.

## Installation


```r
install.packages("devtools")
devtools::install_github("ropensci/rerddap")
```


```r
library('rerddap')
```

## Background

ERDDAP is a server built on top of OPenDAP, which serves some NOAA data. You can get gridded data ([griddap](http://upwell.pfeg.noaa.gov/erddap/griddap/documentation.html)), which lets you query from gridded datasets, or table data ([tabledap](http://upwell.pfeg.noaa.gov/erddap/tabledap/documentation.html)) which lets you query from tabular datasets. In terms of how we interface with them, there are similarties, but some differences too. We try to make a similar interface to both data types in `rerddap`.

## netCDF

`rerddap` supports netCDF format, and is the default when using the `griddap()` function. netCDF is a binary file format, and will have a much smaller footprint on your disk than csv. The binary file format means it's harder to inspect, but the `ncdf` and `ncdf4` packages make it easy to pull data out and write data back into a netCDF file. Note the the file extension for netCDF files is `.nc`. Whether you choose netCDF or csv for small files won't make much of a difference, but will with large files.

## Caching

Data files downloaded are cached in a single hidden directory `~/.rerddap` on your machine. It's hidden so that you don't accidentally delete the data, but you can still easily delete the data if you like. 

When you use `griddap()` or `tabledap()` functions, we construct a MD5 hash from the base URL, and any query parameters - this way each query is separately cached. Once we have the hash, we look in `~/.rerddap` for a matching hash. If there's a match we use that file on disk - if no match, we make a http request for the data to the ERDDAP server you specify. 

## ERDDAP servers

You can get a data.frame of ERDDAP servers using the function `servers()`. Most I think serve some kind of NOAA data, but there are a few that aren't NOAA data.  If you know of more ERDDAP servers, send a pull request, or let us know. 

## Search

First, you likely want to search for data, specify either `griddadp` or `tabledap`


```r
ed_search(query = 'size', which = "table")
#> 11 results, showing first 20 
#>                                                                                         title
#> 1                                                                          CalCOFI Fish Sizes
#> 2                                                                        CalCOFI Larvae Sizes
#> 3                Channel Islands, Kelp Forest Monitoring, Size and Frequency, Natural Habitat
#> 4                             NWFSC Observer Fixed Gear Data, off West Coast of US, 2002-2006
#> 5                                  NWFSC Observer Trawl Data, off West Coast of US, 2002-2006
#> 6                                                     GLOBEC NEP MOCNESS Plankton (MOC1) Data
#> 7                                                 GLOBEC NEP Vertical Plankton Tow (VPT) Data
#> 9                                                  OBIS - ARGOS Satellite Tracking of Animals
#> 10                                                        CalCOFI Larvae Counts Positive Tows
#> 11                                                                               CalCOFI Tows
#> 12 AN EXPERIMENTAL DATASET: Underway Sea Surface Temperature and Salinity Aboard the Oleander
#>             dataset_id
#> 1     erdCalCOFIfshsiz
#> 2     erdCalCOFIlrvsiz
#> 3       erdCinpKfmSFNH
#> 4   nwioosObsFixed2002
#> 5   nwioosObsTrawl2002
#> 6        erdGlobecMoc1
#> 7         erdGlobecVpt
#> 9            aadcArgos
#> 10 erdCalCOFIlrvcntpos
#> 11      erdCalCOFItows
#> 12            nodcPJJU
```


```r
ed_search(query = 'size', which = "grid")
#> 6 results, showing first 20 
#>                                                            title
#> 8                NOAA Global Coral Bleaching Monitoring Products
#> 13        Coawst 4 use, Best Time Series [time][eta_rho][xi_rho]
#> 14            Coawst 4 use, Best Time Series [time][eta_u][xi_u]
#> 15            Coawst 4 use, Best Time Series [time][eta_v][xi_v]
#> 16 Coawst 4 use, Best Time Series [time][s_rho][eta_rho][xi_rho]
#> 17  Coawst 4 use, Best Time Series [time][Nbed][eta_rho][xi_rho]
#>             dataset_id
#> 8             NOAA_DHW
#> 13 whoi_ed12_89ce_9592
#> 14 whoi_61c3_0b5d_cd61
#> 15 whoi_62d0_9d64_c8ff
#> 16 whoi_7dd7_db97_4bbe
#> 17 whoi_a4fb_2c9c_16a7
```

## Information

Then you can get information on a single dataset


```r
info('whoi_62d0_9d64_c8ff')
#> <ERDDAP Dataset> whoi_62d0_9d64_c8ff 
#>  Dimensions (range):  
#>      time: (2012-06-25T01:00:00Z, 2015-04-26T00:00:00Z) 
#>      eta_v: (0, 334) 
#>      xi_v: (0, 895) 
#>  Variables:  
#>      bedload_Vsand_01: 
#>          Units: kilogram meter-1 s-1 
#>      bedload_Vsand_02: 
#>          Units: kilogram meter-1 s-1 
#>      bedload_Vsand_03: 
#>          Units: kilogram meter-1 s-1 
#>      bedload_Vsand_04: 
#>          Units: kilogram meter-1 s-1 
#>      bedload_Vsand_05: 
#>          Units: kilogram meter-1 s-1 
#>      bedload_Vsand_06: 
#>          Units: kilogram meter-1 s-1 
#>      svstr: 
#>          Units: newton meter-2 
#>      vbar: 
#>          Units: meter second-1 
#>      wetdry_mask_v:
```

## griddap (gridded) data


```r
(out <- info('noaa_esrl_027d_0fb5_5d38'))
#> <ERDDAP Dataset> noaa_esrl_027d_0fb5_5d38 
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
  time = c('2012-01-01', '2012-01-12'),
  latitude = c(21, 20),
  longitude = c(-80, -79)
))
#> <NOAA ERDDAP griddap> noaa_esrl_027d_0fb5_5d38
#>    Path: [~/.rerddap/0c0d352c6ec861f6efadce493e270fd0.nc]
#>    Last updated: [2015-04-24 16:41:28]
#>    File size:    [0 mb]
#>    Dimensions (dims/vars):   [3 X 1]
#>    Dim names: time, latitude, longitude
#>    Variable names: CRUTEM3: Surface Air Temperature Monthly Anomaly
#>                   time  lat  long air
#> 1 2012-01-01T00:00:00Z 22.5 -77.5  NA
```

## tabledap (tabular) data


```r
(out <- info('erdCalCOFIfshsiz'))
#> <ERDDAP Dataset> erdCalCOFIfshsiz 
#>  Variables:  
#>      calcofi_species_code: 
#>          Range: 19, 1550 
#>      common_name: 
#>      cruise: 
#>      fish_1000m3: 
#>          Units: Fish per 1,000 cubic meters of water sampled 
#>      fish_count: 
#>      fish_size: 
#>          Units: mm 
#>      itis_tsn: 
#>      latitude: 
#>          Range: 32.515, 38.502 
#>          Units: degrees_north 
#>      line: 
#>          Range: 46.6, 93.3 
#>      longitude: 
#>          Range: -128.5, -117.33 
#>          Units: degrees_east 
#>      net_location: 
#>      net_type: 
#>      order_occupied: 
#>      percent_sorted: 
#>          Units: %/100 
#>      sample_quality: 
#>      scientific_name: 
#>      ship: 
#>      ship_code: 
#>      standard_haul_factor: 
#>      station: 
#>          Range: 28.0, 114.9 
#>      time: 
#>          Range: 9.94464E8, 9.9510582E8 
#>          Units: seconds since 1970-01-01T00:00:00Z 
#>      tow_number: 
#>          Range: 2, 10 
#>      tow_type: 
#>      volume_sampled: 
#>          Units: cubic meters
```


```r
tabledap(out, fields = c('longitude', 'latitude', 'fish_size', 'itis_tsn'),
         'time>=2001-07-07', 'time<=2001-07-10')
#> <NOAA ERDDAP tabledap> erdCalCOFIfshsiz
#>    Path: [~/.rerddap/52894d2daf4c71796c44775f06dc3f16.csv]
#>    Last updated: [2015-04-24 16:41:46]
#>    File size:    [0.02 mb]
#>    Dimensions:   [558 X 4]
#> 
#>     longitude  latitude fish_size itis_tsn
#> 2     -118.26    33.255      22.9   623745
#> 3     -118.26    33.255      22.9   623745
#> 4  -118.10667 32.738335      31.5   623625
#> 5  -118.10667 32.738335      48.3   623625
#> 6  -118.10667 32.738335      15.5   162221
#> 7  -118.10667 32.738335      16.3   162221
#> 8  -118.10667 32.738335      17.8   162221
#> 9  -118.10667 32.738335      18.2   162221
#> 10 -118.10667 32.738335      19.2   162221
#> 11 -118.10667 32.738335      20.0   162221
#> ..        ...       ...       ...      ...
```

## Meta

* Please [report any issues or bugs](https://github.com/ropensci/rerddap/issues).
* License: MIT
* Get citation information for `rerddap` in R doing `citation(package = 'rerddap')`

[![ropensci_footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
