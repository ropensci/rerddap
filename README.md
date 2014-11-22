rerddap
=====



`rerddap` is a general purpose R client for working with ERDDAP servers.

## Installation


```r
install.packages("devtools")
devtools::install_github("ropensci/rerddap")
library('rerddap')
```

__or version with buoy functions on Github__


```r
install.packages("devtools")
devtools::install_github("ropensci/rerddap", ref="buoy")
```


```r
library('rerddap')
```

## Examples

ERDDAP is a server built on top of OPenDAP, which serves some NOAA data. You can get gridded data ([griddap](http://upwell.pfeg.noaa.gov/erddap/griddap/documentation.html)), which lets you query from gridded datasets, or table data ([tabledap](http://upwell.pfeg.noaa.gov/erddap/tabledap/documentation.html)) which lets you query from tabular datasets. In terms of how we interface with them, there are similarties, but some differences too. We try to make a similar interface to both data types in `rerddap`.

First, you likely want to search for data, specify either `griddadp` or `tabledap`


```r
ed_search(query='size', which = "table")
#> 11 results, showing first 20 
#>                                                                                         title
#> 1                                                                          CalCOFI Fish Sizes
#> 2                                                                        CalCOFI Larvae Sizes
#> 3                Channel Islands, Kelp Forest Monitoring, Size and Frequency, Natural Habitat
#> 4                             NWFSC Observer Fixed Gear Data, off West Coast of US, 2002-2006
#> 5                                  NWFSC Observer Trawl Data, off West Coast of US, 2002-2006
#> 6                                                         CalCOFI Larvae Counts Positive Tows
#> 7                                                                                CalCOFI Tows
#> 8                                                     GLOBEC NEP MOCNESS Plankton (MOC1) Data
#> 9                                                 GLOBEC NEP Vertical Plankton Tow (VPT) Data
#> 10                                                 OBIS - ARGOS Satellite Tracking of Animals
#> 11 AN EXPERIMENTAL DATASET: Underway Sea Surface Temperature and Salinity Aboard the Oleander
#>             dataset_id
#> 1     erdCalCOFIfshsiz
#> 2     erdCalCOFIlrvsiz
#> 3       erdCinpKfmSFNH
#> 4   nwioosObsFixed2002
#> 5   nwioosObsTrawl2002
#> 6  erdCalCOFIlrvcntpos
#> 7       erdCalCOFItows
#> 8        erdGlobecMoc1
#> 9         erdGlobecVpt
#> 10           aadcArgos
#> 11            nodcPJJU
```


```r
ed_search(query='size', which = "grid")
#> 5 results, showing first 20 
#>                                                            title
#> 12               NOAA Global Coral Bleaching Monitoring Products
#> 13            Coawst 4 use, Best Time Series [time][eta_u][xi_u]
#> 14            Coawst 4 use, Best Time Series [time][eta_v][xi_v]
#> 15 Coawst 4 use, Best Time Series [time][s_rho][eta_rho][xi_rho]
#> 16  Coawst 4 use, Best Time Series [time][Nbed][eta_rho][xi_rho]
#>               dataset_id
#> 12 hawaii_3b41_0c0b_72bc
#> 13   whoi_61c3_0b5d_cd61
#> 14   whoi_62d0_9d64_c8ff
#> 15   whoi_7dd7_db97_4bbe
#> 16   whoi_a4fb_2c9c_16a7
```

Then you can get information on a single dataset


```r
info('hawaii_3b41_0c0b_72bc')
#> <ERDDAP Dataset> hawaii_3b41_0c0b_72bc 
#>  Dimensions (range):  
#>      time: (2000-11-28T00:00:00Z, 2014-11-13T00:00:00Z) 
#>      latitude: (85.0, -80.0) 
#>      longitude: (-180.0, 179.5) 
#>  Variables:  
#>      CRW_DHW: 
#>          Units: Celsius weeks 
#>      CRW_HOTSPOT: 
#>          Units: Celsius 
#>      CRW_SST: 
#>          Units: Celsius 
#>      CRW_SSTANOMALY: 
#>          Units: Celsius
```

__griddap data__


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
  time = c('2012-01-01','2012-06-12'),
  latitude = c(21, 18),
  longitude = c(-80, -75)
))
#> <NOAA ERDDAP griddap> noaa_esrl_027d_0fb5_5d38
#>    Path: [/Users/sacmac/.rnoaa/erddap/noaa_esrl_027d_0fb5_5d38.csv]
#>    Last updated: [2014-11-04 10:36:20]
#>    File size:    [0 mb]
#>    Dimensions:   [24 X 4]
#> 
#>                    time latitude longitude  air
#> 1  2012-01-01T00:00:00Z     22.5     -77.5  NaN
#> 2  2012-01-01T00:00:00Z     22.5     -72.5  NaN
#> 3  2012-01-01T00:00:00Z     17.5     -77.5 -0.1
#> 4  2012-01-01T00:00:00Z     17.5     -72.5  NaN
#> 5  2012-02-01T00:00:00Z     22.5     -77.5  NaN
#> 6  2012-02-01T00:00:00Z     22.5     -72.5  NaN
#> 7  2012-02-01T00:00:00Z     17.5     -77.5  0.4
#> 8  2012-02-01T00:00:00Z     17.5     -72.5  NaN
#> 9  2012-03-01T00:00:00Z     22.5     -77.5  NaN
#> 10 2012-03-01T00:00:00Z     22.5     -72.5  NaN
#> ..                  ...      ...       ...  ...
```

__tabledap data__


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
tabledap(out, fields=c('longitude','latitude','fish_size','itis_tsn'),
    'time>=2001-07-07','time<=2001-07-10')
#> <NOAA ERDDAP tabledap> erdCalCOFIfshsiz
#>    Path: [~/.rnoaa/erddap/erdCalCOFIfshsiz.csv]
#>    Last updated: [2014-11-21 23:56:11]
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

* [Please report any issues or bugs](https://github.com/ropensci/rerddap/issues).
* License: MIT
* Get citation information for `rerddap` in R doing `citation(package = 'rerddap')`

[![](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
