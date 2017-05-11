context("tabledap")


test_that("tabledap returns the correct", {
  skip_on_cran()

  a <- tabledap('erdCinpKfmBT')
  b <- tabledap('erdCinpKfmBT', 'time>=2007-06-24', 'time<=2007-07-01')

  # class
  expect_is(a, "tabledap")
  expect_is(a, "data.frame")
  expect_is(a$Haliotis_rufescens_Mean_Density, "character")

  # dimensions
  expect_gt(NCOL(a), 20)
  expect_gt(NCOL(b), 20)
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
  expect_error(tabledap('erdCinpKfmBT', "stuff=>things"), "Unrecognized constraint variable=\"stuff\"")
  expect_error(tabledap('erdCinpKfmBT', fields = "bbbbb"), "Unrecognized variable=\"bbbbb\"")
  expect_error(tabledap('erdCinpKfmBT', distinct = "bear"), "not interpretable as logical")
  expect_error(tabledap('erdCinpKfmBT', orderby = "things"), "'orderBy' variable=things isn't in the dataset")
})

unlink(cache_info()$path, recursive = TRUE)
