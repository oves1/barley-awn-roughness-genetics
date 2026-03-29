# Primary analysis of genotyping-by-sequencing (GBS) data of barley
# Read mapping, variant calling and filtering
#
# 1. Copying the data and setting up the directory structure

mkdir /path/to/run419
cd /path/to/run419

# samplesheet file
sheet="run419.csv"

# check number of samples
wc -l $sheet

# check duplicate sample names and IDs
cut -f 3 -d , $sheet | sort | uniq -c | awk '$1 != 1' | wc -l
cut -f 2 -d , $sheet | sort | uniq -c | awk '$1 != 1' | wc -l

# path to raw FASTQ files
hsm_path="/path/to/Project_stein"

cut -d, -f 2,3 $sheet | tr , '\t' | sort | uniq | while read id name; do
  sample="Sample_"$name
  mkdir -p $sample
  find $hsm_path/Sample_$id -type f | grep 'gz$' | xargs ln -st $sample
done

# create list of samples
samples="list_run419.txt"
find -type d | grep Sample | cut -d / -f 2 > $samples

wc -l $samples
ls -1 */*fastq.gz | wc -l


# 2. Read mapping and post-processing of mapping results

# copy these scripts into the working directory:
# call_cat_cutadapt_bwa_novosort_csi.zsh
# collect_stats.zsh
# mapping_stats.awk

adapter='AGATCGGAAGAGC'
minlen=30

# reference genome
ref='/path/to/180903_Morex_pseudomolecules_chloro_clean_v4.fasta'

bwa_threads=8
novosort_threads=8
novosort_mem='10G'

mkdir -p tmp
tmpdir='./tmp'

samples="list_run419.txt"

/opt/Bio/parallel/20150222/bin/parallel -a $samples --will-cite -j 8 \
 ./call_cat_cutadapt_bwa_novosort_csi.zsh $adapter $minlen $ref $bwa_threads $novosort_threads $novosort_mem $tmpdir '{}'

# count BAM files and create CSI file list
ls -1 */*.bam | wc -l
ls */*.csi > indexed_csi.txt

# collect mapping statistics
xargs < $samples ./collect_stats.zsh > mapping_stats_run419.tsv


# 3. Variant calling

# copy these scripts into the working directory:
# call_snps.zsh
# call_samtools.zsh

bamlist="bamlist_run419.txt"
find -type f | grep 'bam$' > $bamlist

wc -l $bamlist

prefix="samtools_run419"
ref='/path/to/180903_Morex_pseudomolecules_chloro_clean_v4.fasta'

threads=64
binsize=20
minq=20

./call_snps.zsh $prefix $ref $bamlist $threads $binsize $minq


# 4. Variant filtering

# copy these files into the working directory:
# gen_call.awk
# gencall_run419.conf

config_file="gencall_run419.conf"
gencall_prefix="gencall_run419"

chmod u+x gen_call.awk

zcat $prefix.vcf.gz | ./gen_call.awk $config_file > $gencall_prefix.tsv 2> $gencall_prefix.err

cat $gencall_prefix.err
