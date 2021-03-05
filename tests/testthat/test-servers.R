context("servers")

skip_on_cran()

test_that("servers", {
  vcr::use_cassette("servers", {
    aa <- servers()
  })

  expect_is(aa, "data.frame")
  expect_is(aa, "tbl")
  expect_is(aa$public, "logical")
})
