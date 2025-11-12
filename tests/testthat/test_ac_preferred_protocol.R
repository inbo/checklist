library(mockery)
test_that("preferred_protocol() works", {
  expect_false(file_exists(file.path(config_dir, "config", "config.yml")))
  stub(preferred_protocol, "R_user_dir", mock_r_user_dir(config_dir))
  stub(
    preferred_protocol,
    "readline",
    mock("junk", "https://gitlab.com/ThierryO")
  )
  expect_identical(preferred_protocol(), "https://gitlab.com/ThierryO/%s.git")
  expect_identical(
    list.files(config_dir, recursive = TRUE),
    c(
      "config/config.yml",
      "config/gitlab.com/thierryo/agpl_3.md",
      "config/gitlab.com/thierryo/apache_2.0.md",
      "config/gitlab.com/thierryo/cc_by_nc_sa_4.0.md",
      "config/gitlab.com/thierryo/mit.md",
      "config/gitlab.com/thierryo/organisation.yml"
    )
  )
  stub(preferred_protocol, "R_user_dir", mock_r_user_dir(config_dir))
  expect_identical(preferred_protocol(), "https://gitlab.com/ThierryO/%s.git")
})
