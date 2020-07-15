#!/bin/sh -l

echo '\nGetting the code...\n'
git clone --quiet https://$2@github.com/$1 check
cd check
git checkout --quiet $GITHUB_SHA
cd $3

Rscript --no-save --no-restore -e 'remotes::install_local(quiet = TRUE, dependencies = TRUE)'
if [ $? -ne 0 ]; then
  echo '\nBuilding the package failed. Please check the error message above.\n';
  exit 1
fi

Rscript --no-save --no-restore -e 'checklist::check_package()'
if [ $? -ne 0 ]; then
  echo '\nThe package failed some checks. Please check the error message above.\n';
  exit 1
fi

export CODECOV_TOKEN=$4
export ORCID_TOKEN=$5
echo '\nChecking code coverage...\n'
Rscript --no-save --no-restore -e 'result <- covr::codecov(quiet = FALSE); message(result$message)'

echo '\nUpdating tag...\n'
Rscript --no-save --no-restore -e 'checklist::set_tag()'
