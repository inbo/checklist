#!/bin/sh -l

Rscript --no-save --no-restore -e 'stopifnot("checklist" %in% rownames(installed.packages()))'
