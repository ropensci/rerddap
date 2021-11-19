## Test environments

* local macOS install, R 4.1.1
* rhub ubuntu, debian, solaris, Apple Silicon (M1), macOS 11.6 Big Sur
* win-builder (devel and release)

## R CMD check results

OK from all checks

## Reverse dependencies

* No probelms with reverse dependencies.

---

This version fixes a bug dealing with coordinates that
are not lat-lon and are in decreasing order.  Adds a new
search function.

Thanks! 
Roy Mendelssohn
