# syntax = docker/dockerfile:1.2
FROM rocker/verse:4.3.0

RUN apt-get update && apt-get install -y --no-install-recommends \
          libcurl4-openssl-dev \
          libssl-dev \
          libnng-dev \
          libmbedtls-dev \
          git-crypt

ENV RENV_PATHS_LIBRARY=/renv/library
ENV RENV_CONFIG_CACHE_SYMLINKS=FALSE

RUN mkdir -p /renv/renv
COPY renv.lock .Rprofile /renv/
COPY renv/activate.R renv/settings.json* /renv/renv/
WORKDIR /renv
RUN --mount=type=cache,target=/root/.cache/R \
  Rscript -e "renv::restore()"
WORKDIR /repel2

CMD ["Rscript", "-e", "R.version"]