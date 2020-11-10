# SexInference
Infer sex from DNA sequencing data and RNA sequencing data

## RNAseq
- Scripts is under `RNAseq`

#### In Human
- General idea: we observed that gene expressions from XIST (female-specific) and Y-linked genes IF1AY, KDM5D, UTY, DDX3Y, and RPS4Y1 are indicative of sex. Therefore, to infer sex from RNAseq data, we fit a logistic regression model using gene expression from these six genes as predictor variables using the GTEx data and predict sex on any new data based on the model build on the GTEx data.
- Below are the steps to infer sex on RNAseq data for any new dataset:

##### Step 1: Download the github repo
- The github repo contains the training data required for the model
```
git clone https://github.com/SexChrLab/SexInference.git
```

##### Step 2: Run quantification using salmon
- You will need to run salmon on your samples but see script `salmon_snakemake.snakefile` for an example of how to set up salmon. 
- The pipeline currently works with the reference transcriptome `gencode.v29.transcripts.fa` (https://www.gencodegenes.org/human/release_29.html). It is important that this version of the reference genome is used when running quantification because we are matching the transcript IDs to the gene IDs for this version of the transcriptome in Step 3. If you are using a different version of the transcriptome, please see where to edit the gene names in Step 3 below. 
#### Step 3: Convert transcript level to gene level
- Because salmon generates counts for transcripts, and because we find that expression at the gene level is clearer for predicting sex, we convert transcript level to gene level for the 6 genes using the script `tximport.R`. This script outputs a CSV file with 7 columns. The first 6 columns are the counts for the genes XIST, IF1AY, KDM5D, UTY, DDX3Y, and RPS4Y1 and the last column is the reported sex. 
- Usage:
    ```
    Rscript tximport.R {path/to/gtf/file} {path/to/samples/name} {quant/dir} {outfile}
    ```

    + Argument 1: path to the `gencode.v29.annotation.gtf` or the annotation that matches with the reference genome to use in Step 1. The matching ID between the transcript and the gene is currently based on gencode v29. **Notes: if you are using a different transcriptome in Step 2, you will need to check if the transcript ID match with the gene ID for these 6 genes. Check lines 38-43 of the script `tximport.R` and modify the transcript ID and gene ID as necessary.**
    + Argument 2: path to the samples name. The first column is the sample name and the second column is the reported sex. See an example under the folder `example_data` (`samples_name.txt`).
    + Argument 3: path to the directory where the quantifications are stored. Right now, this is configured to be in salmon's format. In this directory, the subdirectories are the same as the sample name as indicated by the first column of argument 2. Check line 32 if your directory structure does not match this.
    + Argument 4: path to the output file that will be used in the next step. See an example under the folder `example_data` (`data_for_regression.csv`) 
##### Step 4: Run a logistic regression model
- `sex_inference_model.R`
- Usage:
    ```
    Rscript sex_inference_model.R {path/to/outfile/from/step/3}
    ```
- Currently, this script prints out where there is a discrepancies between the predicted sex and the reported sex. 
- TODO: add option for outputing sex only