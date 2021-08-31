################## Rules used to map the data with STAR ##################

rule star_index:
    input:
        fasta = WORKING_DIR + "reference.fa",
        gtf =   WORKING_DIR + "annotation.gtf"
    output:
         genome_index = [WORKING_DIR + "genome/" + f for f in ["chrLength.txt","chrNameLength.txt","chrName.txt","chrStart.txt","Genome","genomeParameters.txt","SA","SAindex"]]
    message:
        "generating STAR genome index"
    params:
        genome_dir = WORKING_DIR + "genome/",
        sjdb_overhang = config["star_index"]["sjdbOverhang"],
    threads: 10
    resources: mem_mb=100000
    shell:
        "mkdir -p {params.genome_dir}; " # if directory not created STAR will ask for it
        "STAR --runThreadN {threads} "
        "--runMode genomeGenerate "
        "--genomeDir {params.genome_dir} "
        "--genomeFastaFiles {input.fasta} "
        "--sjdbGTFfile {input.gtf} "
        "--sjdbOverhang {params.sjdb_overhang} "

rule map_to_genome_using_STAR:
    input:
        genome_index = rules.star_index.output,
        forward_read = WORKING_DIR + "trimmed/" + "{sample}_R1_trimmed.fq.gz",
        reverse_read = WORKING_DIR + "trimmed/" + "{sample}_R2_trimmed.fq.gz",
        gtf =   WORKING_DIR + "annotation.gtf"
    output:
        RESULT_DIR + "star/{sample}_Aligned.sortedByCoord.out.bam",
        RESULT_DIR + "star/{sample}_Log.final.out"
    message:
        "mapping {wildcards.sample} reads to genome"
    params:
        sample_name           =  "{sample}",
        star_input_file_names =  get_star_names,
        prefix                =  RESULT_DIR + "star/{sample}_",
        maxmismatches         =  config["star"]["mismatches"],
        unmapped              =  config["star"]["unmapped"]   ,
        multimappers          =  config["star"]["multimappers"],
        matchNminoverLread    =  config["star"]["matchminoverlengthread"],
        outSamType            =  config["star"]["samtype"],
        outSAMattributes      =  config["star"]["samattributes"],
        intronmax             =  config["star"]["intronmax"],
        matesgap              =  config["star"]["matesgap"],
        genome_index          =  WORKING_DIR + "genome/",
        sjdbOverhang          =  config["star"]["sjdbOverhang"],
        winAnchorMultimapNmax =  config["star"]["winAnchorMultimapNmax"]    
    threads: 10
    resources: cpus=10
    shell:
        "STAR --runThreadN 12 --genomeDir {params.genome_index} --sjdbGTFfile {input.gtf} \
        --sjdbOverhang {params.sjdbOverhang} --readFilesIn {params.star_input_file_names} \
        --readFilesCommand zcat --winAnchorMultimapNmax {params.winAnchorMultimapNmax} \
        --outFilterMultimapNmax {params.multimappers} \
        --runThreadN {threads}  --outReadsUnmapped {params.unmapped} \
        --outFileNamePrefix {params.prefix} --outSAMtype {params.outSamType} "

     