#!/usr/bin/env bash

task_name="collect_hs_metrics"
task_name=$(echo "$task_name" | sed -r 's/_/-/g')
task_version="latest"
python3 meta.py 'https://gitlab.com/intelliseq/workflows/raw/master/src/main/wdl/tasks/$task_name/$task_version/$task_name.wdl'
