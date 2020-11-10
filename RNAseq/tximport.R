# Please install the package "GenomicFeatures" if it's not installed already, by uncomment these following lines. 
# if (!requireNamespace("BiocManager", quietly = TRUE))
#   install.packages("BiocManager")
# BiocManager::install("GenomicFeatures")

library(tximport)
library(GenomicFeatures)
library(tidyr)

gtf_file = "/data/CEM/shared/public_data/references/GENCODE/gencode.v29.annotation.gtf"
samples_name = "/scratch/tphung3/SexInference/RNAseq/samples_name.txt"
quant_dir = "/scratch/tphung3/SexInference/RNAseq/placenta_batch_1/"
outfile = "/scratch/tphung3/SexInference/RNAseq/placenta_batch_1_data_for_regression.csv"

txdb = makeTxDbFromGFF(gtf_file)

k = keys(txdb, keytype = "TXNAME")

# write output with gene ID and transcript ID   
tx2gene = select(txdb, k, "GENEID", "TXNAME") 
# head(tx2gene)

samples_df = read.csv(samples_name)

files <- file.path(quant_dir, samples_df$sample, "quant.sf")
names(files) <- paste0(samples_df$sample)
txi.salmon <- tximport(files, type = "salmon", tx2gene = tx2gene, ignoreAfterBar=T)

counts_df = as.data.frame(txi.salmon$counts)
counts_df$gene_id = rownames(counts_df)

XIST = subset(counts_df, counts_df$gene_id=="ENSG00000229807.11")
EIF1AY = subset(counts_df, counts_df$gene_id=="ENSG00000198692.9")
KDM5D = subset(counts_df, counts_df$gene_id=="ENSG00000012817.15")
UTY = subset(counts_df, counts_df$gene_id=="ENSG00000183878.15")
DDX3Y = subset(counts_df, counts_df$gene_id=="ENSG00000067048.16")
RPS4Y1 = subset(counts_df, counts_df$gene_id=="ENSG00000129824.15")

nsample = nrow(samples_df)

XIST_long <- gather(XIST[1:nsample], factor_key=TRUE)
colnames(XIST_long) = c("sample_ids", "XIST")

EIF1AY_long <- gather(EIF1AY[1:48], factor_key=TRUE)
colnames(EIF1AY_long) = c("sample_ids", "EIF1AY")

KDM5D_long <- gather(KDM5D[1:48], factor_key=TRUE)
colnames(KDM5D_long) = c("sample_ids", "KDM5D")

UTY_long <- gather(UTY[1:48], factor_key=TRUE)
colnames(UTY_long) = c("sample_ids", "UTY")

DDX3Y_long <- gather(DDX3Y[1:48], factor_key=TRUE)
colnames(DDX3Y_long) = c("sample_ids", "DDX3Y")


RPS4Y1_long <- gather(RPS4Y1[1:48], factor_key=TRUE)
colnames(RPS4Y1_long) = c("sample_ids", "RPS4Y1")

data = data.frame(XIST_long$XIST, EIF1AY_long$EIF1AY, KDM5D_long$KDM5D, UTY_long$UTY, DDX3Y_long$DDX3Y, RPS4Y1_long$RPS4Y1, samples_df$sex)
colnames(data) = c("XIST","EIF1AY","KDM5D","UTY","DDX3Y","RPS4Y1","sex")

write.table(data, oufile, quote = F, row.names = F, sep=",")

# ggplot(RPS4Y1_long, aes(x = sex, y = value, color = sex)) +
#   geom_violin() + scale_color_manual(values = c("#66C2A5",  "#FC8D62")) +
#   theme_bw() +
#   geom_boxplot(width = 0.1, outlier.shape = NA) + 
#   geom_jitter(aes(shape = factor(sex)),
#               size = 3,
#               position = position_jitter(0.1)) +
#   theme(legend.position = "none") +
#   theme(axis.title.x=element_text(size=15), 
#         axis.text.x=element_text(size=12)) +
#   theme(axis.title.y=element_text(size=15),
#         axis.text.y=element_text(size=12)) +
#   theme(axis.title=element_text(size=15)) +
#   theme(legend.text=element_text(size=12)) +
#   theme(legend.title=element_text(size=15)) +
#   stat_compare_means(method = "t.test",
#                      label.x = 1.2,
#                      label.y.npc = 1) +
#   labs(y = "Counts", title="RPS4Y1")