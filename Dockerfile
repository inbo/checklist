FROM rocker/verse

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
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

## Install nano
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    nano

COPY docker/.Rprofile $R_HOME/etc/Rprofile.site

## install INLA
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("INLA", type = "source")'

## install assertthat
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("assertthat")'

## install covr
RUN apt-get update \
  && apt-get install  -y --no-install-recommends \
    libharfbuzz-dev \
    libfribidi-dev \
  && apt-get clean \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("covr")'

## install codemetar
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("codemetar")'

## install curl
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("curl")'

## install desc
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("desc")'

## install devtools
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("devtools")'

## install fs
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("fs")'

## install gert
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("gert")'

## install hexSticker
RUN apt-get update \
  && apt-get install  -y --no-install-recommends \
    libmagick++-dev \
  && apt-get clean \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("hexSticker")'

## install httr
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("httr")'

## install hunspell
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("hunspell")'

## install jsonlite
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("jsonlite")'

## install knitr
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("knitr")'

## install lintr
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("lintr")'

## install microbenchmark
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("microbenchmark")'

## install mockery
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("mockery")'

## install pdftools
RUN  apt-get update \
  && apt-get install -y --no-install-recommends \
       libpoppler-cpp-dev \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("pdftools")'

## install pkgdown
RUN  apt-get update \
  && apt-get install -y --no-install-recommends \
       libfontconfig1-dev \
       libfreetype6-dev \
       libjpeg-dev \
       libpng-dev \
       libtiff5-dev \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("pkgdown")'

## install R6
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("R6")'

## install rcmdcheck
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("rcmdcheck")'

## install renv
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("renv")'

## install rgdal
RUN apt-get update \
  && apt-get install  -y --no-install-recommends \
    libgdal-dev \
    libproj-dev \
  && apt-get clean \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("rgdal")'

## install rmarkdown
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("rmarkdown")'

## install rorcid
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("rorcid")'

## install roxygen2
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("roxygen2")'

## install rstudioapi
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("rstudioapi")'

## install sessioninfo
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("sessioninfo")'

## install showtext
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("showtext")'

## install sysfonts
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("sysfonts")'

## install testthat
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("testthat")'

## install withr
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("withr")'

## install yaml
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("yaml")'

## install checklist
COPY . /checklist/
RUN Rscript --no-save --no-restore -e 'remotes::install_local("checklist", upgrade = "always")'
RUN Rscript --no-save --no-restore -e 'checklist:::install_dictionary(c("nl_BE", "fr_BE", "de_DE"))'

COPY docker/entrypoint_package.sh /entrypoint_package.sh
COPY docker/entrypoint_source.sh /entrypoint_source.sh
COPY docker/entrypoint_project.sh /entrypoint_project.sh
ENTRYPOINT ["/entrypoint_package.sh"]
