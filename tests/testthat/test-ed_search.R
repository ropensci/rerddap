context("ed_search")

test_that("ed_search returns the correct", {
  skip_on_cran()

  a <- ed_search(query = 'temperature')
  b <- ed_search(query = 'size')

  # class
  expect_is(a, "ed_search")
  expect_is(a$info, "data.frame")
  expect_is(a$alldata, "list")

  # dimensions
  expect_equal(length(a), 2)
  expect_equal(NCOL(a$info), 2)
  expect_equal(length(b), 2)
  expect_equal(NCOL(b$info), 2)
})

test_that("ed_search works with different ERDDAP servers", {
  skip_on_cran()

  #' ## Marine Domain Awareness (MDA) (Italy)
  d <- ed_search("temperature", url = "https://bluehub.jrc.ec.europa.eu/erddap/")
  ## Marine Institute (Ireland)
  e <- ed_search("temperature", url = "http://erddap.marine.ie/erddap/")

  expect_is(d, "ed_search")
  expect_is(d$info, "data.frame")
  expect_is(d$alldata, "list")

  expect_is(e, "ed_search")
  expect_is(e$info, "data.frame")
  expect_is(e$alldata, "list")
})

test_that("ed_search correctly catches invalid parameter types", {
  skip_on_cran()

  expect_error(ed_search(query = "temperature", page = "things"), "page not of class numeric")
  expect_error(ed_search(query = "temperature", page_size = "adf"), "page_size not of class numeric")
})

test_that("ed_search fails well", {
  skip_on_cran()

  expect_error(ed_search(), "\"query\" is missing, with no default")
  expect_error(ed_search("size", which = "stuff"), "should be one of")
})
