context("convert_units")

test_that("convert_units works", {
  skip_on_cran()

  a <- convert_units(udunits = "degree_C meter-1")
  b <- convert_units(ucum = "Cel.m-1")

  expect_is(a, "character")
  expect_equal(a, "Cel.m-1")

  expect_is(b, "character")
  expect_equal(b, "degree_C m-1")

  expect_equal(convert_units(udunits = "degC"), "Cel")
  expect_equal(convert_units(ucum = "Cel"), "degree_C")
  expect_equal(convert_units(udunits = "degF"), "[degF]")
  expect_equal(convert_units(ucum = "[degF]"), "degree_F")
  expect_equal(convert_units(udunits = "sec"), "s")
  expect_equal(convert_units(ucum = "s"), "s")
  expect_equal(convert_units(udunits = "day"), "d")
  expect_equal(convert_units(ucum = "d"), "day")

  # nonsense apparently gets returned as itself, oh well
  expect_equal(convert_units("gggg"), "gggg")
})

test_that("convert_units fails well", {
  skip_on_cran()

  expect_error(convert_units(), "One of udunits or ucum must be non-NULL")
  expect_error(convert_units(udunits = "sec", ucum = "sec"), "Supply only one of udunits or ucum")
})
