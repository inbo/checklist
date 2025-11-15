library(mockery)
test_that("author tools", {
  stub(ask_orcid, "readline", mock(""))
  expect_equal(ask_orcid(), "")
  stub(ask_orcid, "readline", mock("junk", "0000-0002-1825-0097"))
  expect_equal(suppressMessages(ask_orcid()), "0000-0002-1825-0097")

  root <- file.path(config_dir, "data")
  expect_false(is_dir(root))
  expect_is(stored_authors(root), "data.frame")
  expect_true(is_dir(root))
  expect_is(stored_authors(root), "data.frame")

  stub(org_list_from_url, "R_user_dir", mock_r_user_dir(config_dir))
  org <- org_list_from_url("https://gitlab.com/thierryo/checklist.git")
  stub(new_author, "readline", mock("John", "Doe", "", ""))
  stub(new_author, "ask_orcid", "")
  expect_output(new_author(current = data.frame(), root = root, org = org))
  expect_true(file_exists(path(root, "author.txt")))
  current <- stored_authors(root)

  stub(author2person, "R_user_dir", mock_r_user_dir(config_dir), depth = 2)
  expect_s3_class(author2person(), "person")

  stub(update_author, "menu", mock(4, 6))
  stub(update_author, "readline", "0000-0002-1825-0097", depth = 2)
  expect_output(
    update_author(current = current, selected = 1, root = root, org = org)
  )
  current$orcid <- "0000-0002-1825-0097"
  expect_identical(current, stored_authors(root))

  stub(update_author, "menu", mock(5, 6))
  stub(
    update_author,
    "readline",
    names(org$get_name_by_domain("info@organisation.checklist", "fr-FR")),
    depth = 2
  )
  expect_output(
    update_author(
      current = current,
      selected = 1,
      root = root,
      org = org,
      lang = "fr-FR"
    )
  )
  current$affiliation <- names(org$get_name_by_domain(
    "organisation.checklist",
    "fr-FR"
  ))
  expect_identical(current, stored_authors(root))
  expect_is(author2person(), "person")

  stub(update_author, "menu", mock(3, 6))
  stub(update_author, "readline", "noreply@organisation.checklist", depth = 2)
  expect_output(
    update_author(
      current = current,
      selected = 1,
      root = root,
      org = org,
      lang = "fr-FR"
    )
  )
  current$email <- "noreply@organisation.checklist"
  expect_identical(current, stored_authors(root))
  expect_is(ap <- author2person(lang = "en-GB"), "person")

  expect_null(coalesce(NULL))
  expect_identical(coalesce(NULL, "a"), "a")
  expect_identical(coalesce(NULL, "a", "b"), "a")
  expect_identical(coalesce("a", NULL, "b"), "a")

  stub(
    new_author,
    "readline",
    mock("Jane", "Doe", "noreply@organisation.checklist")
  )
  stub(new_author, "ask_orcid", mock("", "0000-0002-1825-0097"))
  expect_output(new_author(current, root = root, org = org, lang = "en-GB"))

  stub(use_author, "R_user_dir", mock_r_user_dir(config_dir))
  zenodo_out <- tempfile(fileext = ".txt")
  defer(file_delete(zenodo_out))
  sink(zenodo_out)
  expect_s3_class(
    x <- use_author("noreply@organisation.checklist", lang = "en-GB"),
    "data.frame"
  )
  sink()
  expect_equal(x$given, "Jane")
  expect_equal(x$family, "Doe")

  badge <- "Doe, John[^aut]"
  attr(badge, "footnote") <- "[^aut]: author"
  expect_equal(
    data.frame(
      given = "John",
      family = "Doe",
      orcid = "",
      affiliation = "",
      email = ""
    ) |>
      author2badge(),
    badge
  )

  badge <- "INBO[^cph][^fnd]"
  attr(badge, "footnote") <- c("[^cph]: copyrightholder", "[^fnd]: funder")
  expect_equal(
    data.frame(
      given = "INBO",
      family = "",
      orcid = "",
      affiliation = "",
      email = ""
    ) |>
      author2badge(role = c("cph", "fnd")),
    badge
  )

  badge <- paste0(
    "[Doe, John![ORCID logo](https://info.orcid.org/wp-content/uploads/2019/",
    "11/orcid_16x16.png)](https://orcid.org/0000-0002-1825-0097)[^ctb]"
  )
  attr(badge, "footnote") <- "[^ctb]: contributor"
  expect_equal(
    data.frame(
      family = "Doe",
      given = "John",
      orcid = "0000-0002-1825-0097",
      affiliation = ""
    ) |>
      author2badge(role = "ctb"),
    badge
  )

  stub(org_list_from_url, "R_user_dir", mock_r_user_dir(config_dir))
  org <- org_list_from_url("https://github.com/inbo/checklist.git")
  current <- stored_authors(root)
  stub(new_author, "readline", mock("Ned", "Flanders", "ned@vlaanderen.be"))
  stub(new_author, "ask_orcid", "")
  expect_output(new_author(
    current = current,
    root = root,
    org = org,
    lang = "nl-BE"
  ))
})
