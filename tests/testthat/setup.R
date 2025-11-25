mock_r_user_dir <- function(alt_dir) {
  function(package, which = c("data", "config", "cache")) {
    which <- match.arg(which)
    return(file.path(alt_dir, which))
  }
}

config_dir <- tempfile("config_dir")
withr::defer(unlink(config_dir, recursive = TRUE), testthat::teardown_env())
