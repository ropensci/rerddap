R CMD CHECK passed on my local OS X install with R 3.2.3 and
R development version, Ubuntu running on Travis-CI, 
and Win builder.

This submission replaces package ncdf with ncdf4. In addition, 
a number of improvements to fail more gracefully.

ncdf4 Windows binaries are not on main CRAN mirrors, but are on http://www.stats.ox.ac.uk/pub/RWin.
I included "Additional_repositories: http://www.stats.ox.ac.uk/pub/RWin"
in the DESCRIPTION file, which seems to work for installing on 
Windows machines.

Thanks! Scott Chamberlain
