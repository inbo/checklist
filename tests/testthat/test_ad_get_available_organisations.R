library(mockery)
test_that("get_available_organisations() works", {
  stub(get_available_organisations, "R_user_dir", mock_r_user_dir(config_dir))
  expect_identical(
    get_available_organisations(),
    list(
      names = list(
        `ilvo@ilvo.vlaanderen.be` = list(
          `nl-BE` = paste(
            "Instituut voor Landbouw-, Visserij- en Voedingsonderzoek (ILVO)"
          ),
          `en-GB` = paste(
            "Flanders Research Institute for Agriculture, Fisheries and Food",
            "(ILVO)"
          )
        ),
        `info@inbo.be` = list(
          `nl-BE` = "Instituut voor Natuur- en Bosonderzoek (INBO)",
          `fr-FR` = "Institut de Recherche sur la Nature et les Forêts (INBO)",
          `en-GB` = "Research Institute for Nature and Forest (INBO)",
          `de-DE` = "Institut für Natur- und Waldforschung (INBO)"
        ),
        `info@organisation.checklist` = list(
          `en-GB` = "The checklist organisation",
          `nl-BE` = "De checklist organisatie"
        ),
        `info@vlaamsewaterweg.be` = list(
          `nl-BE` = "De Vlaamse Waterweg nv"
        ),
        `info@vlm.be` = list(
          `nl-BE` = "Vlaamse Landmaatschappij (VLM)"
        ),
        `info@vmm.be` = list(
          `nl-BE` = "Vlaamse Milieumaatschappij (VMM)",
          `en-GB` = "Flanders Environment Agency (VMM)"
        ),
        `natuurenbos@vlaanderen.be` = list(
          `nl-BE` = "Agentschap voor Natuur en Bos (ANB)",
          `en-GB` = "Agency for Nature & Forests (ANB)"
        ),
        `omgeving@vlaanderen.be` = list(
          `nl-BE` = "Department Omgeving"
        )
      ),
      languages = c("de-DE", "en-GB", "fr-FR", "nl-BE"),
      licenses = c(
        `AGPL-3` = paste0(
          "https://raw.githubusercontent.com/IQAndreas/markdown-licenses/refs/",
          "heads/master/gnu-agpl-v3.0.md"
        ),
        `Apache 2.0` = paste0(
          "https://raw.githubusercontent.com/IQAndreas/markdown-licenses/refs/",
          "heads/master/apache-v2.0.md"
        ),
        `CC BY 4.0` = paste0(
          "https://raw.githubusercontent.com/inbo/checklist/refs/heads/main/",
          "inst/generic_template/cc_by_4_0.md"
        ),
        `CC BY-NC-SA 4.0` = paste0(
          "https://raw.githubusercontent.com/idleberg/",
          "Creative-Commons-Markdown/refs/heads/main/4.0/by-nc-sa.markdown"
        ),
        CC0 = paste0(
          "https://raw.githubusercontent.com/inbo/checklist/",
          "131fe5829907079795533bfea767bf7df50c3cfd/inst/generic_template/",
          "cc0.md"
        ),
        `GPL-3` = paste0(
          "https://raw.githubusercontent.com/inbo/checklist/refs/heads/main/",
          "inst/generic_template/gplv3.md"
        ),
        MIT = paste0(
          "https://raw.githubusercontent.com/inbo/checklist/refs/heads/main/",
          "inst/generic_template/mit.md"
        )
      ),
      orcid = c(
        `ilvo@ilvo.vlaanderen.be` = FALSE,
        `info@inbo.be` = TRUE,
        `info@organisation.checklist` = FALSE,
        `info@vlaamsewaterweg.be` = FALSE,
        `info@vlm.be` = FALSE,
        `info@vmm.be` = FALSE,
        `natuurenbos@vlaanderen.be` = FALSE,
        `omgeving@vlaanderen.be` = FALSE
      ),
      zenodo = c(
        `ilvo@ilvo.vlaanderen.be` = "",
        `info@inbo.be` = "inbo",
        `info@organisation.checklist` = "",
        `info@vlaamsewaterweg.be` = "",
        `info@vlm.be` = "",
        `info@vmm.be` = "",
        `natuurenbos@vlaanderen.be` = "",
        `omgeving@vlaanderen.be` = ""
      ),
      ror = c(
        `ilvo@ilvo.vlaanderen.be` = "https://ror.org/05cjt1n05",
        `info@inbo.be` = "https://ror.org/00j54wy13",
        `info@organisation.checklist` = "",
        `info@vlaamsewaterweg.be` = "",
        `info@vlm.be` = "",
        `info@vmm.be` = "",
        `natuurenbos@vlaanderen.be` = "https://ror.org/04wcznf70",
        `omgeving@vlaanderen.be` = ""
      )
    )
  )
})
