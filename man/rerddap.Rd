% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rerddap-package.r
\docType{package}
\name{rerddap}
\alias{rerddap-package}
\alias{rerddap}
\title{rerddap}
\description{
General purpose R client for ERDDAP servers
}
\section{ERDDAP info}{

NOAA's ERDDAP service holds many datasets of interest. It's built on top of
OPenDAP. You can search for datasets via
\code{\link[=ed_search]{ed_search()}}, list datasets via \code{\link[=ed_datasets]{ed_datasets()}},
get information on a single dataset via \code{\link[=info]{info()}}, then get
data you want for either tabledap type via \code{\link[=tabledap]{tabledap()}}, or
for griddap type via \code{\link[=griddap]{griddap()}}
}

\section{tabledap/griddap}{

tabledap and griddap have different interfaces to query for data, so
\code{\link[=tabledap]{tabledap()}} and \code{\link[=griddap]{griddap()}} are separated out as
separate functions even though some of the internals are the same. In
particular, with tabledap you can query on/subset all variables, whereas
with gridddap, you can only query on/subset the dimension varibles (e.g.,
latitude, longitude, altitude).
}

\section{Data size}{

With griddap data via \code{\link[=griddap]{griddap()}} you can get a lot of
data quickly. Try small searches of a dataset to start to get a sense for
the data, then you can increase the amount of data you get. See
\code{\link[=griddap]{griddap()}} for more details.
}

\section{Caching}{

\pkg{rerddap} by default caches the requests you make, so that if you happen to
make the same request again, the data is restored from the cache, rather than
having to go out and retrieve it remotely.  For most applications, this is good,
as it can speed things up when doing a lot of request in a script, and works
because in most cases an ERDDAP request is "idempotent".  This means that the
the request will always return the same thing no matter what requests came
before - it doesn't depend on state. However this is not true if the
script uses either "last" in \code{\link[=griddap]{griddap()}} or "now" in \code{\link[=tabledap]{tabledap()}} as these
will return different values as time elapses and data are added to the
datasets.  While it is desirable to have ERDDAP purely idempotent,  the
"last" and "now" constructs are very helpful for people using ERDDAP
in dashboards, webpages, regular input to models and the like, and the
benefits far outweigh the problems.  However, if you are using either "last"
or "now" in an \pkg{rerddap} based script, you want to be very careful to
clear the \pkg{rerddap} cache, otherwise the request will be viewed as the
same,  and the data from the last request, rather than the latest data,
will be returned.
}

\seealso{
Useful links:
\itemize{
  \item \url{https://docs.ropensci.org/rerddap/}
  \item \url{https://github.com/ropensci/rerddap}
  \item Report bugs at \url{https://github.com/ropensci/rerddap/issues}
}

}
\author{
\strong{Maintainer}: Roy Mendelssohn \email{roy.mendelssohn@noaa.gov} [contributor]

Authors:
\itemize{
  \item Scott Chamberlain
}

Other contributors:
\itemize{
  \item Ben Tupper [contributor]
  \item Salvador Jesús Fernández Bejarano [contributor]
}

}
\keyword{internal}
