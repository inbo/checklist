test_that("check_lintr() works on a project with renv", {
  old_option <- getOption("checklist.rstudio_source_markers", TRUE)
  options("checklist.rstudio_source_markers" = FALSE)
  defer(options("checklist.rstudio_source_markers" = old_option))

  path <- tempfile("check_lintr")
  dir_create(path)
  defer(unlink(path, recursive = TRUE))

  # create a minimal empty project
  x <- checklist$new(x = path, language = "en-GB", package = FALSE)
  x$set_required("lintr")
  write_checklist(x)
  expect_false(check_lintr(path)$fail)

  # setup renv at the root of the project
  renv::init(path, bare = TRUE, load = FALSE, restart = FALSE)
  # add a file within the renv folder that fails lintr
  path(path, "renv", "WRONG-name style.r") |>
    writeLines(text = "lowerCamelCase<-function(base_name.style){return(T)}")
  # test that lintr ignores files within the renv folder
  expect_false(check_lintr(path)$fail)

  # setup renv at a subfolder of the project
  path(path, "source", "targets", "pipeline1") |>
    dir_create()
  path(path, "source", "targets", "pipeline1") |>
    renv::init(bare = TRUE, load = FALSE, restart = FALSE)
  # add a file within this folder that fails lintr
  path |>
    path("source", "targets", "pipeline1", "renv", "WRONG-name style.r") |>
    writeLines(text = "lowerCamelCase<-function(base_name.style){return(T)}")
  # test that lintr ignores files within the renv folder
  expect_false(check_lintr(path)$fail)
})
