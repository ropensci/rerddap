context("disk")

test_that("disk works", {
  skip_on_cran()

  expect_is(disk(), "list")
  expect_is(disk()$store, "character")
  expect_equal(disk()$store, "disk")
  expect_is(disk()$path, "character")
  expect_equal(disk()$path, "~/.rerddap")
  expect_true(disk()$overwrite)
})
