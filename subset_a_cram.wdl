version 1.0

workflow SubSetWorkflow {
  input {
    File cram_file
    File crai_file
    String ID

    String docker

    Int chromosome = 6
    Int start_pos = -1
    Int end_pos = -1

    Int memory = 200
    Int disk = 200
    Int cpu = 4
    Int maxRetries = 1
  }

  call SubsetCRAM {
    input:
      cram_file = cram_file,
      crai_file = crai_file,
      ID = ID,
      chromosome = chromosome,
      start_pos = start_pos,
      end_pos = end_pos,
      docker = docker,
      memory = memory,
      disk = disk,
      cpu = cpu,
      maxRetries = maxRetries
  }

  output {
    File subset_cram = SubsetCRAM.subset_cram
  }
}

task SubsetCRAM {
  input {
    File cram_file
    File crai_file
    String ID
    Int chromosome
    Int start_pos
    Int end_pos
    String docker
    Int memory
    Int disk
    Int cpu
    Int maxRetries
  }

  command <<<
    set -euo pipefail

    cram_basename=$(basename ~{cram_file})
    crai_basename=$(basename ~{crai_file})
    subset_filename="~{ID}_subset.cram"

    echo "Linking cram/crai into working dir..."
    ln -s ~{cram_file} .
    ln -s ~{crai_file} .
    ln -s /app/subset_cram.py .

    echo "Subsetting cram file..."
    python subset_cram.py \
      --input_file $cram_basename \
      --output_file $subset_filename \
      --chrom ~{chromosome} \
      --threads ~{cpu} \
      ~{if start_pos != -1 then "--start " + start_pos else ""} ~{if end_pos != -1 then "--end " + end_pos else ""} 
  >>>

  output {
    File subset_cram = "~{ID}_subset.cram"
  }

  runtime {
    docker: "~{docker}"
    maxRetries: "~{maxRetries}"
    cpu: "~{cpu}"
    memory: "~{memory} GB"
    disks: "local-disk ~{disk} HDD"
  }
}