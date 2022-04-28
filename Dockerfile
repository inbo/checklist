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
      org.label-schema.vendor="Research Institute for Nature and Forest" \
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

## install covr
RUN apt-get update \
  && apt-get install  -y --no-install-recommends \
    libharfbuzz-dev \
    libfribidi-dev \
  && apt-get clean \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("covr")'

## install codemetar
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("codemetar")'

## install gert
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("gert")'

## install hexSticker
RUN apt-get update \
  && apt-get install  -y --no-install-recommends \
    libmagick++-dev \
  && apt-get clean \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("hexSticker")'

## install hunspell
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("hunspell")'

## install lintr
RUN Rscript --no-save --no-restore -e 'remotes::install_github("r-lib/lintr")'

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

## install spelling
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("spelling")'

## install spelling
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("withr")'

## install checklist
COPY . /checklist/
RUN Rscript --no-save --no-restore -e 'remotes::install_local("checklist", upgrade = "always")'

COPY docker/entrypoint_package.sh /entrypoint_package.sh
COPY docker/entrypoint_source.sh /entrypoint_source.sh
ENTRYPOINT ["/entrypoint_package.sh"]
