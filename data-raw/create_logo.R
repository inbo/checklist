create_hexsticker(
  package_name = "checklist",
  filename = file.path("man", "figures", "logo.svg"),
  icon = file.path("inst", "check-box.svg"), x = 180, y = -110, scale = 0.35
)
pkgdown::build_favicons(overwrite = TRUE)
