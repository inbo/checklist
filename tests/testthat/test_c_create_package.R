library(mockery)
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

  expect_is({
      x <- check_package(file.path(path, package), fail = FALSE)
    },
    "Checklist"
  )

  stub(x$add_motivation, "yesno", TRUE, depth = 2)
  stub(x$add_motivation, "readline", "junk", depth = 2)
  expect_is(
    x$add_motivation(which = "notes"),
    "Checklist"
  )
  expect_length(x$.__enclos_env__$private$allowed_notes, 2)

  stub(x$confirm_motivation, "yesno", TRUE, depth = 2)
  expect_is(
    x$confirm_motivation(which = "notes"),
    "Checklist"
  )
  expect_length(x$.__enclos_env__$private$allowed_notes, 2)

  stub(write_checklist, "x$add_motivation", NULL)
  stub(write_checklist, "x$confirm_motivation", NULL)
  old_checklist <- read_checklist(file.path(path, package))
  expect_invisible(write_checklist(x))
  expect_false(
    identical(
      old_checklist$.__enclos_env__$private$allowed_notes,
      x$.__enclos_env__$private$allowed_notes
    )
  )

  stub(x$confirm_motivation, "yesno", FALSE, depth = 2)
  expect_is(
    x$confirm_motivation(which = "notes"),
    "Checklist"
  )
  expect_length(x$.__enclos_env__$private$allowed_notes, 0)

  unlink(path, recursive = TRUE)
})
