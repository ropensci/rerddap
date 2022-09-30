## Test environments

* local macOS install, R 4.2.1
* rhub (devtools::check_rhub())
* macOS Builder (devtools::check_mac_release())
* win-builder (devel and release - devtools::check_win_*())

## R CMD check results

OK from all checks

## Reverse dependencies

* I am maintainer of plotdap and rerddapXracto - they check out
* The maintainer of PAMmisc tested new version wih no problem

---

This version fixes a bug dealing with coordinates that
are not lat-lon and are in decreasing order.  Adds a new
search function.

Thanks! 
Roy Mendelssohn
