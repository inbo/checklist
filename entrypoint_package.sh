#!/bin/sh -l

echo '\nGetting the code...\n'
git clone https://$2@github.com/$1 check
cd check
echo 'GitHub actions:' $GITHUB_ACTIONS
echo 'Event name:' $GITHUB_EVENT_NAME
echo 'ref:' $GITHUB_REF

git config user.name "Checklist bot"
git config user.email "checklist@inbo.be"
git config advice.detachedHead false
git checkout $GITHUB_SHA

cd $3
export CODECOV_TOKEN=$4
export ORCID_TOKEN=$5

echo '\nTrying to install the package...\n'
Rscript --no-save --no-restore -e 'remotes::install_local(dependencies = TRUE, force = TRUE)'
if [ $? -ne 0 ]; then
  echo '\nBuilding the package failed. Please check the error message above.\n';
  exit 1
fi

echo '\nChecking the package...\n'
Rscript --no-save --no-restore -e 'checklist::check_package()'
if [ $? -ne 0 ]; then
  echo '\nThe package failed some checks. Please check the error message above.\n';
  exit 1
fi

echo '\nChecking code coverage...\n'
Rscript --no-save --no-restore -e 'result <- covr::codecov(quiet = FALSE); message(result$message)'

echo '\nBuilding pkgdown website...\n'
Rscript --no-save --no-restore -e 'pkgdown::build_site()'

if [ "${GITHUB_ACTIONS}" != "true" ]; then
  echo '\nNot updating tag, because not a GitHub action.';
else if [ "${GITHUB_EVENT_NAME}" != "push" ];
  echo '\nNot updating tag, because not a push event.';
else if [ "${GITHUB_REF}" != "refs/heads/master"];
  echo '\nNot updating tag, because not on master.';
else
  echo '\nUpdating tag...\n'
  Rscript --no-save --no-restore -e 'checklist::set_tag()'

  echo '\nPush pkgdown website...\n'
  cp -R /check/docs /docs
  if [ -z  "$(git branch -r | grep origin/gh-pages)" ]; then
    git checkout --orphan gh-pages
    git rm -rf --quiet .
    git commit --allow-empty -m "Initializing gh-pages branch"
  else
    git checkout -b gh-pages
    git rm -rf --quiet .
    rm -R *
  fi
  cp -R /docs/. /check
  git add --all
  git commit --amend -m "Automated update of gh-pages website"
  git push --force --set-upstream origin gh-pages
fi
