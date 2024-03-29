#!/bin/bash

pipeline_name_version="variant/1.0.1"

roslin-runner.sh \
    -v ${pipeline_name_version} \
    -w flatten-array/1.0.0/flatten-array-bam.cwl \
    -i inputs.yaml \
    -b lsf
