task cov_and_map {
    File input_file
    String output_file
    command {
        python /Statistics.py ${input_file} ${output_file}
    }
    runtime {
        docker: 'mateuszmarynowski/cov_and_map:latest'
    }
    output {
	File results = "${output_file}"
    }
}

workflow bam_file {
    call cov_and_map
}
