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
    nano \
  && apt-get clean

COPY docker/.Rprofile $R_HOME/etc/Rprofile.site
COPY docker/upgrade_texlive.sh /rocker_scripts/upgrade_texlive.sh

RUN /rocker_scripts/upgrade_texlive.sh

RUN Rscript --no-save --no-restore -e 'install.packages("pak")' \
  && Rscript --no-save --no-restore -e 'pak::pkg_install("remotes")'

## install INLA
RUN  Rscript --no-save --no-restore -e 'pak::pkg_install("fmesher")' \
  && Rscript --no-save --no-restore -e 'pak::pkg_install("sn")' \
  && Rscript --no-save --no-restore -e 'pak::pkg_install("INLA")'

## install checklist dependencies
RUN  Rscript --no-save --no-restore -e 'pak::pkg_install("bookdown")' \
  && Rscript --no-save --no-restore -e 'pak::pkg_install("codemetar")' \
  && Rscript --no-save --no-restore -e 'pak::pkg_install("covr")' \
  && Rscript --no-save --no-restore -e 'pak::pkg_install("cyclocomp")' \
  && Rscript --no-save --no-restore -e 'pak::pkg_install("devtools")' \
  && Rscript --no-save --no-restore -e 'pak::pkg_install("hunspell")' \
  && Rscript --no-save --no-restore -e 'pak::pkg_install("lintr")' \
  && Rscript --no-save --no-restore -e 'pak::pkg_install("mockery")' \
  && Rscript --no-save --no-restore -e 'pak::pkg_install("pdftools")' \
  && Rscript --no-save --no-restore -e 'pak::pkg_install("renv")' \
  && Rscript --no-save --no-restore -e 'pak::pkg_install("showtext")' \
  && Rscript --no-save --no-restore -e 'pak::pkg_install("zen4R")'

## install checklist
COPY . /checklist/
RUN Rscript --no-save --no-restore -e 'remotes::install_local("checklist", upgrade = "always", dependencies = TRUE)'
RUN Rscript --no-save --no-restore -e 'checklist:::install_dictionary(c("nl_BE", "fr_BE", "de_DE"))'

COPY docker/entrypoint_package.sh /entrypoint_package.sh
COPY docker/entrypoint_source.sh /entrypoint_source.sh
COPY docker/entrypoint_project.sh /entrypoint_project.sh
ENTRYPOINT ["/entrypoint_package.sh"]
