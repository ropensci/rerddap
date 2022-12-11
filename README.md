# rerddapXtracto (Version 1.1.3)
rerddapXtracto - R package for accessing environmental data using 'rerddap' 

******
`rxtracto()`option to use the ERDDAP "Interpolate service", which can greatly
speed up extracts for large tracks.
******



******
`rxtracto()` major rewrite of this function to reduce the number of requests made to the ERDDAP server, and to improve overall speed.
******


`rerddapXtracto` is an <span style="color:blue">R</span> package developed to subset and extract satellite and other oceanographic related data from a remote <span style="color:blue">ERDDAP</span> server. The program can extract data for a moving point in time along a user-supplied set of longitude, latitude, time and depth points; in a 3D bounding box; or within a polygon (through time). 

There are also two plotting functions,  `plotTrack()` and `plotBox()` that make use of the `plotdap` package.  See the new [rerdapXtracto vignette](https://rmendels.github.io/UsingrerddapXtracto.html). 



There are three main data extraction functions in the `rerddapXtracto` package: 

- `rxtracto <- function(dataInfo, parameter = NULL, xcoord = NULL, ycoord = NULL, zcoord = NULL, tcoord = NULL, xlen = 0., ylen = 0., zlen = 0., xName = 'longitude', yName = 'latitude', zName = 'altitude', tName = 'time', interp = NULL, verbose = FALSE, progress_bar = FALSE)`

- `rxtracto_3D <- function(dataInfo, parameter = NULL, xcoord = NULL, ycoord = NULL, zcoord = NULL, tcoord = NULL, xName = 'longitude', yName = 'latitude', zName = 'altitude', tName = 'time',  verbose = FALSE)`

- `rxtractogon <- function(dataInfo, parameter, xcoord = NULL, ycoord = NULL, zcoord = NULL, tcoord = NULL, xName = 'longitude', yName = 'latitude', zName = 'altitude', tName = 'time',  verbose = FALSE)`

and two functions for producing maps:

- `plotTrack <- function(resp, xcoord, ycoord, tcoord, plotColor = 'viridis', myFunc = NA,
                      mapData = NULL, crs = NULL,
                      animate = FALSE, cumulative = FALSE,
                      name = NA,  shape = 20, size = .5)`

- `plotBBox <- function(resp, plotColor = 'viridis', time = NA, myFunc = NA,
                mapData = NULL, crs = NULL,
                animate = FALSE, cumulative = FALSE, name = NA,
                maxpixels = 10000)`


For data requests that cross the dateline for datasets that are
on a (-180, 180) longitude grid, there are some important caveats:

- Request must be on a (0, 360) longitude grid
- Several of the checks that the request makes sense are disabled if the request
cross the dateline and the dataset is on a (-180, 180) longitude grid.
- User therefore has more responsibility to check that the request makes sense
for the dataset being accessed.





`rerddapXtracto` uses the `rerddap`, `ncdf4` , `parsedate`, `plotdap` and `sp` packages , and these packages (and the packages imported by these packages) must be installed first or `rerddapXtracto` will fail to install.   

```{r install,eval=FALSE}
install.packages("ncdf4") 
install.packages("parsedate") 
install.packages("plotdap") 
install.packages("rerddap") 
install.packages("sp")
```



```




# Required legalese

“The United States Department of Commerce (DOC) GitHub project code is provided
on an ‘as is’ basis and the user assumes responsibility for its use.
DOC has relinquished control of the information and no longer has responsibility
to protect the integrity, confidentiality, or availability of the information.
Any claims against the Department of Commerce stemming from the use of its
GitHub project will be governed by all applicable Federal law. Any reference to
specific commercial products, processes, or services by service mark, trademark,
manufacturer, or otherwise, does not constitute or imply their endorsement,
recommendation or favoring by the Department of Commerce. The Department of
Commerce seal and logo, or the seal and logo of a DOC bureau, shall not be used
in any manner to imply endorsement of any commercial product or activity by DOC
or the United States Government.”


