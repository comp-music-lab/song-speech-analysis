# Similarities and differences in a global sample of song and speech recordings [Stage 1 Registered Report]. 
## Code and source data

Yuto, O., Tierney, A., Pfordresher, P. Q., McBride, J., Benetos, E., Proutskouva, P., Chiba, G., Liu, F., Jacoby, N., Purdy, S. C., Opondo, P., Fitch, W. T., Hedge, S., Rocamora, M., Thorne, R., Nweke, F., Sadaphal, P., Sadaphal, D., Hadavi, S., ... Savage, P. E. (2022). Similarities and differences in a global sample of song and speech recordings [Stage 1 Registered Report]. https://doi.org/10.31234/osf.io/5rj6y

To run the analyses and create the figures: first clone the repository, and then run the script `run_all.m` (Matlab script) and `run_all.R` (R script). Please run the Matlab script first.

These scripts re-produce the registered report's analyses. Please note that some figures in the registered report were manually arranged using the outputs of the scripts.

The audio files are available at https://osf.io/mzxc8/. Please download the audio files from here. Please locate all original audio files under /data/Stage 1 RR Audio/full-length/ and their excerpt version under /data/Stage 1 RR Audio/excerpt/.

You need to install MIR Toolbox when running the script. Please modify +helper/h_addpath_MIRtoolbox.m accordig to your environment so that the path to MIR Toolbox is appropriately configured.

Some Matlab codes use GPU computation and the parallel toolbox to gain efficiency.

This codebase was developed on Matlab 2021b and R 4.2.1.