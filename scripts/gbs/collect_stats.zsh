#!/bin/zsh

echo -n "#sample\tall_reads\ttrimmed_reads\treads_in_bam\tmapped_reads"
echo "\tq10\tq20\tq30\tq40\tq50\tq60"

for i in $*; do
 base=$i/$i
 echo -n $i"\t"
 cat ${base}_cutadapt.err | grep -m 1 "^Total reads processed:" \
  | awk -F: '{printf $2"\t"}' | tr -d ', '
 cat ${base}_cutadapt.err | grep -m1 'Reads written (passing filters):' \
  | awk -F: '{print $2}' | tr -d ', ' | cut -d '(' -f 1 | tr '\n' '\t'
 cut -f 2 ${base}_mapping_stats.tsv | xargs | tr '  ' '\t'
done 
