import argparse
import subprocess
import os

class ReadsMapped:
    def __init__(self, bam_path, chr, bam_subset_path, bam_stats):
        self.bam_path = bam_path
        self.chr = chr
        self.bam_subset_path = bam_subset_path
        self.bam_stats = bam_stats

    def subset_bam_by_chr(self):
        command_line = "samtools view -b {bam} {chr} > {bam_subset}".format(
            bam=self.bam_path, chr=self.chr, bam_subset=self.bam_subset_path)
        subprocess.check_output(command_line, shell=True)

    def compute_bam_stats(self):
        command_line = "samtools stats {bam_subset} | grep ^SN | cut -f 2- > {bam_stats}".format(
            bam_subset=self.bam_subset_path, bam_stats=self.bam_stats
        )
        subprocess.check_output(command_line, shell=True)

    def return_reads_mapped(self):
        with open(self.bam_stats, "r") as f:
            for line in f:
                if line.startswith("reads mapped and paired"):
                    return line.rstrip("\n").split("\t")[1]

def classify_sex(X_19_ratio, Y_19_ratio, Y_X_ratio):
    """
    This function roughly classifies sex based on reads mapped ratio between X and 19, Y and 19, and Y and X
    :param X_19_ratio:
    :param Y_19_ratio:
    :param Y_X_ratio:
    :return: either "male" or "female"
    """
    if X_19_ratio >= 0.5 and Y_19_ratio <= 0.01 and Y_19_ratio <= 0.01:
        return "probable_XX"
    else:
        return "probable_XY"

def main(args):

    # Check if output directory exists
    if os.path.isdir(args.out_dir) == False:
        os.mkdir(args.out_dir)
    if os.path.isdir(os.path.join(args.out_dir, args.sample)) == False:
        os.mkdir(os.path.join(args.out_dir, args.sample))

    outfile = open(os.path.join(args.out_dir, args.sample, args.sample + "_summary.tsv"), "w")
    # Initilize the header
    header = ["sample", "chr19", "chrX", "chrY", "X/19", "Y/19", "Y/X", "sex_prediction"]
    print("\t".join(header), file=outfile)

    # Initilize the output row
    out = [args.sample]

    chr = ["chr19", "chrX", "chrY"]
    for i in chr:
        bam_subset_path = os.path.join(args.out_dir, args.sample, i + "_bam_subset.bam")
        bam_stat = os.path.join(args.out_dir, args.sample, i + "_bam_stat.txt")
        reads_mapped = ReadsMapped(args.bam_path, i, bam_subset_path, bam_stat)
        reads_mapped.subset_bam_by_chr()
        reads_mapped.compute_bam_stats()
        out.append(reads_mapped.return_reads_mapped())

        # remove intermediate files (bam subsetted)
        os.remove(os.path.join(args.out_dir, args.sample, i + "_bam_subset.bam"))

    X_19_ratio = float(out[2])/float(out[1])
    Y_19_ratio = float(out[3])/float(out[1])
    Y_X_ratio = float(out[3])/float(out[2])

    out.extend([str(X_19_ratio), str(Y_19_ratio), str(Y_X_ratio), classify_sex(X_19_ratio, Y_19_ratio, Y_X_ratio)])
    print("\t".join(out), file=outfile)

def parse_args():
    parser = argparse.ArgumentParser(description="")
    parser.add_argument("--sample", required=True, help="Input the sample name. The sample name is used to create a directory to store outputs")
    parser.add_argument("--bam_path", required=True, help="Input the path to the bam file")
    parser.add_argument("--out_dir", required=True, help="Input the path to where all the results should be stored.")

    return parser.parse_args()


# if __name__ == "__main__":
main(parse_args())