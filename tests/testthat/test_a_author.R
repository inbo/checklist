library(mockery)
test_that("author tools", {
  root <- tempfile("author")
  expect_false(is_dir(root))
  expect_is(stored_authors(root), "data.frame")
  expect_true(is_dir(root))
  expect_is(stored_authors(root), "data.frame")
  stub(new_author, "readline", mock("John", "Doe", "", "", ""))
  expect_output(new_author(current = data.frame(), root = root))
  expect_true(file_exists(path(root, "author.txt")))
  current <- stored_authors(root)

  stub(update_author, "interactive", TRUE)
  stub(update_author, "menu", 7)
  expect_output(update_author(current = current, selected = 1, root = root))
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
    ab <- author2badge()
  })
  expect_equal(ab, badge)

  stub(update_author, "menu", mock(4, 6))
  stub(update_author, "readline", "0000-0002-1825-0097", depth = 2)
  expect_output(update_author(current = current, selected = 1, root = root))
  current$orcid <- "0000-0002-1825-0097"
  expect_identical(current, stored_authors(root))
  badge <- paste0(
    "[Doe, John![ORCID logo](https://info.orcid.org/wp-content/uploads/2019/",
    "11/orcid_16x16.png)](https://orcid.org/0000-0002-1825-0097)[^aut]"
  )
  attr(badge, "footnote") <- "[^aut]: author"
  expect_output({
    ab <- author2badge()
  })
  expect_equal(ab, badge)

  stub(update_author, "menu", mock(3, 6))
  stub(update_author, "readline", "john@doe.com", depth = 2)
  expect_output(update_author(current = current, selected = 1, root = root))
  current$email <- "john@doe.com"
  expect_identical(current, stored_authors(root))

  stub(update_author, "menu", mock(5, 6))
  stub(update_author, "readline", "University of Life", depth = 2)
  expect_output(update_author(current = current, selected = 1, root = root))
  current$affiliation <- "University of Life"
  expect_identical(current, stored_authors(root))
  badge <- paste0(
    "[Doe, John![ORCID logo](https://info.orcid.org/wp-content/uploads/2019/",
    "11/orcid_16x16.png)](https://orcid.org/0000-0002-1825-0097)[^aut][^UL]"
  )
  attr(badge, "footnote") <- c("[^aut]: author", "[^UL]: University of Life")
  expect_output({
    ab <- author2badge()
  })
  expect_equal(ab, badge)
  expect_output({
    ap <- author2person()
  })
  expect_is(ap, "person")

  expect_null(coalesce(NULL))
  expect_identical(coalesce(NULL, "a"), "a")
  expect_identical(coalesce(NULL, "a", "b"), "a")
  expect_identical(coalesce("a", NULL, "b"), "a")
})
