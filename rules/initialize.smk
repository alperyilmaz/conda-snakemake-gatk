import os

configfile: "config.yaml"

extensions=['.fa.amb','.fa.fai','.dict']
GENOMEBASE=os.path.splitext(config["ref"]["genome"])[0]

rule all:
    input: [GENOMEBASE+ext for ext in extensions]

rule initialize_index:
    input:
        config["ref"]["genome"]
    output:
        GENOMEBASE+".fa.amb"
    wrapper:
        "0.27.1/bio/bwa/index"

rule initialize_fa_index:
    input:
        config["ref"]["genome"]
    output:
        GENOMEBASE+".fa.fai"
    conda:
        "../envs/samtools.yaml"
    shell:
        "samtools faidx {input}"

exists = os.path.isfile(GENOMEBASE+".dict")
if exists:
    print("Dictionary file already exists! Skipping this step. If dictionary file is intended to be re-generated please delete current dictionary file")
else:
    rule generate_dictionary:
         input:
            config["ref"]["genome"]
         output:
            GENOMEBASE+".dict"
         conda:
            "../envs/gatk.yaml"
         shell:
            "gatk CreateSequenceDictionary -R {input}"

