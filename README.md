# Genetic control of awn roughness in barley

This repository contains the analysis scripts used in the study:

**"Genetic control of awn roughness in barley"**

## Overview

Awn roughness in barley (*Hordeum vulgare*) is determined by silicified trichomes (barbs) on the awn surface. This study identifies and validates two genes, **Raw1** (5H) and **Raw7** (7H), and demonstrates their epistatic interaction in controlling barb formation.

## Repository contents

- `scripts/` – GBS processing, mapping, SNP calling, filtering, QTL and epistasis analysis   

## Workflow summary

1. GBS read trimming, mapping, and BAM processing  
2. Mapping statistics extraction  
3. SNP calling and genotype filtering  
4. QTL analysis in R using the `qtl` package  
5. Epistasis analysis using linear models, ANOVA, and Tukey’s HSD  

## Genotype classes

Genotype classes are encoded using a 4-letter format:

- First two letters → **Raw1** genotype (AA, Aa, aa)  
- Last two letters → **Raw7** genotype (BB, Bb, bb)  

Examples:
- `AABB` – homozygous dominant at both loci  
- `AaBb` – heterozygous at both loci  
- `aaBB` – recessive Raw1, dominant Raw7  

Total combinations: 9 (3 × 3)

## Requirements

- BWA  
- SAMtools / BCFtools  
- Novosort  
- GNU Parallel  
- R (package: `qtl`)  

## Usage

Update file paths and run scripts sequentially in the `scripts/` directory.

## Citation

[Add manuscript citation here after publication]

## Contact

Muhammad Awais  
[Add institutional email]
