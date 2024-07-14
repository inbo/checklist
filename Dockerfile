FROM rocker/verse:latest

ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="checklist" \
      org.label-schema.description="A docker image dedicated to thoroughly checking R packages and code." \
      org.label-schema.license="MIT" \
      org.label-schema.url="e.g. https://www.inbo.be/" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/inbo/checklist" \
      org.label-schema.vendor="Research Institute for Nature and Forest (INBO)" \
      maintainer="Thierry Onkelinx <thierry.onkelinx@inbo.be>"

## for apt to be noninteractive
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

## Install nano
RUN apt-get update \
  && apt upgrade -y \
  && apt-get install -y --no-install-recommends \
    nano

COPY docker/.Rprofile $R_HOME/etc/Rprofile.site

## install INLA
RUN  apt update \
  && apt install -y --no-install-recommends \
    gdal-bin libgdal-dev libproj-dev libudunits2-dev r-cran-class \
    r-cran-classint r-cran-cli r-cran-dbi r-cran-e1071 r-cran-fansi \
    r-cran-units r-cran-dplyr r-cran-generics r-cran-glue \
    r-cran-kernsmooth r-cran-lattice r-cran-lifecycle r-cran-magrittr \
    r-cran-matrix r-cran-pillar r-cran-pkgconfig r-cran-proxy \
    r-cran-r6 r-cran-rcpp r-cran-rlang r-cran-s2 r-cran-sf r-cran-sp \
    r-cran-tibble r-cran-tidyselect r-cran-utf8 r-cran-vctrs r-cran-withr \
    r-cran-wk \
  && Rscript --no-save --no-restore -e 'update.packages(ask = FALSE)' \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("fmesher")' \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("INLA", type = "source")'

## install sn
RUN  apt update \
  && apt install -y --no-install-recommends \
    r-cran-matrixmodels r-cran-mnormt r-cran-numderiv r-cran-quantreg \
    r-cran-sn r-cran-sparsem \
  && Rscript --no-save --no-restore -e 'update.packages(ask = FALSE)' \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("sn")'

## install checklist dependencies
RUN  apt update \
  && apt install -y --no-install-recommends \
    r-cran-askpass r-cran-assertthat r-cran-backports r-cran-base64enc \
    r-cran-brew r-cran-brio r-cran-cachem r-cran-callr r-cran-clipr \
    r-cran-commonmark r-cran-crayon r-cran-credentials r-cran-crul r-cran-curl \
    r-cran-desc r-cran-devtools r-cran-diffobj r-cran-digest r-cran-downlit \
    r-cran-ellipsis r-cran-evaluate r-cran-fastmap r-cran-fs r-cran-gert \
    r-cran-gh r-cran-gitcreds r-cran-highr r-cran-htmltools r-cran-htmlwidgets \
    r-cran-httpcode r-cran-httpuv r-cran-httr r-cran-hunspell r-cran-ini \
    r-cran-jsonlite r-cran-jquerylib r-cran-knitr r-cran-later r-cran-lazyeval \
    r-cran-memoise r-cran-mime r-cran-miniui r-cran-openssl r-cran-pingr \
    r-cran-pkgbuild r-cran-pkgload r-cran-praise r-cran-prettyunits \
    r-cran-processx r-cran-promises r-cran-ps r-cran-purrr r-cran-ragg \
    r-cran-rappdirs r-cran-rcmdcheck r-cran-rematch2 r-cran-rex \
    r-cran-rmarkdown r-cran-roxygen2 r-cran-remotes r-cran-rprojroot \
    r-cran-rstudioapi r-cran-rversions r-cran-sass r-cran-sessioninfo \
    r-cran-shiny r-cran-sourcetools r-cran-stringi r-cran-stringr r-cran-sys \
    r-cran-systemfonts r-cran-testthat r-cran-textshaping r-cran-tinytex \
    r-cran-triebeard r-cran-urltools r-cran-usethis r-cran-waldo \
    r-cran-whisker r-cran-xfun r-cran-xml2 r-cran-xopen r-cran-xtable \
    r-cran-yaml r-cran-zip \
  && Rscript --no-save --no-restore -e 'update.packages(ask = FALSE)' \
  && Rscript --no-save --no-restore -e 'remotes::install_cran(c("bslib", "codemeta", "codemetar", "cyclocompt", "fontawesome", "httr2", "lintr", "pkgdown", "profvis", "renv", "urlchecker", "xmlparsedata"))'

## install checklist
COPY . /checklist/
RUN Rscript --no-save --no-restore -e 'remotes::install_local("checklist", upgrade = "always")'
RUN Rscript --no-save --no-restore -e 'checklist:::install_dictionary(c("nl_BE", "fr_BE", "de_DE"))'

COPY docker/entrypoint_package.sh /entrypoint_package.sh
COPY docker/entrypoint_source.sh /entrypoint_source.sh
COPY docker/entrypoint_project.sh /entrypoint_project.sh
ENTRYPOINT ["/entrypoint_package.sh"]
