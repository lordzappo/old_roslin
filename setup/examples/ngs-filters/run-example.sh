#!/bin/bash

pipeline_name_version="variant/1.0.0"

roslin-runner.sh \
    -v ${pipeline_name_version} \
    -w ngs-filters/1.1.4/ngs-filters.cwl \
    -i inputs.yaml \
    -b lsf
