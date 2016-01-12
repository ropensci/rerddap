rerddap
=====



[![Build Status](https://travis-ci.org/ropensci/rerddap.svg?branch=master)](https://travis-ci.org/ropensci/rerddap)
[![Build status](https://ci.appveyor.com/api/projects/status/nw858vlk4wx05mxm?svg=true)](https://ci.appveyor.com/project/sckott/rerddap)
[![codecov.io](https://codecov.io/github/ropensci/rerddap/coverage.svg?branch=master)](https://codecov.io/github/ropensci/rerddap?branch=master)
[![rstudio mirror downloads](http://cranlogs.r-pkg.org/badges/grand-total/rerddap)](https://github.com/metacran/cranlogs.app)
[![cran version](http://www.r-pkg.org/badges/version/rerddap)](http://cran.rstudio.com/web/packages/rerddap)

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
#> 11 results, showing first 20 
#>                                                                                          title
#> 1                                                                           CalCOFI Fish Sizes
#> 2                                                                         CalCOFI Larvae Sizes
#> 3                 Channel Islands, Kelp Forest Monitoring, Size and Frequency, Natural Habitat
#> 309                                                        CalCOFI Larvae Counts Positive Tows
#> 310                                                                               CalCOFI Tows
#> 316                                                 OBIS - ARGOS Satellite Tracking of Animals
#> 317                                                    GLOBEC NEP MOCNESS Plankton (MOC1) Data
#> 318                                                GLOBEC NEP Vertical Plankton Tow (VPT) Data
#> 319                            NWFSC Observer Fixed Gear Data, off West Coast of US, 2002-2006
#> 320                                 NWFSC Observer Trawl Data, off West Coast of US, 2002-2006
#> 322 AN EXPERIMENTAL DATASET: Underway Sea Surface Temperature and Salinity Aboard the Oleander
#>              dataset_id
#> 1      erdCalCOFIfshsiz
#> 2      erdCalCOFIlrvsiz
#> 3        erdCinpKfmSFNH
#> 309 erdCalCOFIlrvcntpos
#> 310      erdCalCOFItows
#> 316           aadcArgos
#> 317       erdGlobecMoc1
#> 318        erdGlobecVpt
#> 319  nwioosObsFixed2002
#> 320  nwioosObsTrawl2002
#> 322            nodcPJJU
```


```r
ed_search(query = 'size', which = "grid")
#> 311 results, showing first 20 
#>                                                                                                 title
#> 4         ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0008) [time][eta_rho][xi_rho]
#> 5             ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0008) [time][eta_u][xi_u]
#> 6             ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0008) [time][eta_v][xi_v]
#> 7  ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0008) [time][s_rho][eta_rho][xi_rho]
#> 8   ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0008) [time][Nbed][eta_rho][xi_rho]
#> 9         ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0009) [time][eta_rho][xi_rho]
#> 10            ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0009) [time][eta_u][xi_u]
#> 11            ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0009) [time][eta_v][xi_v]
#> 12 ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0009) [time][s_rho][eta_rho][xi_rho]
#> 13  ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0009) [time][Nbed][eta_rho][xi_rho]
#> 14        ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0010) [time][eta_rho][xi_rho]
#> 15            ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0010) [time][eta_u][xi_u]
#> 16            ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0010) [time][eta_v][xi_v]
#> 17 ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0010) [time][s_rho][eta_rho][xi_rho]
#> 18  ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0010) [time][Nbed][eta_rho][xi_rho]
#> 19        ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0011) [time][eta_rho][xi_rho]
#> 20            ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0011) [time][eta_u][xi_u]
#> 21            ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0011) [time][eta_v][xi_v]
#> 22 ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0011) [time][s_rho][eta_rho][xi_rho]
#> 23  ROMS3.0 CBLAST2007 Ripples with SWAN-40m res (his case7 ar0fd 0011) [time][Nbed][eta_rho][xi_rho]
#>             dataset_id
#> 4  whoi_cbae_ef31_0877
#> 5  whoi_61f3_6dac_36c1
#> 6  whoi_4eff_1b8e_513a
#> 7  whoi_4d06_1f87_db0b
#> 8  whoi_4849_5c78_58dc
#> 9  whoi_28c3_4a74_191a
#> 10 whoi_e627_874c_2b1b
#> 11 whoi_9183_ea0f_9417
#> 12 whoi_322d_c428_66b4
#> 13 whoi_5f75_6229_f722
#> 14 whoi_02c9_858d_bc77
#> 15 whoi_689d_0109_9280
#> 16 whoi_4f6e_439a_8e4b
#> 17 whoi_5451_efbd_60ac
#> 18 whoi_1ace_a9ee_f343
#> 19 whoi_0524_c15f_28da
#> 20 whoi_e5c5_72b2_af51
#> 21 whoi_1fcf_de1b_c428
#> 22 whoi_e305_a468_eabc
#> 23 whoi_0657_2b81_14df
```

## Information

Then you can get information on a single dataset


```r
info('whoi_62d0_9d64_c8ff')
#> <ERDDAP info> whoi_62d0_9d64_c8ff 
#>  Dimensions (range):  
#>      time: (2012-06-25T01:00:00Z, 2015-10-14T00:00:00Z) 
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
  time = c('2012-01-01', '2012-01-12'),
  latitude = c(21, 20),
  longitude = c(-80, -79)
))
#> <ERDDAP griddap> noaa_esrl_027d_0fb5_5d38
#>    Path: [~/.rerddap/0c0d352c6ec861f6efadce493e270fd0.nc]
#>    Last updated: [2016-01-12 08:21:21]
#>    File size:    [0 mb]
#>    Dimensions (dims/vars):   [3 X 1]
#>    Dim names: time, latitude, longitude
#>    Variable names: CRUTEM3: Surface Air Temperature Monthly Anomaly
#>    data.frame (rows/columns):   [1 X 4]
#>                   time  lat   lon air
#> 1 2012-01-01T00:00:00Z 22.5 -77.5  NA
```

## tabledap (tabular) data


```r
(out <- info('erdCalCOFIfshsiz'))
#> <ERDDAP info> erdCalCOFIfshsiz 
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
#> <ERDDAP tabledap> erdCalCOFIfshsiz
#>    Path: [~/.rerddap/52894d2daf4c71796c44775f06dc3f16.csv]
#>    Last updated: [2016-01-12 08:21:22]
#>    File size:    [0.02 mb]
#>    Dimensions:   [558 X 4]
#> 
#>     longitude  latitude fish_size itis_tsn
#> 2  -118.10667 32.738335      31.5   623625
#> 3  -118.10667 32.738335      48.3   623625
#> 4  -118.10667 32.738335      15.5   162221
#> 5  -118.10667 32.738335      16.3   162221
#> 6  -118.10667 32.738335      17.8   162221
#> 7  -118.10667 32.738335      18.2   162221
#> 8  -118.10667 32.738335      19.2   162221
#> 9  -118.10667 32.738335      20.0   162221
#> 10 -118.10667 32.738335      21.0   162221
#> 11 -118.10667 32.738335      21.5   162221
#> ..        ...       ...       ...      ...
```

## Meta

* Please [report any issues or bugs](https://github.com/ropensci/rerddap/issues).
* License: MIT
* Get citation information for `rerddap` in R doing `citation(package = 'rerddap')`
* Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

[![ropensci_footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
