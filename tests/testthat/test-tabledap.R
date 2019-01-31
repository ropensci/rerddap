context("tabledap")

test_that("tabledap returns the correct stuff", {
  vcr::use_cassette("tabledap_memory", {
    a <- tabledap('erdCinpKfmBT', store = memory())
    b <- tabledap('erdCinpKfmBT', 'time>=2007-06-24', 'time<=2007-07-01', store = memory())
  })

  # class
  expect_is(a, "tabledap")
  expect_is(a, "data.frame")
  expect_is(a$Haliotis_rufescens_Mean_Density, "character")

  # dimensions
  expect_gt(NCOL(a), 20)
  expect_gt(NCOL(b), 20)

  vcr::use_cassette("tabledap_disk", {
    a <- tabledap('erdCinpKfmBT', store = disk(path = 'fixtures/'))
    b <- tabledap('erdCinpKfmBT', 'time>=2007-06-24', 'time<=2007-07-01', store = disk('fixtures/'))
  })

  # class
  expect_is(a, "tabledap")
  expect_is(a, "data.frame")
  expect_is(a$Haliotis_rufescens_Mean_Density, "character")

  # dimensions
  expect_gt(NCOL(a), 20)
  expect_gt(NCOL(b), 20)
})

test_that("tabledap fields parameter works", {
  vcr::use_cassette("tabledap_fields_parameter", {
    d <- tabledap('erdCinpKfmBT', fields = c('longitude','latitude','Haliotis_fulgens_Mean_Density'),
                  'time>=2001-07-14', store = disk('fixtures/'))
  })

  expect_is(d, "tabledap")
})

test_that("tabledap fields parameter fails correctly", {
  vcr::use_cassette("tabledap_fields_fails_well", {
    expect_error(tabledap('erdCalCOFIlrvcntHBtoHI', fields = 'stuff',
                          'time>=2001-07-14', store = memory()), 
    "Unrecognized variable")
  })
})

test_that("tabledap units parameter works", {
  vcr::use_cassette("tabledap_units_parameter", {
    e <- tabledap('erdCinpKfmBT', fields = c('longitude','latitude','Haliotis_fulgens_Mean_Density'),
                  'time>=2001-07-14', units = 'udunits', store = disk("fixtures/"))
  })
  
  expect_is(e, "tabledap")
})

test_that("tabledap units parameter fails correctly", {
  vcr::use_cassette("tabledap_units_fails_well", {
    expect_error(
      tabledap('erdCinpKfmBT', 'time>=2001-07-14', units = "stuff", store = memory()),
      "toUnits=UDUNITS must be UDUNITS or UCUM"
    )
  })
})

test_that("tabledap fails well on common mistakes", {
  # failures that do HTTP requests
  vcr::use_cassette("tabledap_fails_well", {
    expect_error(tabledap('hawaii_b55f_a8f2_ad70', "stuff=>things", store = memory()), 
      "HTTP Status 404 – Not Found")
    expect_error(tabledap('erdCinpKfmBT', fields = "bbbbb", store = memory()), 
      "Unrecognized variable=\"bbbbb\"")
    expect_error(tabledap('erdCinpKfmBT', orderby = "things", store = memory()), 
      "'orderBy' variable=things isn't in the dataset")
  })

  # failures that do not do HTTP requests
  skip_on_cran()

  expect_error(tabledap(), "argument \"x\" is missing")
  expect_error(tabledap('erdCinpKfmBT', distinct = "bear"), "not interpretable as logical")
})

# unlink(cache_info()$path, recursive = TRUE)
