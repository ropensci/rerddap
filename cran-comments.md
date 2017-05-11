## Test environments

* local OS X install, R 3.4.0
* ubuntu 12.04 (on travis-ci), R 3.4.0
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 1 note

License components with restrictions and base license permitting such:
  MIT + file LICENSE
File 'LICENSE':
  YEAR: 2017
  COPYRIGHT HOLDER: Scott Chamberlain

## Reverse dependencies

There are no reverse dependencies.

---

This version is being submitted to fix archiving of this package.

This is a new release. I have read and agree to the the CRAN
policies at https://cran.r-project.org/web/packages/policies.html

This submissions changes how cache path is determined, and now asks
the user where to cache files when they use functions that use 
file caching (not all do). Examples and tests now use temp dirs.

Thanks! 
Scott Chamberlain
