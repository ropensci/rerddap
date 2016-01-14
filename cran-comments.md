R CMD CHECK passed on my local OS X install with R 3.2.3 and
R development version, Ubuntu running on Travis-CI, 
and Win builder.

This submission replaces package ncdf with ncdf4. In addition, 
a number of improvements to fail more gracefully.

ncdf4 Windows binaries are now on the main CRAN mirrors, so 
I've removed the "Additional_repositories: http://www.stats.ox.ac.uk/pub/RWin"
entry in the DESCRIPTION file, as requested by Uwe.

Thanks! Scott Chamberlain
