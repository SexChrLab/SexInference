configfile: "placenta_batch_1_config.json"
rule all:
    input:
        expand("placenta_batch_1/{sample}/quant.sf", sample=config["all_samples"])
rule salmon:
    input:
        fq1 = lambda wildcards: config[wildcards.sample]["fq_1"],
        fq2 = lambda wildcards: config[wildcards.sample]["fq_2"]
    output:
        "placenta_batch_1/{sample}/quant.sf"
    params:
        out_dir = "{sample}",

    shell:
        """
        salmon quant -i reference_index/gencode.v29.transcripts.index -l A -1 {input.fq1} -2 {input.fq2} -p 8 --validateMappings -o placenta_batch_1/{params.out_dir}
        """
