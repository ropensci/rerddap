context("griddap")

test_that("griddap returns the correct class", {
  a <- griddap('noaa_esrl_027d_0fb5_5d38',
               time = c('2012-01-01', '2012-01-12'),
               latitude = c(21, 18),
               longitude = c(-80, -78)
  )

  expect_is(a, "griddap_nc")
  expect_is(unclass(a), "list")
  expect_is(a$summary, "ncdf")
  expect_is(a$summary$filename, "character")
  expect_is(a$data, "data.frame")
  expect_is(a$data$time, "character")
})

test_that("griddap fixes incorrect user inputs", {
  # wrong order of latitude
  a <- griddap('noaa_esrl_027d_0fb5_5d38',
               time = c('2012-01-01', '2012-01-30'),
               latitude = c(18, 21),
               longitude = c(-80, -78)
  )
  # wrong order of longitude
  b <- griddap('noaa_esrl_027d_0fb5_5d38',
               time = c('2012-01-01', '2012-01-30'),
               latitude = c(21, 18),
               longitude = c(-70, -80)
  )
  # wrong order of time
  c <- griddap('noaa_esrl_027d_0fb5_5d38',
               time = c('2012-02-01', '2012-01-12'),
               latitude = c(21, 18),
               longitude = c(-80, -78)
  )

  expect_is(a, "griddap_nc")
  expect_is(a$data, "data.frame")
  expect_is(b, "griddap_nc")
  expect_is(b$data, "data.frame")
  expect_is(c, "griddap_nc")
  expect_is(c$data, "data.frame")

  # wrong longitude formatting given
  expect_error(griddap('noaa_esrl_027d_0fb5_5d38',
                       time = c('2012-01-01', '2012-01-30'),
                       latitude = c(21, 18),
                       longitude = c(175, 183)), "One or both longitude values")

  # wrong latitude formatting given
  expect_error(griddap('noaa_esrl_027d_0fb5_5d38',
                       time = c('2012-01-01', '2012-01-30'),
                       latitude = c(21, -120),
                       longitude = c(-80, -78)), "One or both latitude values")
})

# # Search by dataset key
# out <- occ_search(datasetKey='7b5d6a48-f762-11e1-a439-00145eb45e9a', return='data')
#
# test_that("returns the correct class", {
#   expect_is(out, "data.frame")
# })
# test_that("returns the correct dimensions", {
#   expect_equal(dim(out), c(177,42))
# })
#
# ## Search by catalog number
# out <- occ_search(catalogNumber='PlantAndMushroom.6845144', fields='all')
#
# test_that("returns the correct class", {
#   expect_is(out, "gbif")
#   expect_is(out$meta, "list")
#   expect_is(out$data, "character")
# })
# test_that("returns the correct value", {
#   expect_true(out$meta$endOfRecords)
# })
# test_that("returns the correct dimensions", {
#   expect_equal(length(out), 4)
# })
#
# # Occurrence data: lat/long data, and associated metadata with occurrences
# out <- occ_search(taxonKey=key, return='data')
#
# test_that("returns the correct class", {
#   expect_is(out, "data.frame")
#   expect_is(out[1,1], "character")
#   expect_is(out[1,2], "integer")
# })
# test_that("returns the correct value", {
#   expect_equal(as.character(out[1,1]), "Helianthus annuus")
# })
#
# # Taxonomic hierarchy data
# out <- occ_search(taxonKey=key, limit=20, return='hier')
#
# test_that("returns the correct class", {
#   expect_is(out, "gbif")
#   expect_is(out[[1]], "data.frame")
# })
# test_that("returns the correct dimensions", {
#   expect_equal(length(out), 1)
#   expect_equal(dim(out[[1]]), c(7,3))
# })
#
#
# ######### Get occurrences for a particular eventDate
# key <- name_suggest(q='Aesculus hippocastanum')$key[1]
#
# test_that("dates work correctly", {
#   a <- occ_search(taxonKey=key, year="2013", fields=c('name','year'))
#   b <- occ_search(taxonKey=key, month="6", fields=c('name','month'))
#
#   expect_equal(a$data$year[1], 2013)
#   expect_equal(b$data$month[1], 6)
#
#   expect_is(occ_search(taxonKey=key, year="1990,1991"), "gbif")
# })
#
# test_that("make sure things that should throw errors do", {
#   # not allowed to do a range query on many variables, including contintent
#   expect_error(occ_search(taxonKey=key, continent = 'asia,oceania'))
#   # can't pass the wrong value to latitude
#   expect_error(occ_search(decimalLatitude = 334))
# })
#
# ######### Get occurrences based on depth
# test_that("returns the correct stuff", {
#   key <- name_backbone(name='Salmo salar', kingdom='animals')$speciesKey
#   expect_is(occ_search(taxonKey=key, depth="5"), "gbif")
#   expect_is(occ_search(taxonKey=key, depth=5), "gbif")
#   # does range search correctly - THROWS ERROR NOW, BUT SHOULD WORK
#   expect_error(occ_search(taxonKey=key, depth="5-10"))
# })
#
# ######### Get occurrences based on elevation
# test_that("returns the correct dimensions", {
#   key <- name_backbone(name='Puma concolor', kingdom='animals')$speciesKey
#   res <- occ_search(taxonKey=key, elevation=1000, hasCoordinate=TRUE, fields=c('name','elevation'))
#   expect_equal(names(res$data), c('name','elevation'))
# })
