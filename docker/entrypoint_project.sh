#!/bin/sh -l

echo '\nGetting the code...\n'
git clone https://$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY check
cd check
git config advice.detachedHead false
git checkout $GITHUB_SHA
cd ..

Rscript --no-save --no-restore -e 'checklist::check_project("check/'$INPUT_PATH'", fail = TRUE, quiet = FALSE)'
if [ $? -ne 0 ]; then
  echo '\nThe project failed some checks. Please check the error message above.\n';
  exit 1
fi
