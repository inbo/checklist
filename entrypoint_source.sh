#!/bin/sh -l

echo '\nGetting the code...\n'
git clone https://$2@github.com/$1 check
cd check
git config advice.detachedHead false
git checkout $GITHUB_SHA
cd $3

Rscript --no-save --no-restore -e 'checklist::check_source()'
if [ $? -ne 0 ]; then
  echo '\nThe source code failed some checks. Please check the error message above.\n';
  exit 1
fi
