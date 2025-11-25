library(mockery)
test_that("new_org_item", {
  stub(new_org_list, "R_user_dir", mock_r_user_dir(config_dir), depth = 2)
  stub(new_org_list, "menu_first", mock(1, 1, 1, Inf))
  stub(new_org_list, "ask_yes_no", mock(TRUE, FALSE))
  stub(
    new_org_list,
    "new_org_item",
    org_item$new(
      name = c(`en-GB` = "Rainbow"),
      email = "info@rainbow.org",
      license = list(
        package = character(0),
        project = character(0),
        data = character(0)
      )
    )
  )
  expect_s3_class(
    oi <- new_org_list(git = "https://bitbucket.org/myorg"),
    "org_list"
  )
  expect_equal(
    oi,
    org_list$new(
      org_item$new(
        name = c(
          `nl-BE` = paste(
            "Instituut voor Landbouw-, Visserij- en Voedingsonderzoek (ILVO)"
          ),
          `en-GB` = paste(
            "Flanders Research Institute for Agriculture, Fisheries and Food",
            "(ILVO)"
          )
        ),
        email = "ilvo@ilvo.vlaanderen.be",
        website = "https://ilvo.vlaanderen.be/en",
        logo = paste0(
          "https://ilvo.vlaanderen.be/uploads/images/logo-ILVO-2016-eng.png"
        ),
        ror = "https://ror.org/05cjt1n05",
        license = list(
          package = c(
            `GPL-3.0` = paste(
              "https://raw.githubusercontent.com/inbo/checklist/refs/heads",
              "main/inst/generic_template/gplv3.md",
              sep = "/"
            ),
            MIT = paste(
              "https://raw.githubusercontent.com/inbo/checklist/refs/heads",
              "main/inst/generic_template/mit.md",
              sep = "/"
            )
          ),
          project = c(
            `CC BY 4.0` = paste(
              "https://raw.githubusercontent.com/inbo/checklist/refs/heads",
              "main/inst/generic_template/cc_by_4_0.md",
              sep = "/"
            )
          ),
          data = c(
            `CC0` = paste(
              "https://raw.githubusercontent.com/inbo/checklist",
              "131fe5829907079795533bfea767bf7df50c3cfd/inst/generic_template",
              "cc0.md",
              sep = "/"
            )
          )
        )
      ),
      org_item$new(
        name = c(`en-GB` = "Rainbow"),
        email = "info@rainbow.org",
        license = list(
          package = character(0),
          project = character(0),
          data = character(0)
        )
      ),
      git = "https://bitbucket.org/myorg"
    )
  )
})
