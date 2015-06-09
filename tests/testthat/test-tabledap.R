context("tabledap")


test_that("tabledap returns the correct", {
  skip_on_cran()

  a <- tabledap('erdCalCOFIfshsiz')
  b <- tabledap('erdCalCOFIfshsiz', 'time>=2001-07-07', 'time<=2001-07-08')

  # class
  expect_is(a, "tabledap")
  expect_is(a, "data.frame")
  expect_is(a$ship, "character")

  # dimensions
  expect_equal(NCOL(a), 24)
  expect_equal(NCOL(b), 24)
})

test_that("tabledap fields parameter works, and fails correctly", {
  skip_on_cran()

  d <- tabledap('erdCinpKfmT', fields = c('longitude','latitude','time','temperature'),
                'time>=2007-09-19', 'time<=2007-09-21')

  expect_is(d, "tabledap")
  expect_error(tabledap('erdCinpKfmT', fields = 'stuff',
                        'time>=2007-09-19', 'time<=2007-09-21'), "Unrecognized variable=\"stuff\"")
})

test_that("tabledap units parameter works, and fails correctly", {
  skip_on_cran()

  e <- tabledap('erdCinpKfmT', fields = c('longitude','latitude','time','temperature'),
                'time>=2007-09-19', 'time<=2007-09-21', units = 'udunits')

  expect_is(e, "tabledap")
  expect_error(tabledap('erdCinpKfmT', fields = 'stuff',
                        'time>=2007-09-19', 'time<=2007-09-21', units = "stuff"),
               "toUnits=UDUNITS must be UDUNITS or UCUM")
})

test_that("tabledap fails well, in addition to above failure tests", {
  skip_on_cran()

  expect_error(tabledap(), "argument \"x\" is missing")
  expect_error(tabledap('erdCalCOFIfshsiz', "stuff=>things"), "Unrecognized constraint variable=\"stuff\"")
  expect_error(tabledap('erdCalCOFIfshsiz', fields = "bbbbb"), "Unrecognized variable=bbbbb")
  expect_error(tabledap('erdCalCOFIfshsiz', distinct = "bear"), "not interpretable as logical")
  expect_error(tabledap('erdCalCOFIfshsiz', orderby = "things"), "'orderBy' variable=things isn't in the dataset")
})
