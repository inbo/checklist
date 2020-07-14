test_that("create_package() works", {
  maintainer <- orcid2person(
    orcid = "0000-0001-8804-4216", email = "thierry.onkelinx@inbo.be"
  )
  path <- tempfile("test_package")
  package <- "junk"
  dir.create(path)
  expect_message(
    create_package(
      path = path,
      package = package,
      title = "testing the ability of checklist to create a minimal package",
      description = "A dummy package.",
      maintainer = maintainer
    ),
    regexp = sprintf("package created at `.*%s`", package)
  )
  expect_is(
    x <- check_package(file.path(path, package), fail = FALSE),
    "Checklist"
  )
  unlink(path, recursive = TRUE)
})
