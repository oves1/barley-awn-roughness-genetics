# Epistasis analysis of Raw1 and Raw7 for awn barb traits in barley
#
# This script can be used for:
# - basal barb count
# - central barb count
# - basal barb size
# - central barb size
#
# Genotype class format:
# Each column represents one genotype combination of Raw1 and Raw7.
# Naming convention (4 characters):
#   First two letters -> Raw1 genotype (AA, Aa, aa)
#   Last two letters  -> Raw7 genotype (BB, Bb, bb)
#
# Examples:
#   AABB -> homozygous dominant at both loci
#   AaBb -> heterozygous at both loci
#   aaBB -> recessive Raw1, dominant Raw7
#
# Total expected combinations: 9 (3 x 3)

library(data.table)
library(stringi)
library(magrittr)
library(dplyr)
library(multcompView)

# set folder containing the input file
setwd("path/to/your/folder")

# read data (wide format: each column = genotype class)
c <- fread("data-file.csv") %>%
  melt(value.name = "n", variable.name = "gt", measure.vars = colnames(.)) %>%
  .[!is.na(n), ]

# split genotype into Raw1 (A) and Raw7 (B)
c[, gtA := substr(gt, 1, 2)]
c[, gtB := substr(gt, 3, 4)]

# predictor variables
c[, doseA := stringi::stri_count(gt, regex = "A")]
c[, doseB := stringi::stri_count(gt, regex = "B")]

# additive and dominance encoding
c[, Additive.Marker.A := doseA - 1]
c[, Additive.Marker.B := doseB - 1]
c[, Dominance.Marker.A := as.integer(doseA == 1)]
c[, Dominance.Marker.B := as.integer(doseB == 1)]

# linear model (epistasis)
lm0 <- lm(
  n ~ Additive.Marker.A +
    Dominance.Marker.A +
    Additive.Marker.B +
    Dominance.Marker.B +
    Additive.Marker.A * Additive.Marker.B +
    Additive.Marker.A * Dominance.Marker.B +
    Additive.Marker.B * Dominance.Marker.A +
    Dominance.Marker.A * Dominance.Marker.B,
  data = c
)

summary(lm0)
anova(lm0)

# ANOVA by genotype class
anova1 <- aov(n ~ gt, data = c)
summary(anova1)

# Tukey HSD
tukey <- TukeyHSD(anova1)
print(tukey)

# compact letter display
cld <- multcompLetters4(anova1, tukey)
cld <- as.data.frame.list(cld$gt)

# summary table
Tk <- group_by(c, gt) %>%
  summarise(
    mean = mean(n),
    quant = quantile(n, probs = 0.75)
  ) %>%
  arrange(desc(mean))

Tk$cld <- cld$Letters
print(Tk)

# save summary table
write.csv(Tk, "epistasis_summary.csv", row.names = FALSE)