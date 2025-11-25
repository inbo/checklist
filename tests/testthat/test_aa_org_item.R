test_that("the org_item class works", {
  expect_s3_class(
    anb <- org_item$new(
      name = c(
        `nl-BE` = "Agentschap voor Natuur en Bos (ANB)",
        `en-GB` = "Agency for Nature & Forests (ANB)"
      ),
      email = "natuurenbos@vlaanderen.be",
      ror = "https://ror.org/04wcznf70",
      zenodo = "anb",
      license = list(
        package = character(0),
        project = character(0),
        data = character(0)
      )
    ),
    "org_item"
  )
  expect_identical(
    anb$as_person(role = "fnd"),
    person(
      given = "Agentschap voor Natuur en Bos (ANB)",
      email = "natuurenbos@vlaanderen.be",
      role = "fnd",
      comment = c(ROR = "https://ror.org/04wcznf70")
    )
  )
  expect_identical(
    anb$as_person(lang = "en-GB", role = "cph"),
    person(
      given = "Agency for Nature & Forests (ANB)",
      email = "natuurenbos@vlaanderen.be",
      role = "cph",
      comment = c(ROR = "https://ror.org/04wcznf70")
    )
  )
  expect_output(print(anb))
  expect_identical(
    anb$as_person(lang = "fr-FR"),
    person(
      given = "Agentschap voor Natuur en Bos (ANB)",
      email = "natuurenbos@vlaanderen.be",
      role = c("cph", "fnd"),
      comment = c(ROR = "https://ror.org/04wcznf70")
    )
  )
  expect_identical(
    anb$get_default_name,
    c(`nl-BE` = "Agentschap voor Natuur en Bos (ANB)")
  )
  expect_false(anb$get_orcid)

  expect_s3_class(
    inbo <- org_item$new(email = "info@inbo.be"),
    "org_item"
  )
  expect_identical(
    names(inbo$get_license(type = "all")),
    c("GPL-3", "MIT", "CC BY 4.0", "CC0")
  )
  expect_is(inbo_list <- inbo$as_list, "list")
  expect_identical(
    names(inbo_list),
    c(
      "name",
      "email",
      "website",
      "logo",
      "ror",
      "orcid",
      "zenodo",
      "rightsholder",
      "funder",
      "license"
    )
  )
  expect_identical(inbo$get_zenodo, "inbo")
  expect_true(inbo$get_orcid)
})
