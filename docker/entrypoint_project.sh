#!/bin/sh -l

echo '\nGetting the code...\n'
git clone https://oauth2:$GITHUB_TOKEN@github.com/$GITHUB_REPOSITORY check
cd check
git config advice.detachedHead false
git checkout $GITHUB_SHA


if [ ! -z "$INPUT_APTGET" ]; then
  apt-get update
  apt-get install -y --no-install-recommends $INPUT_APTGET
fi

if [ -f renv.lock ]; then
  Rscript --no-save --no-restore --no-init-file -e 'renv::restore()'
fi

if [ -n "$INPUT_CRAN" ]; then
  CRAN='remotes::install_cran('${INPUT_CRAN}', upgrade = "always")'
  Rscript --no-save --no-restore --no-init-file -e "$CRAN"
fi
Rscript --no-save --no-restore --no-init-file -e 'install.packages(checklist:::list_missing_packages())'

echo '\nGetting the organisation settting...\n'
Rscript --no-save --no-restore --no-init-file -e 'checklist::get_default_org_list()'

echo '\nChecking the project...\n'
Rscript --no-save --no-restore --no-init-file -e 'checklist::check_project("'$INPUT_PATH'", fail = TRUE, quiet = FALSE)'
if [ $? -ne 0 ]; then
  echo '\nThe project failed some checks. Please check the error message above.\n';
  exit 1
fi
