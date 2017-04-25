rerddap 0.4.0
=============

### NEW FEATURES

* New vignette added that goes in to much more depth than 
the original vignette (#51) thx to @rmendels
* `info()` function gains new attribute `url` with the 
base url for the ERDDAP server used (#42)
* Replaced usage of internal compact data.frame code to 
use `tibble` package (#45)

### MINOR IMPROVEMENTS

* Added another ERDDAP server to `servers()` function (#49)
* Changed base URLs for default ERDDAP server from `http` 
to `https`  (#50)
* Added note to docs for `griddap()` and `tabledap()` for how
to best deal with 500 server errors (#48)
* Replaced all `dplyr::rbind_all` uses with `dplyr::bind_rows` (#46)


rerddap 0.3.4
=============

### MINOR IMPROVEMENTS

* Removed use of `ncdf` package, which has been taken off CRAN.
Using `ncdf4` now for all NetCDF file manipulation. (#35)
* Failing better now with custom error catching (#31)
* Added many internal checks for parameter inputs, warning or
stopping as necessary - ERDDAP servers silently drop with no
informative messages (#32)

### BUG FIXES

* Using now `file.info()$size` instead of `file.size()` to be
backwards compatible with R versions < 3.2


rerddap 0.3.0
=============

### NEW FEATURES

* Cache functions accept the outputs of `griddap()` and `tabledap()`
so that the user can easily see cache details or delete the file from
the cache without having to manually get the file name. (#30)

### MINOR IMPROVEMENTS

* All package dependencies now use `importFrom` so we only import
functions we need instead of their global namespaces.

### BUG FIXES

* Fixed bug in parsing data from netcdf files, affected the
`griddap()` function (#28)


rerddap 0.2.0
=============

### NEW FEATURES

* Added a suite of functions to manage local cached files (#17)

### MINOR IMPROVEMENTS

* Added new ERDDAP server to list of servers in the `servers()` function (#21)

### BUG FIXES

* Fixed a few cases across a number of functions in which an empty list
passed to `query` parmaeter in `httr::GET()` caused an error (#23)
* Fixed retrieval of path to file written to disk by `httr::write_disk()` (#24)
* `last` is a value accepted by ERDDAP servers, but internal functions
weren't checking correctly, fixed now. (#25)
* `as.info()` wasn't passing on the `url` parameter to the `info()` function.
fixed now. (#26)


rerddap 0.1.0
=============

### NEW FEATURES

* released to CRAN
