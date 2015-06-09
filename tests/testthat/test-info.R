context("info")

a <- info('noaa_esrl_027d_0fb5_5d38')
b <- info('noaa_gfdl_31d5_ca95_1287')
d <- info('noaa_esrl_5ee0_7c46_db68')
e <- info('noaa_esrl_c028_2e8a_9caf')
f <- info('nodcWoa09mon5t')

test_that("info returns the correct class", {
  expect_is(a, "info")
  expect_is(b, "info")
  expect_is(d, "info")
  expect_is(e, "info")
  expect_is(f, "info")

  expect_is(a$variables, "data.frame")
  expect_is(a$alldata, "list")
  expect_is(a$alldata$NC_GLOBAL, "data.frame")
  expect_is(a$alldata$air, "data.frame")

  expect_is(b$alldata$clivi, "data.frame")
  expect_is(d$alldata$air, "data.frame")
  expect_is(e$alldata$time, "data.frame")
  expect_is(f$alldata$depth, "data.frame")
})

test_that("info returns the correct dimensions", {
  expect_equal(length(a), 2)
  expect_equal(NCOL(a$variables), 3)
})

test_that("info works with different ERDDAP servers", {
  h <- info("erdMH1kd4908day", url = "https://bluehub.jrc.ec.europa.eu/erddap/")

  expect_is(h, "info")
  expect_is(h$variables, "data.frame")
  expect_is(h$alldata, "list")
})

test_that("info fails well", {
  expect_error(info(), "is missing, with no default")
  expect_error(info("stuff"), "Not Found")
})
