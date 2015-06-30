R CMD CHECK passed on my local OS X install with R 3.2.1 and
R development version, Ubuntu running on Travis-CI, and Win builder.


This submission is mostly to fix a number of broken functions due to the 
recent update in httr on CRAN to v1.0. 


As noted on my first submission, one exception is that Win-builder warns:

* checking package dependencies ... NOTE
Package suggested but not available for checking: 'ncdf4'

ncdf4 binaries are not available for Windows, so the package is 
in Suggests, for those on Linux/OSX, or Windows users that manage 
to install the package from source. Windows users can use ncdf, for
which binaries are available on CRAN.


Thanks! Scott Chamberlain
