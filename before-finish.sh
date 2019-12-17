### bioobject
wget -O bioobject.py https://gitlab.com/intelliseq/workflows/raw/dev/src/main/scripts/bco/v1/versions.py
python3 bioobject.py

### task_name change "_" to "-"
task_name=$(echo "$task_name" | sed -r 's/_/-/g')

### meta_data
python3 -m pip install --user miniwdl
wget -O meta.py https://raw.githubusercontent.com/MateuszMarynowski/coverage_and_mapped/master/meta.py
python3 meta.py 'https://gitlab.com/intelliseq/workflows/raw/dev/src/main/wdl/tasks/$task_name/$task_version/$task_name.wdl'

### description_domain
pipeline_steps=$(jo -a "$(cat meta.json)")
description_domain=$(jo -p pipeline_steps="$pipeline_steps")

### bioobject
cpu=$(lscpu | grep '^CPU(s)' | grep -o '[0-9]*')
memory=$(cat /proc/meminfo | grep MemTotal | grep -o '[0-9]*' |  awk '{ print $1/1024/1024 ; exit}')
finishtime=$(date +%s)
starttime=$(cat starttime)
tasktime=$((finishtime-starttime))

os_name=$(cat /etc/os-release | grep -e "^NAME" | grep -o "\".*\"" | sed 's/"//g')
os_version=$(cat /etc/os-release | grep -e "^VERSION" | grep -o "\".*\"" | sed 's/"//g')
jo -p name=$os_name version=$os_version > software_ubuntu.bco
software_prerequisites=$(tools="[]"; for toolfile in $(ls software*.bco); do tools=$(echo $tools | jq ". + [$(cat $toolfile)]") ; done; echo $tools)
if [ "$(ls -A $datasource*.bco)" ]; then
  external_data_endpoints=$(tools="[]"; for toolfile in $(ls datasource*.bco); do tools=$(echo $tools | jq ". + [$(cat $toolfile)]") ; done; echo $tools)
fi

step=$(jo name="$task_name" version="$task_version")
provenance_domain=$(jo -p \
    steps=$(jo -a $step) \
)

execution_domain=$(jo -p \
  script="https://gitlab.com/intelliseq/workflows/raw/dev/src/main/wdl/tasks/$task_name/$task_version/$task_name.wdl" \
  script_driver="shell" \
  software_prerequisites="$software_prerequisites" \
  external_data_endpoints="$external_data_endpoints" \
  name="$task_name" \
)

CPU=$(jo param=cpu value=$cpu name="$task_name")
MEMORY=$(jo param=memory value=$memory name="$task_name")
TASKTIME=$(jo param=tasktime value=$tasktime name="$task_name")
DOCKER=$(jo param=docker_image value=$task_docker name="$task_name")

parametric_domain=$(jo -a $CPU $MEMORY $TASKTIME $DOCKER)

biocomputeobject=$(jo -p \
  bco_spec_version="https://w3id.org/biocompute/1.3.0/" \
  bco_id="https://intelliseq.com/flow/$(uuidgen)" \
  provenance_domain="$provenance_domain" \
  execution_domain="$execution_domain" \
  parametric_domain="$parametric_domain" \
  description_domain="$description_domain" \
)

echo "$biocomputeobject" > bco.json
