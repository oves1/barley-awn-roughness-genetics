# QTL analysis for awn roughness in barley
# Study: Genetic control of awn roughness in barley
#
# This script performs:
# 1. Import of cross data
# 2. Basic phenotype/genotype inspection
# 3. Recombination fraction estimation and linkage-group inference
# 4. Map export
# 5. Single-QTL scan using Haley-Knott regression
# 6. Composite interval mapping (CIM)
# 7. Permutation-based significance testing
# 8. Confidence interval estimation and effect plots
#
# Notes:
# - Update INPUT_DIR and INPUT_FILE before running.
# - The script assumes phenotype column 1 contains awn roughness.
# - The cleaned linkage-group object is used for downstream QTL analysis.

if (!requireNamespace("qtl", quietly = TRUE)) {
  stop("Package 'qtl' is required. Install it with install.packages('qtl').")
}

library(qtl)

# User settings
INPUT_DIR <- "path/to/data"
INPUT_FILE <- "F2_597_7H_rqtl.csv"
INPUT_SEP <- ";"

PHENO_COL <- 1
STEP_SIZE <- 2.5

MAX_RF_PREVIEW <- 0.35
MIN_LOD_PREVIEW <- 3
MAX_RF_FINAL <- 0.07
MIN_LOD_FINAL <- 6

CIM_N_MARCOVAR <- 3
CIM_WINDOW <- 0.01
MAP_FUNCTION <- "kosambi"

N_PERM <- 1000
ALPHA_LEVELS <- c(0.05, 0.20)

QTL_CHR <- 7
QTL_POS <- 520

MAP_TABLE_FILE <- "mhor597_linkage_map.csv"
CIM_PLOT_FILE <- "mhor597_cim_plot.pdf"
PERM_PLOT_FILE <- "mhor597_permutation_plot.pdf"
PXG_PLOT_FILE <- "mhor597_peak_marker_pxg.pdf"
EFFECT_PLOT_FILE <- "mhor597_peak_marker_effectplot.pdf"

# Read cross data
cross_obj <- read.cross(
  format = "csv",
  dir = INPUT_DIR,
  file = INPUT_FILE,
  sep = INPUT_SEP
)

cross_obj <- jittermap(cross_obj)

# Basic summaries
print(summary(cross_obj))
geno.image(cross_obj)
plotPheno(cross_obj, pheno.col = PHENO_COL)

# Estimate recombination fractions
cross_rf <- est.rf(cross_obj)

lg_preview <- formLinkageGroups(
  cross = cross_rf,
  max.rf = MAX_RF_PREVIEW,
  min.lod = MIN_LOD_PREVIEW
)

print(table(lg_preview[, 2]))

cross_lg <- formLinkageGroups(
  cross = cross_rf,
  max.rf = MAX_RF_FINAL,
  min.lod = MIN_LOD_FINAL,
  reorgMarkers = TRUE
)

lg1_markers <- markernames(cross_lg, chr = 1)
print(lg1_markers)

# Export map table
map_table <- map2table(pull.map(cross_lg))
write.table(map_table, file = MAP_TABLE_FILE, sep = ",", row.names = FALSE)

# Calculate genotype probabilities
cross_genoprob <- calc.genoprob(cross_lg, step = STEP_SIZE)

# Single-QTL scan
scan_hk <- scanone(cross_genoprob, method = "hk")

# Composite interval mapping
scan_cim <- cim(
  cross_genoprob,
  n.marcovar = CIM_N_MARCOVAR,
  window = CIM_WINDOW,
  method = "hk",
  map.function = MAP_FUNCTION
)

pdf(CIM_PLOT_FILE)
plot(scan_cim)
dev.off()

# Permutation test
perm_hk <- scanone(cross_genoprob, method = "hk", n.perm = N_PERM)

pdf(PERM_PLOT_FILE)
plot(perm_hk)
dev.off()

print(summary(perm_hk))
print(summary(perm_hk, alpha = ALPHA_LEVELS))
print(summary(scan_cim, perms = perm_hk, alpha = 0.20, pvalues = TRUE))

# Confidence intervals
print(lodint(scan_cim, chr = QTL_CHR))
print(bayesint(scan_cim, chr = QTL_CHR))

print(lodint(scan_cim, chr = QTL_CHR, expandtomarkers = TRUE))
print(bayesint(scan_cim, chr = QTL_CHR, expandtomarkers = TRUE))

# Peak marker and effect plots
print(max(scan_cim, chr = QTL_CHR))

peak_marker <- find.marker(cross_genoprob, chr = QTL_CHR, pos = QTL_POS)
print(peak_marker)

pdf(PXG_PLOT_FILE)
plotPXG(cross_genoprob, marker = peak_marker)
dev.off()

pdf(EFFECT_PLOT_FILE)
effectplot(cross_genoprob, mname1 = peak_marker)
dev.off()
