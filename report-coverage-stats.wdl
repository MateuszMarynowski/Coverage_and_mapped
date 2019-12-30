workflow report_coverage_stats_workflow {

  meta {
    keywords: ["report", "coverage_report"]
    name: 'report_coverage_stats'
    author: 'https://gitlab.com/marysiaa'
    copyright: 'Copyright 2019 Intelliseq'
    description: '## report_coverage_stats \n Generic text for task'
    changes: '{"latest": "no changes"}'

    input_coverage_stats_json: '{"name": "coverage_stats_json", "type": "File", "constraints": {"extension": ["json"]}}'

    output_coverage_report_pdf: '{"name": "coverage_report_pdf", "type": "File", "copy": "True", "description": "Coverage statistics report in pdf file", "constraints": {"extension": ["pdf"]}}'
    output_coverage_report_odt: '{"name": "coverage_report_odt", "type": "File", "copy": "True", "description": "Coverage statistics report in odt file", "constraints": {"extension": ["odt"]}}'
    output_coverage_report_docx: '{"name": "coverage_report_docx", "type": "File", "copy": "True", "description": "Coverage statistics report in docx file", "constraints": {"extension": ["docx"]}}'
    output_coverage_report_html: '{"name": "coverage_report_html", "type": "File", "copy": "True", "description": "Coverage statistics report in html file", "constraints": {"extension": ["html"]}}'
    output_stdout_log: '{"name": "Standard out", "type": "File", "copy": "True", "description": "Console output"}'
    output_stderr_err: '{"name": "Standard err", "type": "File", "copy": "True", "description": "Console stderr"}'
    output_bco: '{"name": "Biocompute object", "type": "File", "copy": "True", "description": "Biocompute object"}'
  }

  call report_coverage_stats

}

task report_coverage_stats {

  File coverage_stats_json
  String index

  String task_name = "report_coverage_stats"
  String task_version = "latest"
  String docker_image = "intelliseqngs/reports:v0.3"

  command <<<
  task_name="${task_name}"; task_version="${task_version}"; task_docker="${docker_image}"
  source <(curl -s https://raw.githubusercontent.com/MateuszMarynowski/coverage_and_mapped/master/after-start.sh)

  printf "{\
    \"task-name\":\"${task_name}\",\
    \"task-version\":\"${task_version}\",\
    \"docker-image\":\"${docker_image}\",\
    \"resources\":$RESOURCES,\
    \"tools\":$TOOLS\
    }" | sed 's/ //g' > bco.json


  /opt/tools/generate-report.sh --json coverage=${coverage_stats_json} --template /opt/tools/templates/coverage-v1/content.xml --name "template"


  source <(curl -s https://raw.githubusercontent.com/MateuszMarynowski/coverage_and_mapped/master/before-finish.sh)
  >>>

  runtime {

    maxRetries: 3
    docker: docker_image
    memory: "1G"
    cpu: "1"

  }

  output {

    File coverage_report_pdf = "template.pdf"
    File coverage_report_odt = "template.odt"
    File coverage_report_docx = "template.docx"
    File coverage_report_html = "template.html"

    File stdout_log = stdout()
    File stderr_log = stderr()
    File bco = "bco.json"

  }

}
