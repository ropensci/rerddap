context("servers")

test_that("servers", {
  vcr::use_cassette("servers", {
    aa <- servers()
  })

  expect_is(aa, "data.frame")
  expect_is(aa, "tbl")
  expect_named(aa, c("name", "url", "public"))
  expect_is(aa$public, "logical")
})
