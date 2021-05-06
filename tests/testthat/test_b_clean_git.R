test_that("clean_git with `master` as main branch", {
  origin_path <- tempfile("clean_git_origin")
  dir.create(origin_path)
  on.exit(unlink(origin_path, recursive = TRUE), add = TRUE)

  path <- tempfile("clean_git")
  dir.create(path)
  on.exit(unlink(path, recursive = TRUE), add = TRUE)

  path2 <- tempfile("clean_git2")
  dir.create(path2)
  on.exit(unlink(path2, recursive = TRUE), add = TRUE)

  origin_repo <- init(origin_path, bare = TRUE)
  repo <- git2r::clone(origin_path, path, progress = FALSE)
  repo2 <- git2r::clone(origin_path, path2, progress = FALSE)

  git2r::config(
    repo = repo, user.name = "junk", user.email = "junk@inbo.be"
  )
  git2r::config(
    repo = repo2, user.name = "junk", user.email = "junk@inbo.be"
  )

  writeLines("foo", file.path(path, "junk.txt"))
  add(repo, "junk.txt")
  junk <- git2r::commit(repo = repo, message = "Initial commit")
  git2r::push(repo, "origin", "refs/heads/master", set_upstream = TRUE)
  checkout(repo, "branch", create = TRUE)
  writeLines("foo", file.path(path, "junk2.txt"))
  add(repo, "junk2.txt")
  junk <- git2r::commit(repo = repo, message = "branch commit")
  git2r::push(repo, "origin", "refs/heads/branch", set_upstream = TRUE)

  # checkout master when no local branches
  expect_identical(names(branches(repo2)), character(0))
  expect_invisible(clean_git(path2, verbose = FALSE))
  expect_identical(
    lookup_commit(branches(repo)[["branch"]])$sha,
    lookup_commit(branches(repo2)[["origin/branch"]])$sha
  )

  # update local branches that are behind
  writeLines("bar", file.path(path, "junk2.txt"))
  add(repo, "junk2.txt")
  junk <- git2r::commit(repo = repo, message = "branch commit")
  git2r::push(repo)
  checkout(repo2, "branch", create = TRUE)
  expect_invisible(clean_git(repo2, verbose = FALSE))
  expect_identical(
    lookup_commit(branches(repo)[["branch"]])$sha,
    lookup_commit(branches(repo2)[["origin/branch"]])$sha
  )
  expect_identical(
    ahead_behind(
      lookup_commit(branches(repo2)[["branch"]]),
      lookup_commit(branches(repo2)[["origin/branch"]])
    ),
    c(0L, 0L)
  )
  expect_identical(repository_head(repo2), branches(repo2)[["branch"]])

  # don't push local changes ahead
  writeLines("junk", file.path(path2, "junk2.txt"))
  add(repo2, "junk2.txt")
  junk <- git2r::commit(repo = repo2, message = "branch commit")
  expect_identical(
    ahead_behind(
      lookup_commit(branches(repo2)[["branch"]]),
      lookup_commit(branches(repo2)[["origin/branch"]])
    ),
    c(1L, 0L)
  )
  expect_invisible(clean_git(path2, verbose = FALSE))
  expect_identical(
    ahead_behind(
      lookup_commit(branches(repo2)[["branch"]]),
      lookup_commit(branches(repo2)[["origin/branch"]])
    ),
    c(1L, 0L)
  )
  expect_identical(repository_head(repo2), branches(repo2)[["branch"]])

  # issue warnings when branch is ahead and behind
  writeLines("bar", file.path(path, "junk.txt"))
  add(repo, "junk.txt")
  junk <- git2r::commit(repo = repo, message = "branch commit")
  git2r::push(repo)
  expect_warning(
    clean_git(path2, verbose = FALSE),
    "diverged from the origin branch"
  )
  expect_identical(
    ahead_behind(
      lookup_commit(branches(repo2)[["branch"]]),
      lookup_commit(branches(repo2)[["origin/branch"]])
    ),
    c(1L, 1L)
  )

  # remove local branches fully merged into the main branch
  checkout(repo, "master")
  git2r::merge(
    branches(repo)[["branch"]], branches(repo)[["master"]],
    fail = TRUE
  )
  git2r::push(repo)
  git2r::branch_delete(branches(origin_repo)[["branch"]])
  expect_invisible(clean_git(path, verbose = FALSE))
  expect_named(branches(repo), c("master", "origin/master"))
  expect_identical(repository_head(repo)$name, "master")

  # keep diverging local branches without tracking remote
  expect_warning(
    clean_git(path2, verbose = FALSE),
    "diverged from the main origin branch"
  )
  expect_named(branches(repo2), c("branch", "master", "origin/master"))
  expect_identical(
    ahead_behind(
      lookup_commit(branches(repo2)[["branch"]]),
      lookup_commit(branches(repo2)[["origin/master"]])
    ),
    c(1L, 1L)
  )
  expect_identical(repository_head(repo2)$name, "branch")
})
