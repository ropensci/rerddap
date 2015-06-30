<!--
%\VignetteEngine{knitr::knitr}
%\VignetteIndexEntry{rerddap introduction}
-->



rerddap introduction
====================

`rerddap` is a general purpose R client for working with ERDDAP servers. ERDDAP is a server built on top of OPenDAP, which serves some NOAA data. You can get gridded data ([griddap](http://upwell.pfeg.noaa.gov/erddap/griddap/documentation.html)), which lets you query from gridded datasets, or table data ([tabledap](http://upwell.pfeg.noaa.gov/erddap/tabledap/documentation.html)) which lets you query from tabular datasets. In terms of how we interface with them, there are similarties, but some differences too. We try to make a similar interface to both data types in `rerddap`.

## netCDF

`rerddap` supports netCDF format, and is the default when using the `griddap()` function. netCDF is a binary file format, and will have a much smaller footprint on your disk than csv. The binary file format means it's harder to inspect, but the `ncdf` and `ncdf4` packages make it easy to pull data out and write data back into a netCDF file. Note the the file extension for netCDF files is `.nc`. Whether you choose netCDF or csv for small files won't make much of a difference, but will with large files.

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
#> 11 results, showing first 20 
#>                                                                                         title
#> 1                                                                          CalCOFI Fish Sizes
#> 2                                                                        CalCOFI Larvae Sizes
#> 3                Channel Islands, Kelp Forest Monitoring, Size and Frequency, Natural Habitat
#> 4                                                         CalCOFI Larvae Counts Positive Tows
#> 5                                                                                CalCOFI Tows
#> 7                                                     GLOBEC NEP MOCNESS Plankton (MOC1) Data
#> 8                                                 GLOBEC NEP Vertical Plankton Tow (VPT) Data
#> 9                                                  OBIS - ARGOS Satellite Tracking of Animals
#> 10 AN EXPERIMENTAL DATASET: Underway Sea Surface Temperature and Salinity Aboard the Oleander
#> 11                            NWFSC Observer Fixed Gear Data, off West Coast of US, 2002-2006
#> 12                                 NWFSC Observer Trawl Data, off West Coast of US, 2002-2006
#>             dataset_id
#> 1     erdCalCOFIfshsiz
#> 2     erdCalCOFIlrvsiz
#> 3       erdCinpKfmSFNH
#> 4  erdCalCOFIlrvcntpos
#> 5       erdCalCOFItows
#> 7        erdGlobecMoc1
#> 8         erdGlobecVpt
#> 9            aadcArgos
#> 10            nodcPJJU
#> 11  nwioosObsFixed2002
#> 12  nwioosObsTrawl2002
```


```r
ed_search(query = 'size', which = "grid")
#> 6 results, showing first 20 
#>                                                                                                   title
#> 6                                                       NOAA Global Coral Bleaching Monitoring Products
#> 13        USGS COAWST Forecast, US East Coast and Gulf of Mexico (Experimental) [time][eta_rho][xi_rho]
#> 14            USGS COAWST Forecast, US East Coast and Gulf of Mexico (Experimental) [time][eta_u][xi_u]
#> 15            USGS COAWST Forecast, US East Coast and Gulf of Mexico (Experimental) [time][eta_v][xi_v]
#> 16 USGS COAWST Forecast, US East Coast and Gulf of Mexico (Experimental) [time][s_rho][eta_rho][xi_rho]
#> 17  USGS COAWST Forecast, US East Coast and Gulf of Mexico (Experimental) [time][Nbed][eta_rho][xi_rho]
#>             dataset_id
#> 6             NOAA_DHW
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
#> <ERDDAP info> whoi_62d0_9d64_c8ff 
#>  Dimensions (range):  
#>      time: (2012-06-25T01:00:00Z, 2015-07-01T00:00:00Z) 
#>      eta_v: (0, 334) 
#>      xi_v: (0, 895) 
#>  Variables:  
#>      bedload_Vsand_01: 
#>          Units: kilogram meter-1 s-1 
#>      bedload_Vsand_02: 
#>          Units: kilogram meter-1 s-1 
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
#>    Path: [~/.rerddap/648ed11e8b911b65e39eb63c8df339df.nc]
#>    Last updated: [2015-06-30 11:20:57]
#>    File size:    [0 mb]
#>    Dimensions (dims/vars):   [3 X 1]
#>    Dim names: time, latitude, longitude
#>    Variable names: CRUTEM3: Surface Air Temperature Monthly Anomaly
#>    data.frame (rows/columns):   [18 X 4]
#>                    time latitude longitude  air
#> 1  2012-01-01T00:00:00Z     22.5     -77.5   NA
#> 2  2012-01-01T00:00:00Z     22.5     -77.5   NA
#> 3  2012-01-01T00:00:00Z     22.5     -77.5   NA
#> 4  2012-01-01T00:00:00Z     22.5     -77.5 -0.1
#> 5  2012-01-01T00:00:00Z     22.5     -77.5   NA
#> 6  2012-01-01T00:00:00Z     22.5     -77.5 -0.2
#> 7  2012-01-01T00:00:00Z     17.5     -72.5  0.2
#> 8  2012-01-01T00:00:00Z     17.5     -72.5   NA
#> 9  2012-01-01T00:00:00Z     17.5     -72.5  0.3
#> 10 2012-02-01T00:00:00Z     17.5     -72.5   NA
#> ..                  ...      ...       ...  ...
```

The output of `griddap()` is a list that you can explore further. Get the summary


```r
res$summary
#> [1] "file ~/.rerddap/648ed11e8b911b65e39eb63c8df339df.nc has 3 dimensions:"
#> [1] "time   Size: 2"
#> [1] "latitude   Size: 3"
#> [1] "longitude   Size: 3"
#> [1] "------------------------"
#> [1] "file ~/.rerddap/648ed11e8b911b65e39eb63c8df339df.nc has 1 variables:"
#> [1] "float air[longitude,latitude,time]  Longname:CRUTEM3: Surface Air Temperature Monthly Anomaly Missval:-9.96920996838687e+36"
```

Get the dimension variables


```r
names(res$summary$dim)
#> [1] "time"      "latitude"  "longitude"
```

Get the data.frame (beware: you may want to just look at the `head` of the data.frame if large)


```r
res$data
#>                    time latitude longitude   air
#> 1  2012-01-01T00:00:00Z     22.5     -77.5    NA
#> 2  2012-01-01T00:00:00Z     22.5     -77.5    NA
#> 3  2012-01-01T00:00:00Z     22.5     -77.5    NA
#> 4  2012-01-01T00:00:00Z     22.5     -77.5 -0.10
#> 5  2012-01-01T00:00:00Z     22.5     -77.5    NA
#> 6  2012-01-01T00:00:00Z     22.5     -77.5 -0.20
#> 7  2012-01-01T00:00:00Z     17.5     -72.5  0.20
#> 8  2012-01-01T00:00:00Z     17.5     -72.5    NA
#> 9  2012-01-01T00:00:00Z     17.5     -72.5  0.30
#> 10 2012-02-01T00:00:00Z     17.5     -72.5    NA
#> 11 2012-02-01T00:00:00Z     17.5     -72.5    NA
#> 12 2012-02-01T00:00:00Z     17.5     -72.5    NA
#> 13 2012-02-01T00:00:00Z     12.5     -67.5  0.40
#> 14 2012-02-01T00:00:00Z     12.5     -67.5    NA
#> 15 2012-02-01T00:00:00Z     12.5     -67.5  0.20
#> 16 2012-02-01T00:00:00Z     12.5     -67.5  0.00
#> 17 2012-02-01T00:00:00Z     12.5     -67.5    NA
#> 18 2012-02-01T00:00:00Z     12.5     -67.5  0.32
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
...
```


```r
(dat <- tabledap(out, 'time>=2001-07-07', 'time<=2001-07-10', fields = c('longitude', 'latitude', 'fish_size', 'itis_tsn', 'scientific_name')))
#> <ERDDAP tabledap> erdCalCOFIfshsiz
#>    Path: [~/.rerddap/f013f9ee09bdb4184928d533e575e948.csv]
#>    Last updated: [2015-06-30 11:20:58]
#>    File size:    [0.03 mb]
#>    Dimensions:   [558 X 5]
#> 
#>     longitude  latitude fish_size itis_tsn       scientific_name
#> 2     -118.26    33.255      22.9   623745 Nannobrachium ritteri
#> 3     -118.26    33.255      22.9   623745 Nannobrachium ritteri
#> 4  -118.10667 32.738335      31.5   623625  Lipolagus ochotensis
#> 5  -118.10667 32.738335      48.3   623625  Lipolagus ochotensis
#> 6  -118.10667 32.738335      15.5   162221 Argyropelecus sladeni
#> 7  -118.10667 32.738335      16.3   162221 Argyropelecus sladeni
#> 8  -118.10667 32.738335      17.8   162221 Argyropelecus sladeni
#> 9  -118.10667 32.738335      18.2   162221 Argyropelecus sladeni
#> 10 -118.10667 32.738335      19.2   162221 Argyropelecus sladeni
#> 11 -118.10667 32.738335      20.0   162221 Argyropelecus sladeni
#> ..        ...       ...       ...      ...                   ...
```

Since both `griddap()` and `tabledap()` give back data.frame's, it's easy to do downstream manipulation. For example, we can use `dplyr` to filter, summarize, group, and sort:


```r
library("dplyr")
dat$fish_size <- as.numeric(dat$fish_size)
tbl_df(dat) %>% 
  filter(fish_size > 30) %>% 
  group_by(scientific_name) %>% 
  summarise(mean_size = mean(fish_size)) %>% 
  arrange(desc(mean_size))
#> Source: local data frame [20 x 2]
#> 
#>                 scientific_name mean_size
#> 1       Idiacanthus antrostomus 253.00000
#> 2            Stomias atriventer 189.25000
#> 3            Lestidiops ringens  98.70000
#> 4     Tarletonbeania crenularis  56.50000
#> 5      Ceratoscopelus townsendi  53.70000
#> 6     Stenobrachius leucopsarus  47.74538
#> 7               Sardinops sagax  47.00000
#> 8         Nannobrachium ritteri  43.30250
#> 9         Bathylagoides wesethi  43.09167
#> 10         Vinciguerria lucetia  42.00000
#> 11       Cyclothone acclinidens  40.80000
#> 12         Lipolagus ochotensis  39.72500
#> 13        Leuroglossus stilbius  38.35385
#> 14        Triphoturus mexicanus  38.21342
#> 15                Diaphus theta  37.88571
#> 16       Trachipterus altivelis  37.70000
#> 17 Symbolophorus californiensis  37.66000
#> 18         Nannobrachium regale  37.50000
#> 19         Merluccius productus  36.61333
#> 20        Argyropelecus sladeni  32.43333
```
