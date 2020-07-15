library("vcr")
vcr::vcr_configure(
  dir = "../vcr_cassettes",
  write_disk_path = "../fixtures"
)
