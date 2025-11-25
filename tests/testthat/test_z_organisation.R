library(mockery)
test_that("organisation class", {
  expect_warning(org <- organisation$new())
  expect_output(print(org), regexp = "rightsholder")

  root <- tempdir()
  dir_create(root)
  x <- checklist$new(x = root, package = FALSE, language = "en-GB")
  write_checklist(x = x)
  expect_warning(write_organisation(org = org, x = x), "Deprecated")
  expect_warning(stored_org <- read_organisation(x), "Deprecated")
  expect_equal(stored_org, org)

  r_user_dir <- tempdir()
  dir_create(r_user_dir)
  stub(default_organisation, "R_user_dir", r_user_dir)
  expect_warning(default_organisation(org = org), "deprecated")

  root2 <- tempdir()
  dir_create(root2)
  stub(read_organisation, "R_user_dir", r_user_dir)
  expect_warning(stored_org <- read_organisation(root2), "Deprecated")
  expect_equal(stored_org, org)
})
