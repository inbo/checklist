#' @importFrom stats setNames
fix_duplicate_git_config <- function(repo = ".") {
  current <- git_config(repo)
  if (anyDuplicated(current) == 0) {
    return(invisible(NULL))
  }
  problem <- current$name[anyDuplicated(current)]
  grepl("^branch", problem) |>
    setNames(sprintf("unhandled duplicate in git config: `%s`", problem)) |>
    stopifnot()
  file.path(repo, ".git", "config") |> readLines() -> local_config
  branch_position <- grep("\\[branch \"(.*)\"\\]", local_config)
  branch_name <- gsub(
    "\\[branch \"(.*)\"\\]",
    "\\1",
    local_config[branch_position]
  )
  paste0("branch.", branch_name, ".") |>
    vapply(grepl, logical(1), x = problem) |>
    which() -> matching_branch
  branch_position <- tail(branch_position, 1 - matching_branch)
  keep_start <- head(local_config, branch_position[1])
  if (length(branch_position) == 1) {
    keep_end <- character(0)
    tail(local_config, -branch_position[1]) -> to_alter
  } else {
    keep_end <- tail(local_config, 1 - branch_position[2])
    head(local_config, branch_position[2] - 1) |>
      tail(-branch_position[1]) -> to_alter
  }
  c(keep_start, unique(to_alter), keep_end) |>
    writeLines(file.path(repo, ".git", "config"))
  return(invisible(NULL))
}
