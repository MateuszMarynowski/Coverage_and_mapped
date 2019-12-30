workflow collect_hs_metrics_workflow {

  meta {
    keywords: '[metrics, gatk, samtools]'
    name: 'Collect coverage metrics'
    author: 'https://gitlab.com/mremre, https://gitlab.com/moni.krzyz'
    copyright: 'Copyright 2019 Intelliseq'
    description: 'Collects coverage metrics using gatk and samtools.'
    changes: '{"latest": "no changes"}'
    input_intervals: '{"name": "intervals", "type": "File", "extension": "interval_list", "description": "interval list"}'
    input_bam: '{"name": "bam", "type": "File", "extension": "bam", "description": "Alignment result"}'
    input_bai: '{"name": "bai", "type": "File", "extension": "bai", "description": "Alignment result index"}'
    output_final_json: '{"name": "final_json.json", "type": "File", "copy": "True", "description": "json with coverage statistics metrics"}'
    output_simple_json: '{"name": "simple_json.json", "type": "File", "copy": "True", "description": "json with human readable coverage statistics metrics"}'
    output_stdout_log: '{"name": "Standard out", "type": "File", "copy": "True", "description": "Console output"}'
    output_stderr_err: '{"name": "Standard err", "type": "File", "copy": "True", "description": "Console stderr"}'
    output_bco: '{"name": "Biocompute object", "type": "File", "copy": "True", "description": "Biocompute object"}'
  }

  call collect_hs_metrics

}

task collect_hs_metrics {

  File intervals
  File bam_file
  File bai_file


  String task_name = "collect_hs_metrics"
  String task_version = "latest"
  String docker_image = "intelliseqngs/picard:v2.21.4"

  command <<<
  pip install miniwdl
  task_name="${task_name}"; task_version="${task_version}"; task_docker="${docker_image}"
  source <(curl -s https://raw.githubusercontent.com/MateuszMarynowski/coverage_and_mapped/master/after-start.sh)

  java -jar /usr/picard/picard.jar CollectHsMetrics \
      I=${bam_file} \
      O=output_hs_metrics.txt \
      R=/resources/Homo_sapiens_assembly/broad-institute-hg38/Homo_sapiens_assembly38.fa \
      BAIT_INTERVALS=${intervals} \
      TARGET_INTERVALS=${intervals}


  cat output_hs_metrics.txt | sed -n '7p' | sed "s/\t/\n/g" > names.txt
  cat output_hs_metrics.txt | sed -n '8p' | sed "s/\t/\n/g" > values.txt

  echo "[" > hs_metrics.json
  awk 'FNR==NR{a[FNR]=$0;next}{print "{\"name\":\""   a[FNR]  "\",\"value\":\"" $0   "\"}," }' names.txt values.txt >> hs_metrics.json
  sed -i '$ s/,$//g' hs_metrics.json
  echo "]" >> hs_metrics.json

  all=`sed values.txt -n "21p"`
  aligned=`sed values.txt -n "30p"`
  bc -l <<< "$aligned / $all" > result

  source <(curl -s https://raw.githubusercontent.com/MateuszMarynowski/coverage_and_mapped/master/before-finish.sh)
  >>>

  runtime {

    maxRetries: 3
    docker: docker_image
    memory: "1G"
    cpu: "1"

  }

  output {

    File hs_metrics="output_hs_metrics.txt"
    File hs_metrics_json="hs_metrics.json"

    File stdout_log = stdout()
    File stderr_log = stderr()
    File bco = "bco.json"

  }

}
