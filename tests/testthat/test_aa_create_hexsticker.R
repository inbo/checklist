test_that("create_hexsticker", {
  skip_on_os("mac")
  sticker_no_logo <- tempfile("no_logo", fileext = ".svg")
  create_hexsticker("coolname", filename = sticker_no_logo)
  expect_true(file.exists(sticker_no_logo))

  sticker_logo <- tempfile("logo", fileext = ".svg")
  create_hexsticker(
    "coolname",
    filename = sticker_logo,
    icon = system.file("check-box.svg", package = "checklist")
  )
  expect_true(file.exists(sticker_logo))
})
