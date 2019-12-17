workflow merge_bco_workflow { call merge_bco {} }

task merge_bco {
  Array[File] bcos
  Array[Array[File]] bcos_scatter
  Array[File] bcos_scatter_flatten = flatten(bcos_scatter)
  Array[File] stdout
  Array[Array[File]] stdout_scatter
  Array[File] stdout_scatter_flatten = flatten(stdout_scatter)
  String module_name
  String module_version

  # @Input(description="", required="false")
  String task_name = "merge_bco"
  String task_version = "1.0"
  String docker_image = "intelliseqngs/ubuntu-minimal:18.04_v0.2"

  command <<<
  
    provenance_domain=`jq -s '{ steps: map(.provenance_domain.steps[]) }' ${sep=" " bcos} ${sep=" " bcos_scatter_flatten}`
    echo_provenance_domain=`echo $provenance_domain | jq '.steps'`

    execution_domain=`jq -s '{ execution_domain: map(.execution_domain) }' ${sep=" " bcos} ${sep=" " bcos_scatter_flatten}`
    echo_execution_domain=`echo $execution_domain | jq '.execution_domain'`

    parametric_domain=`jq -s '{ parametric_domain: map(.parametric_domain[]) }' ${sep=" " bcos} ${sep=" " bcos_scatter_flatten}`
    echo_parametric_domain=`echo $parametric_domain | jq '.parametric_domain'`
    
    description_domain=`jq -s '{ pipeline_steps: map(.description_domain.pipeline_steps[]) }' ${sep=" " bcos} ${sep=" " bcos_scatter_flatten}`
    echo_description_domain=`echo $description_domain | jq '.pipeline_steps'`

    biocomputeobject=$(jo -p\
      bco_spec_version="https://w3id.org/biocompute/1.3.0/" \
      bco_id="https://intelliseq.com/flow/fdb3091e-5420-46b9-b1f6-e6e88e94bac1" \
      provenance_domain=$(jo name=${module_name} version=${module_version} steps="$echo_provenance_domain") \
      execution_domain="$echo_execution_domain" \
      parametric_domain="$echo_parametric_domain" \
      description_domain=$(jo pipeline_steps="$echo_description_domain") \
    )

    echo "$biocomputeobject" > bco.json
    
    cat ${sep=" " stdout} ${sep=" " stdout_scatter_flatten} > stdout

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








