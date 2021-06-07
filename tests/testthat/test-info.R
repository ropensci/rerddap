context("info")

skip_on_cran()

test_that("info returns the correct", {
   vcr::use_cassette("info", {
    a <- info('erdRWtanm1day')
    d <- info('erdMBchlamday_LonPM180')
    e <- info('erdMBchla1day')
    # f <- info('nodcWoa09mon5t')
  })

  # class
  expect_is(a, "info")
  expect_is(d, "info")
  expect_is(e, "info")
  # expect_is(f, "info")

  expect_is(a$base_url, "character")
  expect_match(a$base_url, "erddap")
  expect_is(a$variables, "data.frame")
  expect_is(a$alldata, "list")
  expect_is(a$alldata$NC_GLOBAL, "data.frame")
  expect_is(a$alldata$sstAnomaly, "data.frame")

  #expect_is(b$alldata$clivi, "data.frame")
  expect_is(d$alldata$chlorophyll, "data.frame")
  expect_is(e$alldata$time, "data.frame")
  # expect_is(f$alldata$depth, "data.frame")

  # dimensions
  expect_equal(length(a), 3)
  expect_equal(NCOL(a$variables), 3)
})

test_that("info works with different ERDDAP servers", {
  vcr::use_cassette("info_diff_servers", {
    h <- info("IMI_CONN_2D", url = "http://erddap.marine.ie/erddap/")
  })

  expect_is(h, "info")
  expect_is(h$variables, "data.frame")
  expect_is(h$alldata, "list")
})

test_that("info fails well", {
  expect_error(info(), "is missing, with no default")
  expect_error(info("stuff"), "Not Found")
})

test_that("resilient to user given URLs w/ & w/o trailing slash", {
  id = "ncdcOisst21Agg_LonPM180"
  a <- vcr::use_cassette("info_url_slash", {
    info(id, url = "https://coastwatch.pfeg.noaa.gov/erddap/")
  })
  b <- vcr::use_cassette("info_url_slash2", {
    info(id, url = "https://coastwatch.pfeg.noaa.gov/erddap")
  })
  expect_identical(
    a$http_interactions_$used_interactions[[1]]$request$uri,
    b$http_interactions_$used_interactions[[1]]$request$uri
  )
  expect_identical(
    a$http_interactions_$used_interactions[[2]]$request$uri,
    b$http_interactions_$used_interactions[[2]]$request$uri
  )
})
