context("ed_datasets")

skip_on_cran()

test_that("ed_datasets returns the correct", {
  vcr::use_cassette("ed_datasets_table", {
    a <- ed_datasets('table')
  })
  
  expect_is(a, "data.frame")
  expect_is(a$griddap, "character")
  expect_lt(NCOL(a), 50)

  vcr::use_cassette("ed_datasets_grid", {
    b <- ed_datasets('grid')
  })
    
  expect_is(b, "data.frame")
  expect_is(b$Institution, "character")
  expect_lt(NCOL(b), 50)
})

test_that("ed_datasets fails well", {
  expect_error(ed_datasets("stuff"), "should be one of")
})
