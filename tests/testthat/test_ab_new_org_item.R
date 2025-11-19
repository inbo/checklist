library(mockery)
test_that("new_org_item", {
  stub(new_org_item, "ask_email", mock("info@org.org"))
  stub(
    new_org_item,
    "readline",
    mock("My Organization", "Mijn organisatie", "")
  )
  stub(new_org_item, "ask_language", mock("en-GB", "nl-BE"))
  stub(new_org_item, "ask_yes_no", mock(TRUE, FALSE, FALSE))
  stub(new_org_item, "ask_ror", "")
  stub(
    new_org_item,
    "ask_new_license",
    mock(character(0), character(0), character(0))
  )
  expect_s3_class(
    oi <- new_org_item(languages = character(0), licenses = character(0)),
    "org_item"
  )
  expect_equal(
    oi,
    org_item$new(
      name = c(`en-GB` = "My Organization", `nl-BE` = "Mijn organisatie"),
      email = "info@org.org",
      license = list(
        package = character(0),
        project = character(0),
        data = character(0)
      )
    )
  )
})
