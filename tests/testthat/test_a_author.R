library(mockery)
test_that("author tools", {
  stub(ask_orcid, "readline", mock(""))
  expect_equal(ask_orcid(), "")
  stub(ask_orcid, "readline", mock("junk", "0000-0002-1825-0097"))
  expect_equal(suppressMessages(ask_orcid()), "0000-0002-1825-0097")

  root <- tempfile("author")
  expect_false(is_dir(root))
  expect_is(stored_authors(root), "data.frame")
  expect_true(is_dir(root))
  expect_is(stored_authors(root), "data.frame")
  stub(new_author, "readline", mock("John", "Doe", "", ""))
  stub(new_author, "ask_orcid", "")
  org <- read_organisation()
  expect_output(new_author(current = data.frame(), root = root, org = org))
  expect_true(file_exists(path(root, "author.txt")))
  current <- stored_authors(root)

  stub(update_author, "interactive", TRUE)
  stub(update_author, "menu", 7)
  expect_output(
    update_author(current = current, selected = 1, root = root, org = org)
  )
  expect_identical(current, stored_authors(root))

  stub(author2person, "R_user_dir", root, depth = 2)
  expect_output({
    ap <- author2person()
  })
  expect_is(ap, "person")

  stub(author2badge, "R_user_dir", root, depth = 2)
  badge <- "Doe, John[^aut]"
  attr(badge, "footnote") <- "[^aut]: author"
  expect_output({
    ab <- author2badge(org = read_organisation())
  })
  expect_equal(ab, badge)

  stub(update_author, "menu", mock(4, 6))
  stub(update_author, "readline", "0000-0002-1825-0097", depth = 2)
  expect_output(
    update_author(
      current = current,
      selected = 1,
      root = root,
      org = read_organisation()
    )
  )
  current$orcid <- "0000-0002-1825-0097"
  expect_identical(current, stored_authors(root))
  badge <- paste0(
    "[Doe, John![ORCID logo](https://info.orcid.org/wp-content/uploads/2019/",
    "11/orcid_16x16.png)](https://orcid.org/0000-0002-1825-0097)[^aut]"
  )
  attr(badge, "footnote") <- "[^aut]: author"
  expect_output({
    ab <- author2badge(org = org)
  })
  expect_equal(ab, badge)

  stub(update_author, "menu", mock(5, 6))
  stub(
    update_author,
    "readline",
    org$get_organisation[["inbo.be"]]$affiliation[1],
    depth = 2
  )
  expect_output(
    update_author(current = current, selected = 1, root = root, org = org)
  )
  current$affiliation <- org$get_organisation[["inbo.be"]]$affiliation[1]
  expect_identical(current, stored_authors(root))
  badge <- paste0(
    "[Doe, John![ORCID logo](https://info.orcid.org/wp-content/uploads/2019/",
    "11/orcid_16x16.png)]",
    "(https://orcid.org/0000-0002-1825-0097)[^aut][^inbo.be]"
  )
  attr(badge, "footnote") <- c(
    "[^aut]: author",
    paste("[^inbo.be]:", org$get_organisation[["inbo.be"]]$affiliation[1])
  )
  expect_output({
    ab <- author2badge(org = org)
  })
  expect_equal(ab, badge)
  expect_output({
    ap <- author2person()
  })
  expect_is(ap, "person")

  stub(update_author, "menu", mock(3, 6))
  stub(update_author, "readline", "noreply@inbo.be", depth = 2)
  expect_output(
    update_author(current = current, selected = 1, root = root, org = org)
  )
  current$email <- "noreply@inbo.be"
  expect_identical(current, stored_authors(root))
  expect_output({
    ap <- author2person()
  })
  expect_is(ap, "person")

  expect_null(coalesce(NULL))
  expect_identical(coalesce(NULL, "a"), "a")
  expect_identical(coalesce(NULL, "a", "b"), "a")
  expect_identical(coalesce("a", NULL, "b"), "a")

  stub(new_author, "readline", mock("Jane", "Doe", "noreply@inbo.be"))
  stub(new_author, "ask_orcid", mock("", "0000-0002-1825-0097"))
  expect_output(new_author(current, root = root, org = org))

  stub(use_author, "R_user_dir", root)
  zenodo_out <- tempfile(fileext = ".txt")
  defer(file_delete(zenodo_out))
  sink(zenodo_out)
  expect_s3_class(x <- use_author("noreply@inbo.be"), "data.frame")
  sink()
  expect_equal(x$given, "Jane")
  expect_equal(x$family, "Doe")
})
