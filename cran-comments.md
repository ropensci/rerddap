I have read and agree to the the CRAN policies at http://cran.r-project.org/web/packages/policies.html

R CMD CHECK passed on my local OS X install with R 3.2.0 and
R development version, Ubuntu running on Travis-CI, and Win builder.

On exception is that Win-builder warns:

* checking package dependencies ... NOTE
Package suggested but not available for checking: 'ncdf4'

ncdf4 binaries are not available for Windows, so the package is 
in Suggests, for those on Linux/OSX, or Windows users that manage 
to install the package from source. 

Thanks! Scott Chamberlain
