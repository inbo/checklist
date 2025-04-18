#!/bin/sh -l

installed_version=$(tlmgr --version | grep -oP 'version \K[0-9]{4}')
current_year=$(date +'%Y')
if [ "$installed_version" -lt "$current_year" ]; then
  /rocker_scripts/install_texlive.sh
fi
