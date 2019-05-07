rerddap 0.6.0
=============

### MINOR IMPROVEMENTS

* change all `tibble::as_data_frame`/`tibble::data_frame` to `tibble::as_tibble` (#79)
* `info()` gains new element in its output list, `base_url`, the base url for the ERDDAP server under consideration (#80)
* improved docs for `griddap()` with respect to what's returned from the function  (#81)
* fix some test fixtures to use preserve exact bytes so that cran checks on debian clang devel don't fail (#83)
* add .github files: contributing, issue template, pull request template

### BUG FIXES

* fix for lat/lon parsing within `griddap()` to account for cases when min and max are reversed from the order they should be in (#78)
* fix to `griddap()` to parse additioanl dimensions returned; previously we were only returning time, lat, and lon, plus one more (#82) thanks @afredstonhermann


rerddap 0.5.0
=============

### MINOR IMPROVEMENTS

* added new `Caching` section to package level manual file (`?rerddap`) about caching  (#52)
* use markdown docs in package (#75)
* replace `httr` with `crul` (#54)
* cache most tests with HTTP requests using `vcr` (#76)
* add test for `read` parameter in `griddap()` (#47)
* use default url via `eurl()`; used as default in main functions; set default url with env vars, see `?eurl`  (#41)
* improve handling and reporting back to user of ERDDAP server errors (#70) (#73)
* change to `griddap()`: when nc format gridded datasets have latitude and longitude we "melt" them into a data.frame for easy downstream consumption. When nc format gridded datasets do not have latitude and longitude components, we do not read in the data, throw a warning saying so. You can readin the nc file yourself with the file path (#74)
* for for `griddap()` to support cases in wihch lat/lon runs north to south and south to north (#68)

### BUG FIXES

* `memory()` usage in `griddap()` wasn't working. fixed now (#77)


rerddap 0.4.2
=============

### NEW FEATURES

* Now using `hoardr` to manage caching paths and such (#60). Also
now asking users where they want to cache files, either in a 
`rappdirs` user cache dir or a temp directory. Now on tests and examples
we use temp dirs.
* Related to above, new functions `cache_info()` to get cache path and 
number of cached files, and `cache_setup()` to set cache path.
* Related to above, `cache_details()`, `cache_list()`, and `cache_delete()`
lose their `cache_path` parameter - now cache path is set package wide and 
we use the same cache path, so no need to set in the fxn call.

### MINOR IMPROVEMENTS

* Fixes to a number of `griddap()` and `tabledap()` examples to use 
datasets that still exist (previous examples used datasets that are no
gone)


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
