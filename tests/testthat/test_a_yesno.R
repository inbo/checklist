library(mockery)
test_that("yesno", {
  yesno_mock <- mock(TRUE)
  stub(yesno, "interactive", yesno_mock)
  stub(yesno, "menu", 1)
  expect_is(yesno(), "logical")
  expect_called(yesno_mock, 1)
})
