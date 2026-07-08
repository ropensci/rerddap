---
name: rerddap
description: Help users write correct R code with rerddap to search, retrieve, cache, or convert oceanographic and environmental data from ERDDAP(TM) servers. Use when users need to call info(), griddap(), tabledap(), ed_search(), ed_search_adv(), global_search(), estimate request size, manage the rerddap cache, point at a non-default ERDDAP server, or convert times/units/FIPS codes/keywords via rerddap's convert_* helpers.
metadata:
  author: Roy Mendelssohn (@rmendels)
  version: "1.0"
license: MIT
---

rerddap is a general purpose R client for ERDDAP(TM) servers — servers that serve gridded data (`griddap`) and tabular data (`tabledap`), mostly NOAA earth-science datasets.

## Core Principle: info() Before Data

`griddap()` and `tabledap()` need exact dimension names, variable names, and actual data ranges — these come from `info()`, never from guessing. Both functions accept the `info` object directly (skips a re-fetch of metadata).

```r
library(rerddap)

# ALWAYS start here
out <- info('erdMH1chla8day')
print(out)          # summary: dimensions (with ranges) and variables (with units/range)
out$variables        # data.frame of data variables, types, actual_range
out$alldata$time     # full attribute list for a specific dimension or variable

# pass the info object straight into griddap()/tabledap()
chl <- griddap(out,
  time      = c('2020-01-01', '2020-01-10'),
  latitude  = c(30, 40),
  longitude = c(-130, -120),
  fields    = 'chlorophyll'
)
```

**Wrong pattern:** calling `griddap(datasetid, ...)` with dimension names/ranges guessed from memory or a website. This throws `"Some input dimensions (...) don't match those in dataset"` or `"...outside data range"`. Always `print(out)` (or inspect `out$alldata`) first to get the real dimension names and ranges — they vary per dataset (e.g. `time`/`latitude`/`longitude` vs. ROMS-style `time`/`xi_rho`/`eta_rho`).

## Discovering Datasets

```r
# free-text search on the default ERDDAP (griddap datasets by default)
ed_search(query = 'chlorophyll')
ed_search(query = 'chlorophyll', which = 'tabledap')

# advanced search: bounding box, time range, protocol, institution, keywords...
ed_search_adv(
  query = 'temperature', protocol = 'griddap',
  minLat = 30, maxLat = 50, minLon = -140, maxLon = -110,
  minTime = '2020-01-01T00:00:00Z', maxTime = '2020-02-01T00:00:00Z'
)

# search many ERDDAP servers at once for the same query
servers()$url                                     # curated list of known ERDDAP servers
global_search('sea surface temperature', servers()$url[1:5], 'griddap')

# list every dataset of a given type on a server
ed_datasets('griddap')
ed_datasets('tabledap')
```

## griddap(): Gridded Data

- Every dimension argument must be length 2, even for a single value: `c(x, x)`.
- `'last'` (or any string containing it) grabs the most recent value on that dimension.
- `stride` subsamples; order follows the dimension order shown by `print(out)`.
- `fmt`: `"nc"` (default, via ncdf4), `"csv"`, or `"parquet"` (needs ERDDAP >= 2.25).
- `store`: `disk()` (default, cached on disk) or `memory()` (skip caching, return in-session).

```r
out <- info('erdVHNchlamday')

griddap(out,
  time      = c('2015-04-01', '2015-04-10'),
  latitude  = c(18, 21),
  longitude = c(-120, -119),
  fields    = 'chlorophyll'
)

# open-ended: most recent time step available
griddap(out, time = c('last', 'last'), latitude = c(18, 21), longitude = c(-120, -119))

# subsample: stride order matches the dims listed in print(out)
griddap(out,
  time = c('2015-04-01', '2015-04-30'), latitude = c(18, 30), longitude = c(-130, -110),
  stride = c(2, 4, 4)
)

# read into memory instead of caching to disk
griddap(out, time = c('2015-04-01', '2015-04-10'), latitude = c(18, 21),
  longitude = c(-120, -119), store = memory())
```

## tabledap(): Tabular Data

- Query constraints are quoted strings, operator inline: `'field OP value'`, `OP` one of `=`, `!=`, `=~` (regex), `<`, `<=`, `>`, `>=`.
- `fields` selects columns to return.
- `distinct`, `orderby`, `orderbymax`/`orderbymin`/`orderbyminmax` push sorting/dedup to the server.
- `units`: `'udunits'` (e.g. `degree_C`) or `'ucum'` (e.g. `Cel`).
- `fmt`: `"csv"` (default) or `"parquet"` (needs ERDDAP >= 2.25) — no `"nc"` option for tabledap.

```r
tabledap('erdCinpKfmBT',
  fields = c('longitude', 'latitude', 'Aplysia_californica_Mean_Density'),
  'time>=2006-08-24'
)

# regex constraint
tabledap('erdCinpKfmT', 'station=~"^N.*"')

# server-side sort + dedupe
tabledap('sg114_3', fields = c('longitude', 'latitude', 'trajectory'),
  'time>=2008-12-05', distinct = TRUE)
```

**Wrong pattern:** writing constraints as separate `key =` arguments (`tabledap(id, time = '2020-01-01')`) — that's not how tabledap takes constraints. Pass them as quoted strings in `...`: `tabledap(id, 'time>=2020-01-01')`.

## Before You Download: estimate_griddap_size()

Wide time/space `griddap()` requests can be many GB and blow past ERDDAP server limits. `estimate_griddap_size()` uses only `info()` metadata — no network request — to estimate point counts and bytes per variable before you fetch anything.

```r
out <- info('erdMH1chla8day')
estimate_griddap_size(out,
  latitude  = c(30, 50),
  longitude = c(-140, -110),
  time      = c('2020-01-01', '2020-12-31')
)
# prints a per-dimension breakdown (points, stride, spacing source) and total
# bytes per requested variable; returns the same info invisibly for scripting
```

If a dimension's spacing can't be inferred from the dataset's metadata, it warns and assumes 1 point for that dimension — override with `spacing = list(<dim> = <value>)` (use `time_sec` for the time dimension).

## Caching

`griddap()`/`tabledap()` results are cached to disk by default, keyed by an MD5 hash of the full request URL — an identical call in a later session reads from disk instead of re-hitting the server.

```r
cache_setup(temp_dir = TRUE)   # use a session-only temp cache (skips interactive path prompt)
cache_info()                   # cache path + file count
cache_list()                   # nc & csv files currently in cache
cache_details(chl)             # size + summary for one cached result (or cache_details() for all)
cache_delete(chl)              # delete the file(s) behind one griddap()/tabledap() result
cache_delete_all()             # wipe the whole cache
```

Don't hand-roll your own caching layer around rerddap calls — repeated identical requests are already free after the first fetch.

## Non-Default ERDDAP Servers

Every function takes a `url` argument (default `eurl()`, NOAA's CoastWatch/PolarWatch ERDDAP). Point at any other ERDDAP server the same way:

```r
servers()                                       # data.frame of known public ERDDAP servers
ed_search('temperature', url = 'http://erddap.marine.ie/erddap/')
info('IMI_CONN_2D', url = 'http://erddap.marine.ie/erddap/')

# set a session/project-wide default instead of passing url= everywhere
Sys.setenv(RERDDAP_DEFAULT_URL = 'https://coastwatch.pfeg.noaa.gov/erddap/')
eurl()   # reflects the env var once set
```

## Output Objects

- `info()` → class `info`: `list(variables, alldata, base_url)`, `print.info` shows dims/vars.
- `griddap()` → class `griddap_nc` / `griddap_csv` / `griddap_parquet`; attrs `datasetid`, `path`, `url`. For parquet, the return value is `list(summary, data)`.
- `tabledap()` → class `tabledap` (a `data.frame` subclass); attrs `datasetid`, `path`, `url`, `units`.

```r
attr(chl, 'datasetid'); attr(chl, 'path'); attr(chl, 'url')   # metadata lives in attributes
browse(chl)                                                    # open the dataset's ERDDAP info page
```

## Conversion Helpers

```r
convert_time(n = 473472000)                       # unix seconds -> ISO 8601 string
convert_time(isoTime = '1985-01-02T00:00:00Z')    # validate/normalize an ISO 8601 string
convert_time(n = 473472000, method = 'web')        # same, via the ERDDAP server's own converter

convert_units(udunits = 'degree_C meter-1')        # UDUNITS -> UCUM
convert_units(ucum = 'Cel.m-1')                    # UCUM -> UDUNITS

fipscounty(code = '06053')                         # FIPS code -> county name
fipscounty(county = 'CA, Monterey')                # county name -> FIPS code

key_words(cf = 'air_pressure')                     # CF standard name -> GCMD science keyword
```

## Common Mistakes

| Mistake | Fix |
|---|---|
| Calling `griddap()`/`tabledap()` with dimension names/ranges guessed instead of read from `info()` | Always `print(out)` or inspect `out$alldata` first |
| Dimension arg of length 1, e.g. `time = '2020-01-01'` | All dims are length-2: `c('2020-01-01', '2020-01-01')` for a single value |
| tabledap constraint written as a named argument, `time = '>=2020-01-01'` | Constraints are quoted strings in `...`: `'time>=2020-01-01'` |
| Large `griddap()` bounding box / time range with `stride = 1` | Run `estimate_griddap_size()` first, or set `stride` to subsample |
| Assuming `fmt = 'parquet'` always works | Requires ERDDAP >= 2.25 on that server; both functions `stop()` otherwise |
| Re-running an identical expensive request every session expecting it to hit the network | It's already disk-cached by URL+args hash; check `cache_list()`/`cache_info()` before assuming otherwise |

## Quick Reference

| Task | Function |
|---|---|
| Dataset metadata (dims, vars, ranges) | `info()` |
| Search by keyword | `ed_search()` |
| Search by bounding box / time / protocol / institution | `ed_search_adv()` |
| Search many ERDDAP servers at once | `global_search()` |
| List all datasets of a type on a server | `ed_datasets()` |
| List known ERDDAP servers | `servers()` |
| Fetch gridded data | `griddap()` |
| Fetch tabular data | `tabledap()` |
| Estimate download size before fetching | `estimate_griddap_size()` |
| Open a dataset's info page in the browser | `browse()` |
| Cache management | `cache_setup()`, `cache_info()`, `cache_list()`, `cache_details()`, `cache_delete()`, `cache_delete_all()` |
| Time conversion | `convert_time()` |
| Units conversion (UDUNITS <-> UCUM) | `convert_units()` |
| FIPS county code <-> name | `fipscounty()` |
| CF standard name -> GCMD keyword | `key_words()` |
| Default/custom server URL | `eurl()`, `Sys.setenv(RERDDAP_DEFAULT_URL = ...)` |
