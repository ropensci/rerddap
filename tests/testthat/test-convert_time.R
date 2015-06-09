context("convert_time")

test_that("convert_time works", {
  skip_on_cran()

  a <- convert_time(n = 473472000)
  a_web <- convert_time(n = 473472000, method = "web")
  b <- convert_time(isoTime = "1985-01-02T00:00:00Z")
  b_web <- convert_time(isoTime = "1985-01-02T00:00:00Z", method = "web")

  expect_is(a, "character")
  expect_is(b, "character")
  expect_is(a_web, "character")
  expect_is(b_web, "character")
  expect_equal(b_web, "473472000")
})

test_that("convert_time fails well", {
  skip_on_cran()

  expect_error(convert_time(), "One of n or isoTime must be non-NULL")
  expect_error(convert_time(4, 5), "is not TRUE")
  expect_error(convert_time(473472000, "B"), "Supply only one of n or isoTime")
})
