test_that("the org_list class works", {
  expect_s3_class(org <- org_list$new(), "org_list")
  expect_s3_class(
    org <- org$add_item(
      org_item$new(
        name = c(`en-GB` = "The checklist corporation"),
        email = "info@checklist.corp",
        rightsholder = "single",
        funder = "single"
      )
    ),
    "org_list"
  )
  expect_output(print(org))
  expect_identical(
    org$get_allowed_licenses(),
    c(
      `GPL-3.0` = paste(
        "https://raw.githubusercontent.com/inbo/checklist/refs/heads/main",
        "inst/generic_template/gplv3.md",
        sep = "/"
      ),
      MIT = paste(
        "https://raw.githubusercontent.com/inbo/checklist/refs/heads/main",
        "inst/generic_template/mit.md",
        sep = "/"
      )
    )
  )
  expect_identical(
    org$get_person(email = "junk@domain.com", role = "aut"),
    person(email = "junk@domain.com", role = "aut")
  )
  expect_identical(
    org$get_person(email = "info@checklist.corp", lang = "nl-BE"),
    person(
      given = "The checklist corporation",
      email = "info@checklist.corp",
      role = c("cph", "fnd")
    )
  )
  expect_is(matched <- org$get_match("checklist"), "list")
  expect_identical(names(matched), c("name", "email", "match"))
  expect_identical(org$get_languages, "en-GB")
  expect_is(matched <- org$get_match("The checklist corporation"), "list")
  expect_identical(names(matched), c("name", "email", "match"))
  expect_identical(org$get_languages, "en-GB")
  expect_identical(
    names(org$get_allowed_licenses(email = "info@checklist.corp")),
    c("GPL-3.0", "MIT")
  )
  expect_identical(org$get_zenodo_by_email("info@checklist.corp"), character(0))
  expect_identical(
    org$get_name_by_domain(email = "info@checklist.corp", lang = "nl-BE"),
    c(`The checklist corporation` = FALSE)
  )

  expect_error(
    org_list$new(
      org_item$new(
        name = c(`en-GB` = "The checklist corporation"),
        email = "info@checklist.corp",
        rightsholder = "single",
        funder = "single"
      ),
      org_item$new(email = "info@inbo.be", rightsholder = "shared")
    ),
    "`single` is not compatible with `shared`"
  )

  path <- tempfile("inbo_git")
  git_init(path)
  checklist$new(x = path, language = "nl-BE") |>
    write_checklist()
  git_remote_add("https://github.com/inbo/junk", repo = path)
  expect_s3_class(org <- git_org(path), "org_list")
  gert::git_remote_remove("origin", repo = path)
  git_remote_add("https://bitbucket.com/inbo/junk", repo = path)
  expect_message(org <- git_org(path), "no local `org_list`")
})
