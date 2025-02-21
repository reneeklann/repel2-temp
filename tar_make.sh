#!/bin/bash

DEFAULT_TARGET=wb_data_download
TARGET="${1:-$DEFAULT_TARGET}"
export TARGETS_ERROR=stop

Rscript -e "targets::tar_make($TARGET)"