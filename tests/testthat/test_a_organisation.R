library(mockery)
test_that("organisation class", {
  org <- organisation$new()
  expect_output(print(org), regexp = "rightsholder")

  root <- tempdir()
  dir_create(root)
  x <- checklist$new(x = root, package = FALSE, language = "en-GB")
  write_checklist(x = x)
  expect_invisible(write_organisation(org = org, x = x))
  expect_equal(read_organisation(x), org)

  r_user_dir <- tempdir()
  dir_create(r_user_dir)
  stub(default_organisation, "R_user_dir", r_user_dir)
  expect_invisible(default_organisation(org = org))

  root2 <- tempdir()
  dir_create(root2)
  stub(read_organisation, "R_user_dir", r_user_dir)
  expect_equal(read_organisation(root2), org)
})
