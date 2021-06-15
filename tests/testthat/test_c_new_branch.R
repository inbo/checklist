test_that("new_branch() creates a branch from the main branch", {
  origin_path <- tempfile("new_branch_origin")
  dir.create(origin_path)
  on.exit(unlink(origin_path, recursive = TRUE), add = TRUE)

  path <- tempfile("new_branch")
  dir.create(path)
  on.exit(unlink(path, recursive = TRUE), add = TRUE)

  origin_repo <- init(origin_path, bare = TRUE)
  repo <- git2r::clone(origin_path, path, progress = FALSE)

  git2r::config(
    repo = repo, user.name = "junk", user.email = "junk@inbo.be"
  )

  writeLines("foo", file.path(path, "junk.txt"))
  add(repo, "junk.txt")
  initial <- git2r::commit(repo = repo, message = "Initial commit")
  git2r::push(repo, "origin", "refs/heads/master", set_upstream = TRUE)
  checkout(repo, "branch", create = TRUE)
  writeLines("foo", file.path(path, "junk2.txt"))
  add(repo, "junk2.txt")
  junk <- git2r::commit(repo = repo, message = "branch commit")
  git2r::push(repo, "origin", "refs/heads/branch", set_upstream = TRUE)
  expect_invisible(new_branch("new", path))
  expect_identical(repository_head(repo)$name, "new")
  expect_identical(git2r::last_commit(repo), initial)
  expect_invisible(new_branch("new2", repo))
  expect_identical(repository_head(repo)$name, "new2")
  expect_identical(git2r::last_commit(repo), initial)
})
