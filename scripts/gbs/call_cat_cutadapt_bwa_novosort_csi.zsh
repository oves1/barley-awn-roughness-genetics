#!/bin/zsh

setopt globsubst
setopt extendedglob 

adapter=$1
shift
minlen=$1
shift
ref=$1
shift
bwa_threads=$1
shift
novosort_threads=$1
shift
novosort_mem=$1
shift
tmpdir=$1
shift

i=$1

cutadapt='/opt/Bio/cutadapt/1.15/bin/cutadapt'
bwa="/opt/Bio/bwa/0.7.17/bin/bwa"
samtools='/opt/Bio/samtools/1.7/bin/samtools'
novosort="/opt/Bio/novocraft/V3.06.05/bin/novosort"

base=$i/$i:t
bam=${base}.bam
stats=${base}_mapping_stats.tsv

cutadapterr=${base}_cutadapt.err
bwaerr=${base}_bwa.err
samtoolserr=${base}_samtools.err
novosorterr=${base}_novosort.err
statserr=${base}_mapping_stats.err

b=$base:t
rgentry="@RG\tID:$b\tPL:ILLUMINA\tPU:$b\tSM:$b"
 
$cutadapt -m $minlen -a $adapter -f fastq 2> $cutadapterr \
 <(find $i | grep 'fastq.gz$' | sort | xargs zcat) \
 | $bwa mem -R $rgentry -M -t $bwa_threads $ref /dev/stdin 2> $bwaerr \
 | $samtools view -Su /dev/stdin 2> $samtoolserr \
 | $novosort -t $tmpdir -c $novosort_threads -m $novosort_mem -o $bam /dev/stdin 2> $novosorterr 

echo $pipestatus | tee ${base}_pipestatus.txt \
 | tr ' ' '\n' | grep -q '^[^0$]' || { 
 $samtools index -c $bam 
 $samtools view $bam | ./mapping_stats.awk -v SE=1
} > $stats 2> $statserr
