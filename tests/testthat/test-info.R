context("info")

test_that("info returns the correct", {
   vcr::use_cassette("info", {
    a <- info('erdRWtanm1day')
    #b <- info('noaa_gfdl_31d5_ca95_1287')
    d <- info('erdMBchlamday_LonPM180')
    e <- info('erdMBchla1day')
    f <- info('nodcWoa09mon5t')

    # class
    expect_is(a, "info")
    #expect_is(b, "info")
    expect_is(d, "info")
    expect_is(e, "info")
    expect_is(f, "info")

    expect_is(a$variables, "data.frame")
    expect_is(a$alldata, "list")
    expect_is(a$alldata$NC_GLOBAL, "data.frame")
    expect_is(a$alldata$sstAnomaly, "data.frame")

    #expect_is(b$alldata$clivi, "data.frame")
    expect_is(d$alldata$chlorophyll, "data.frame")
    expect_is(e$alldata$time, "data.frame")
    expect_is(f$alldata$depth, "data.frame")

    # dimensions
    expect_equal(length(a), 2)
    expect_equal(NCOL(a$variables), 3)
  })
})

test_that("info works with different ERDDAP servers", {
  vcr::use_cassette("info_diff_servers", {
    h <- info("IMI_CONN_2D", url = "http://erddap.marine.ie/erddap/")

    expect_is(h, "info")
    expect_is(h$variables, "data.frame")
    expect_is(h$alldata, "list")
  })
})

test_that("info fails well", {
  skip_on_cran()

  expect_error(info(), "is missing, with no default")
  expect_error(info("stuff"), "Not Found")
})
