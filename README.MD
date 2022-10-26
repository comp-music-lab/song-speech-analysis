# Sequence alignment of folk song melodies reveals cross-cultural mechanisms of musical evolution. 
## Code and source data

Savage, P. E., Passmore, S., Chiba, G., Currie, T. E., Suzuki, H., & Atkinson, Q. D. (2020). Sequence alignment of folk song melodies reveals cross-cultural mechanisms of musical evolution. PsyArXiv Preprint. https://doi.org/10.31234/osf.io/5rj6y

To run the analyses: first clone the repository, and then run the script `MelodicEvo.R` in R or R Studio. 

This script re-produces the paper's main analyses, as well as several tests of the main effects on different data subsets.
Result files and figures are not included by default. 

The scripts `analysis/PID.R` and `analysis/Dist.R` are commented out because they have been pre-calculated. To recalculate distance matrices and re-identify highly related pairs, re-run these scripts after downloading the full English and Japanese distance matrices from https://osf.io/nhvzw/. This will take up to a month on a personal computer. 

All analyses was run using R v4.1. To ensure results are accurately re-produced, please check that all packages used match those used in the reported results. These details are held in `sessionInfo.txt`. 

### Troubleshooting

Some packages used in this analysis require some coercion to be installed. For these packages, we reccomend referring to their maintainer instructions. 
Packages that are known to be difficult are:

- brms: https://github.com/paul-buerkner/brms
- rnaturalhires: https://github.com/ropensci/rnaturalearth