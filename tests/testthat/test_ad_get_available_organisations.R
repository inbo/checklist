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
        `info@vlaamsewaterweg.be` = list(`nl-BE` = "De Vlaamse Waterweg nv"),
        `info@vlm.be` = list(`nl-BE` = "Vlaamse Landmaatschappij (VLM)"),
        `info@vmm.be` = list(
          `nl-BE` = "Vlaamse Milieumaatschappij (VMM)",
          `en-GB` = "Flanders Environment Agency (VMM)"
        ),
        `natuurenbos@vlaanderen.be` = list(
          `nl-BE` = "Agentschap voor Natuur en Bos (ANB)",
          `en-GB` = "Agency for Nature & Forests (ANB)"
        ),
        `omgeving@vlaanderen.be` = list(`nl-BE` = "Department Omgeving")
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
        `ilvo@ilvo.vlaanderen.be` = "05cjt1n05",
        `info@inbo.be` = "00j54wy13",
        `info@organisation.checklist` = "",
        `info@vlaamsewaterweg.be` = "",
        `info@vlm.be` = "",
        `info@vmm.be` = "",
        `natuurenbos@vlaanderen.be` = "04wcznf70",
        `omgeving@vlaanderen.be` = ""
      ),
      website = c(
        `ilvo@ilvo.vlaanderen.be` = "https://ilvo.vlaanderen.be/en",
        `info@inbo.be` = "https://www.vlaanderen.be/inbo/en-gb",
        `info@organisation.checklist` = "",
        `info@vlaamsewaterweg.be` = "https://www.vlaamsewaterweg.be/",
        `info@vlm.be` = "https://www.vlm.be/",
        `info@vmm.be` = "https://en.vmm.vlaanderen.be/",
        `natuurenbos@vlaanderen.be` = "https://www.natuurenbos.be/",
        `omgeving@vlaanderen.be` = "https://omgeving.vlaanderen.be/"
      ),
      logo = c(
        `ilvo@ilvo.vlaanderen.be` = paste0(
          "https://ilvo.vlaanderen.be/uploads/images/logo-ILVO-2016-eng.png"
        ),
        `info@inbo.be` = paste0(
          "https://inbo.github.io/checklist/reference/figures/logo-en.png"
        ),
        `info@organisation.checklist` = "",
        `info@vlaamsewaterweg.be` = "",
        `info@vlm.be` = paste0(
          "https://www.vlm.be/nl/SiteCollectionImages/Logo/",
          "Logo's%20Vlaamse%20overheid%20en%20VLM/Sponsorlogo_VLM_kleur.jpg"
        ),
        `info@vmm.be` = "https://2016.vmm.be/assets/images/logo.svg",
        `natuurenbos@vlaanderen.be` = "",
        `omgeving@vlaanderen.be` = paste0(
          "https://omgeving.vlaanderen.be/sites/default/files/",
          "entiteitslogo-DOMG-92k2.png"
        )
      )
    )
  )
})
