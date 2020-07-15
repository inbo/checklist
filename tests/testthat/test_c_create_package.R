test_that("create_package() works", {
  maintainer <- person(
    given = "Thierry",
    family = "Onkelinx",
    role = c("aut", "cre"),
    email = "thierry.onkelinx@inbo.be",
    comment = c(ORCID = "0000-0001-8804-4216")
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
