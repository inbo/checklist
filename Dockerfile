FROM rocker/r-ubuntu:20.04

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

## Configure default locale, see https://github.com/rocker-org/rocker/issues/19
RUN apt-get update \
  && apt-get install -y  --no-install-recommends \
    locales \
  && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
  && locale-gen en_US.utf8 \
  && /usr/sbin/update-locale LANG=en_US.UTF-8

## Install wget
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    wget

## install tinytex
RUN  apt-get update \
  && apt-get install -y --no-install-recommends \
    qpdf \
  && Rscript --no-save --no-restore -e 'install.packages("tinytex")' \
  && Rscript -e 'tinytex::install_tinytex()' \
  && Rscript -e 'tinytex::tlmgr_install(c("inconsolata", "times", "tex", "helvetic", "dvips"))'
ENV PATH="/root/bin:${PATH}"

## Install pandoc
RUN wget https://github.com/jgm/pandoc/releases/download/2.7.3/pandoc-2.7.3-1-amd64.deb \
  && dpkg -i pandoc-2.7.3-1-amd64.deb \
  && rm pandoc-2.7.3-1-amd64.deb

## install git
RUN  apt-get update \
  && apt-get install -y --no-install-recommends \
    git

## install INLA
RUN Rscript --no-save --no-restore -e 'install.packages("INLA", repos = c(getOption("repos"), INLA = "https://inla.r-inla-download.org/R/stable"))'

## install remotes package
RUN Rscript --no-save --no-restore -e 'install.packages("remotes")'

## install devtools
RUN  apt-get update \
  && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("devtools")'

## install assertthat
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("assertthat")'

## install covr
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("covr")'

## install codemetar
RUN apt-get update \
  && apt-get install  -y --no-install-recommends \
    libgit2-dev \
  && apt-get clean \
  && Rscript --no-save --no-restore -e 'remotes::install_github("ropensci/codemetar@dev")'

## install desc
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("desc")'

## install git2r
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("git2r")'

## install hunspell
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("hunspell")'

## install lintr
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("lintr")'

## install microbenchmark
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("microbenchmark")'

## install mockery
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("mockery")'

## install pillar
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("pkgdown")'

## install pillar
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("pillar")'

## install Rcpp
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("Rcpp")'

## install rcmdcheck
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("rcmdcheck")'

## install rlang
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("rlang")'

## install rgdal
RUN apt-get update \
  && apt-get install  -y --no-install-recommends \
    libgdal-dev \
    libproj-dev \
  && apt-get clean \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("rgdal")'

## install rorcid
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("rorcid")'

## install roxygen2
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("roxygen2")'

## install R6
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("R6")'

## install spelling
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("sessioninfo")'

## install spelling
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("spelling")'

## install tibble
RUN  Rscript --no-save --no-restore -e 'remotes::install_cran("tibble")'

## install tidyverse
RUN  Rscript --no-save --no-restore -e 'remotes::install_cran("tidyverse")'

## install yaml
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("yaml")'

## install checklist
COPY . /checklist/
RUN Rscript --no-save --no-restore -e 'remotes::install_local("checklist", dependencies = FALSE)'

COPY entrypoint_package.sh /entrypoint_package.sh
COPY entrypoint_source.sh /entrypoint_source.sh
ENTRYPOINT ["/entrypoint_package.sh"]
