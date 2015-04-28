context("disk")

test_that("disk works", {
  expect_is(disk(), "list")
  expect_is(disk()$store, "character")
  expect_equal(disk()$store, "disk")
  expect_is(disk()$path, "character")
  expect_equal(disk()$path, "~/.rerddap")
  expect_true(disk()$overwrite)
})
