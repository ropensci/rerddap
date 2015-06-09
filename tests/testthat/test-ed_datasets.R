context("ed_datasets")


test_that("ed_datasets returns the correct", {
  skip_on_cran()

  a <- ed_datasets('table')
  b <- ed_datasets('grid')

  # class
  expect_is(a, "data.frame")
  expect_is(b, "data.frame")
  expect_is(a$griddap, "character")
  expect_is(b$Institution, "character")

  # dimensions
  expect_less_than(NCOL(a), 50)
  expect_less_than(NCOL(b), 50)
})

test_that("ed_datasets fails well", {
  skip_on_cran()

  expect_error(ed_datasets("stuff"), "should be one of")
})
