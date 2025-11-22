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
  && Rscript --no-save --no-restore -e 'pak::pkg_install("remotes", dependencies = TRUE)'

## install INLA
RUN  Rscript --no-save --no-restore -e 'pak::pkg_install("fmesher", dependencies = TRUE)' \
  && Rscript --no-save --no-restore -e 'pak::pkg_install("sn", dependencies = TRUE)' \
  && Rscript --no-save --no-restore -e 'pak::pkg_install("INLA", dependencies = TRUE)'

## install checklist dependencies
RUN  Rscript --no-save --no-restore -e 'pak::pkg_install("assertthat", dependencies = TRUE)' \
  && Rscript --no-save --no-restore -e 'pak::pkg_install("codemetar", dependencies = TRUE)' \
  && Rscript --no-save --no-restore -e 'pak::pkg_install("hunspell", dependencies = TRUE)' \
  && Rscript --no-save --no-restore -e 'pak::pkg_install("lintr", dependencies = TRUE)' \
  && Rscript --no-save --no-restore -e 'pak::pkg_install("renv", dependencies = TRUE)' \
  && Rscript --no-save --no-restore -e 'pak::pkg_install("showtext", dependencies = TRUE)' \
  && Rscript --no-save --no-restore -e 'pak::pkg_install("zen4R", dependencies = TRUE)'

## install checklist
COPY . /checklist/
RUN Rscript --no-save --no-restore -e 'remotes::install_local("checklist", upgrade = "always", dependencies = TRUE)'
RUN Rscript --no-save --no-restore -e 'checklist:::install_dictionary(c("nl_BE", "fr_BE", "de_DE"))'

COPY docker/entrypoint_package.sh /entrypoint_package.sh
COPY docker/entrypoint_project.sh /entrypoint_project.sh
ENTRYPOINT ["/entrypoint_package.sh"]
