workflow merge_bco_workflow { call merge_bco {} }

task merge_bco {
  File bco_collect_hs
  File bco_report
  # @Input(description="", required="false")
  String task_name = "merge_bco"
  String task_version = "1.0"
  String docker_image = "intelliseqngs/ubuntu-minimal:18.04_v0.2"

  command <<<
    provenance_domain=`jq -s '{ steps: map(.provenance_domain.steps[]) }' ${bco_collect_hs} ${bco_report}`
    echo_provenance_domain=`echo $provenance_domain | jq '.steps'`

    execution_domain=`jq -s '{ execution_domain: map(.execution_domain) }' ${bco_collect_hs} ${bco_report}`
    echo_execution_domain=`echo $execution_domain | jq '.execution_domain'`

    parametric_domain=`jq -s '{ parametric_domain: map(.parametric_domain[]) }' ${bco_collect_hs} ${bco_report}`
    echo_parametric_domain=`echo $parametric_domain | jq '.parametric_domain'`

    biocomputeobject=$(jo -p\
      bco_spec_version="https://w3id.org/biocompute/1.3.0/" \
      bco_id="https://intelliseq.com/flow/fdb3091e-5420-46b9-b1f6-e6e88e94bac1" \
      provenance_domain=$(jo name=alignment version=1.0 steps="$echo_provenance_domain") \
      execution_domain="$echo_execution_domain" \
      parametric_domain="$echo_parametric_domain" \
    )

    echo "$biocomputeobject" > bco.json

  >>>

  runtime {

    docker: docker_image
    memory: "500M"
    cpu: "1"

  }

  output {

    # @Output(keep=true, outdir="/tmp", filename="stdout.log", description="logs")
    File stdout_log = stdout()
    # @Output(keep=true, outdir="/tmp", filename="stderr.log")
    File stderr_log = stderr()
    # @Output(keep=true, outdir="/tmp", description="")
    File bco = "bco.json"

  }
}








