context("disk")

skip_on_cran()

test_that("disk works", {
  expect_is(disk(), "list")
  expect_is(disk()$store, "character")
  expect_equal(disk()$store, "disk")
  expect_is(disk()$path, "character")
  expect_match(disk()$path, "rerddap")
  expect_true(disk()$overwrite)

  #unlink(cache_info()$path, recursive = TRUE)
})
