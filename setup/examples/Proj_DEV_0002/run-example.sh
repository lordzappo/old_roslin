#!/bin/bash

pipeline_name_version="variant/1.3.1"

roslin_request_to_yaml.py \
    -m Proj_DEV_0002_sample_mapping.txt \
    -p Proj_DEV_0002_sample_pairing.txt \
    -g Proj_DEV_0002_sample_grouping.txt \
    -r Proj_DEV_0002_request.txt \
    -o . \
    -f inputs.yaml

# nohup roslin-runner.sh \
#     -v ${pipeline_name_version} \
#     -w project-workflow.cwl \
#     -i inputs.yaml \
#     -b lsf &

roslin_submit.py \
   --id Proj_DEV_0002 \
   --path . \
   --workflow project-workflow.cwl \
   --pipeline ${pipeline_name_version}
