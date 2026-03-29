#!/bin/zsh

samtools='/opt/Bio/samtools/1.7/bin/samtools'
bcftools='/opt/Bio/bcftools/1.6/bin/bcftools'

ref=$1
shift
bamlist=$1
shift
minq=$1
shift
reg=$1

$samtools mpileup -q $minq -gDVu -b $bamlist -r $reg -f $ref \
  | $bcftools call -mv -f GQ - 

