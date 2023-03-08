test_that("lang_2_iso_639_3", {
  expect_identical(lang_2_iso_639_3("eng"), "eng")
  expect_is(z <- lang_2_iso_639_3("zzz"), "character")
  expect_true(z == "zzz")
  expect_equal(
    attr(z, "problem"),
    "Language field in DESCRIPTION must be a valid language.
E.g. en-GB for (British) English and nl-BE for (Flemish) Dutch."
  )
})
