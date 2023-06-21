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

## install assertthat
RUN  apt update \
  && apt install -y --no-install-recommends r-cran-assertthat \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("assertthat")'

## install desc
RUN  apt update \
  && apt install -y --no-install-recommends r-cran-desc \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("desc")'

## install fs
RUN  apt update \
  && apt install -y --no-install-recommends r-cran-fs \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("fs")'

## install jsonlite
RUN  apt update \
  && apt install -y --no-install-recommends r-cran-jsonlite \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("jsonlite")'

## install hunspell
RUN  apt update \
  && apt install -y --no-install-recommends r-cran-hunspell \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("hunspell")'

## install R6
RUN  apt update \
  && apt install -y --no-install-recommends r-cran-r6 \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("R6")'

## install httr
RUN  apt update \
  && apt install -y --no-install-recommends r-cran-httr \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("httr")'

## install gert
RUN  apt update \
  && apt install -y --no-install-recommends r-cran-gert \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("gert")'

## install knitr
RUN  apt update \
  && apt install -y --no-install-recommends r-cran-knitr \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("knitr")'

## install sessioninfo
RUN  apt update \
  && apt install -y --no-install-recommends r-cran-sessioninfo \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("sessioninfo")'

## install withr
RUN  apt update \
  && apt install -y --no-install-recommends r-cran-withr \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("withr")'

## install yaml
RUN  apt update \
  && apt install -y --no-install-recommends r-cran-yaml \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("yaml")'

## install curl
RUN  apt update \
  && apt install -y --no-install-recommends r-cran-curl \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("curl")'

## install renv
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("renv")'

## install covr
RUN apt-get update \
  && apt-get install  -y --no-install-recommends \
    libharfbuzz-dev \
    libfribidi-dev \
    r-cran-covr \
  && apt-get clean \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("covr")'

## install lintr
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("lintr")'

## install rcmdcheck
RUN  apt update \
  && apt install -y --no-install-recommends r-cran-rcmdcheck \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("rcmdcheck")'

## install rmarkdown
RUN  apt update \
  && apt install -y --no-install-recommends r-cran-rmarkdown \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("rmarkdown")'

## install roxygen2
RUN  apt update \
  && apt install -y --no-install-recommends r-cran-roxygen2 \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("roxygen2")'

## install INLA
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("INLA", type = "source")'

## install bookdown
RUN  apt update \
  && apt install -y --no-install-recommends r-cran-bookdown \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("bookdown")'

## install mockery
RUN  apt update \
  && apt install -y --no-install-recommends r-cran-mockery \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("mockery")'

## install pdftools
RUN  apt-get update \
  && apt-get install -y --no-install-recommends \
       libpoppler-cpp-dev \
       r-cran-pdftools \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("pdftools")'

## install rstudioapi
RUN  apt update \
  && apt install -y --no-install-recommends r-cran-rstudioapi \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("rstudioapi")'

## install codemetar
RUN  Rscript --no-save --no-restore -e 'remotes::install_cran("codemetar")'

## install testthat
RUN  apt update \
  && apt install -y --no-install-recommends r-cran-testthat \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("testthat")'

## install pkgdown
RUN  apt-get update \
  && apt-get install -y --no-install-recommends \
       libfontconfig1-dev \
       libfreetype6-dev \
       libjpeg-dev \
       libpng-dev \
       libtiff5-dev \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("pkgdown")'

## install sysfonts
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("sysfonts")'

## install showtext
RUN Rscript --no-save --no-restore -e 'remotes::install_cran("showtext")'

## install hexSticker
RUN apt-get update \
  && apt-get install  -y --no-install-recommends \
    libmagick++-dev \
  && apt-get clean \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("hexSticker")'

## install devtools
RUN  apt update \
  && apt install -y --no-install-recommends r-cran-devtools \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("devtools")'

## install zen4R
RUN  apt update \
  && apt install -y --no-install-recommends libsecret-1-dev \
  && Rscript --no-save --no-restore -e 'remotes::install_cran("zen4R")'

## install microbenchmark
RUN  Rscript --no-save --no-restore -e 'remotes::install_cran("microbenchmark")'

## install checklist
COPY . /checklist/
RUN Rscript --no-save --no-restore -e 'remotes::install_local("checklist", upgrade = "always")'
RUN Rscript --no-save --no-restore -e 'checklist:::install_dictionary(c("nl_BE", "fr_BE", "de_DE"))'

COPY docker/entrypoint_package.sh /entrypoint_package.sh
COPY docker/entrypoint_source.sh /entrypoint_source.sh
COPY docker/entrypoint_project.sh /entrypoint_project.sh
ENTRYPOINT ["/entrypoint_package.sh"]
