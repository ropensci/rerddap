rerddap
=====



[![cran checks](https://cranchecks.info/badges/worst/rerddap)](https://cranchecks.info/pkgs/rerddap)
[![R-check](https://github.com/ropensci/rerddap/workflows/R-check/badge.svg)](https://github.com/ropensci/rerddap/actions)
[![codecov.io](https://codecov.io/github/ropensci/rerddap/coverage.svg?branch=master)](https://codecov.io/github/ropensci/rerddap?branch=master)
[![rstudio mirror downloads](https://cranlogs.r-pkg.org/badges/rerddap)](https://github.com/r-hub/cranlogs.app)
[![cran version](https://www.r-pkg.org/badges/version/rerddap)](https://cran.r-project.org/package=rerddap)

`rerddap` is a general purpose R client for working with ERDDAP servers.

Package Docs: https://docs.ropensci.org/rerddap/

## Installation

From CRAN


```r
install.packages("rerddap")
```

Or development version from GitHub


```r
remotes::install_github("ropensci/rerddap")
```


```r
library("rerddap")
```

Some users may experience an installation error, stating to install 1 or more 
packages, e.g., you may need `DBI`, in which case do, for example, 
`install.packages("DBI")` before installing `rerddap`.

## Background

ERDDAP is a server built on top of OPenDAP, which serves some NOAA data. You can get gridded data (griddap (https://upwell.pfeg.noaa.gov/erddap/griddap/documentation.html)), which lets you query from gridded datasets, or table data (tabledap (https://upwell.pfeg.noaa.gov/erddap/tabledap/documentation.html)) which lets you query from tabular datasets. In terms of how we interface with them, there are similarities, but some differences too. We try to make a similar interface to both data types in `rerddap`.

## NetCDF

`rerddap` supports NetCDF format, and is the default when using the `griddap()` function. NetCDF is a binary file format, and will have a much smaller footprint on your disk than csv. The binary file format means it's harder to inspect, but the `ncdf4` package makes it easy to pull data out and write data back into a NetCDF file. Note the the file extension for NetCDF files is `.nc`. Whether you choose NetCDF or csv for small files won't make much of a difference, but will with large files.

## Caching

Data files downloaded are cached in a single directory on your machine determined by the `hoardr` package. When you use `griddap()` or `tabledap()` functions, we construct a MD5 hash from the base URL, and any query parameters - this way each query is separately cached. Once we have the hash, we look in the cache directory for a matching hash. If there's a match we use that file on disk - if no match, we make a http request for the data to the ERDDAP server you specify.

## ERDDAP servers

You can get a data.frame of ERDDAP servers using the function `servers()`. Most I think serve some kind of NOAA data, but there are a few that aren't NOAA data.  If you know of more ERDDAP servers, send a pull request, or let us know.

## Meta

* Please [report any issues or bugs](https://github.com/ropensci/rerddap/issues).
* License: MIT
* Get citation information for `rerddap` in R doing `citation(package = 'rerddap')`
* Please note that this package is released with a [Contributor Code of Conduct](https://ropensci.org/code-of-conduct/). By contributing to this project, you agree to abide by its terms.

[![ropensci_footer](https://ropensci.org/public_images/github_footer.png)](https://ropensci.org)
