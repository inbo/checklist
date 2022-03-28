iso_raw <- readLines(
  "https://iso639-3.sil.org/sites/iso639-3/files/downloads/iso-639-3.tab",
  encoding = "UTF-8"
)
iso_list <- strsplit(iso_raw[-1], split = "\t")
iso_639_3 <- data.frame(
  alpha_3 = vapply(iso_list, `[`, character(1), 1),
  alpha_2 = vapply(iso_list, `[`, character(1), 4),
  name = vapply(iso_list, `[`, character(1), 7)
)
save(iso_639_3, file = "R/sysdata.rda")
