test_that("validate_email() works", {
  expect_false(
    any(
      validate_email(c("a", "a@a", "a@a. a", "a a@a"))
    )
  )
  expect_true(
    all(
      validate_email(c("a@a.a", "a.a@a.a", "_a@a.a", "a@a.a.a"))
    )
  )
})

test_that("checklist print error works", {
  expect_match(checklist_format_error(c(junk = "test")), "junk: 1 error.*test")
})
