test_that("orcid2person() works", {
  expect_error(orcid2person(orcid = "zzzz-0000-0000-0000"), class = "http_404")
  expect_error(orcid2person(orcid = "0000-0001-8804-4216"), "No public email")
  expect_identical(
    orcid2person(
      orcid = "0000-0001-8804-4216", email = "Thierry.Onkelinx@INBO.be"
    ),
    person(
      given = "Thierry",
      family = "Onkelinx",
      role = c("aut", "cre"),
      email = "thierry.onkelinx@inbo.be",
      comment = c(ORCID = "0000-0001-8804-4216")
    )
  )
  expect_identical(
    orcid2person(
      orcid = "0000-0001-8804-4216",
      email = "Thierry.Onkelinx@INBO.be",
      role = "ctb"
    ),
    person(
      given = "Thierry",
      family = "Onkelinx",
      role = "ctb",
      email = "thierry.onkelinx@inbo.be",
      comment = c(ORCID = "0000-0001-8804-4216")
    )
  )
})
