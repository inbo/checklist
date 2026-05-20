library(mockery)
test_that("ask_rightsholder_funder", {
  stub(org_list_from_url, "R_user_dir", mock_r_user_dir(config_dir))
  org <- org_list_from_url("https://gitlab.com/thierryo/checklist.git")
  expect_type(
    x <- ask_rightsholder_funder(org = org, type = "rightsholder"),
    "list"
  )
  expect_equal(names(x), c("selection", "org"))
  expect_equal(x$org, org)

  stub(ask_rightsholder_funder, "ask_yes_no", mock(TRUE, FALSE))
  expect_type(
    x <- ask_rightsholder_funder(org = org, type = "rightsholder"),
    "list"
  )
  expect_equal(names(x), c("selection", "org"))
  expect_equal(x$org, org)

  stub(ask_rightsholder_funder, "ask_yes_no", mock(TRUE, FALSE))
  stub(ask_rightsholder_funder, "menu_first", 3L)
  stub(
    ask_rightsholder_funder,
    "new_org_item",
    citeme::org_item$new(
      email = "somewhere@over-the-rainbow.org",
      name = c(`en-GB` = "Over the Rainbow")
    )
  )
  expect_type(
    x <- ask_rightsholder_funder(org = org, type = "rightsholder"),
    "list"
  )
  expect_equal(names(x), c("selection", "org"))
  expect_equal(x$org, org)
})
