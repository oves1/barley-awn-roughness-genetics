#!/bin/zsh

parallel='/opt/Bio/parallel/20160322/bin/parallel'
vcfutils='/opt/Bio/samtools/0.1.19/bin/bcftools/vcfutils.pl'
tabix='/opt/Bio/tabix/0.2.6/bin/tabix'
bgzip='/opt/Bio/bcftools/1.6/bin/bgzip'

prefix=$1
shift
ref=$1
shift
bamlist=$1
shift
threads=$1
shift
binsize=$1
shift
minq=$1

echo $[ $binsize * 1000000] | tr -d . | read binsize

vcf="${prefix}.vcf.gz"

{
 $vcfutils splitchr -l $binsize $ref.fai \
  | $parallel -k -j $threads -I'{}' ./call_samtools.zsh $ref $bamlist $minq '{}' \
  | awk '!header || !/^#/ {print} /^#CHROM/ {header=1}' \
  | $bgzip > $vcf && $tabix -p vcf $prefix.vcf.gz
} 2> $prefix.vcf.err 
