# Globally, songs and instrumental melodies are slower, higher, and use more stable pitches stable than speech [Stage 2 Registered Report]. 
## Code and source data

Ozaki, Y., Tierney, A., Pfordresher, P. Q., McBride, J., Benetos, E., Proutskouva, P., Chiba, G., Liu, F., Jacoby, N., Purdy, S. C., Opondo, P., Fitch, W. T., Rocamora, M., Thorne, R., Nweke, F., Sadaphal, D., Sadaphal, P., Hadavi, S., Fujii, S., … Savage, P. E. (Accepted In Principle). Globally, songs and instrumental melodies are slower, higher, and use more stable pitches stable than speech [Stage 2 Registered Report]. Peer Community In Registered Reports. Preprint: https://doi.org/10.31234/osf.io/jr9x7 

To run the analyses and create the figures: 

1. Clone this repository.
1. Download the audio files (including video files) from the "Audio recordings" folder on the OSF repository (https://osf.io/mzxc8/).
	- The "audiodir" column of datainfo.csv, datainfo_pyin-praat.csv, datainfo_pyin-subset.csv and datainfo_subset.csv should refer to the directory where you store the audio files.
	- File names contain the multi-byte characters, so please ensure the compatibility when rewriting the csv files otherwise multi-byte characters may be unexpectedly corrupted.
1. Download Hilton et al.'s audio files from their Zenodo repository (https://doi.org/10.5281/zenodo.5525161). Choose the "IDS-corpus-raw.zip".
	- The "audiodir" column of datainfo_Hilton-pyin-20sec.csv, datainfo_Hilton-pyin.csv, datainfo_Hilton-subset-pyin.csv, datainfo_pilot-Hilton-pyin.csv, and datainfo_pilot-Hilton-sa.csv should refer to the directory where you store Hilton et al.'s audio files.
1. Download the audio files of the pilot analysis from the OSF repository (https://osf.io/hw2sp).
	- Move the full-length audio files to /data/Stage 1 RR Audio/full-length/ and the excerpt version to /data/Stage 1 RR Audio/excerpt/.
1. Download the MIR Toolbox (https://www.jyu.fi/hytk/fi/laitokset/mutku/en/research/materials/mirtoolbox). Modify +helper/h_addpath_MIRtoolbox.m accordig to your environment so that the path to MIR Toolbox is appropriately configured.
1. Run the script `run_all.m` (Matlab script) and `run_all.R` (R script). Please run the Matlab script first.
	- `run_all_pilot.m` and `run_all_pilot.R` are the script for the pilot data analyses found in SI.

These above procuedure re-produces the paper's analyses. Please note that some figures in the paper were manually arranged using the outputs of the scripts.

Some Matlab codes use GPU computation and the parallel toolbox to gain efficiency.

This codebase was developed on Matlab 2021b and R 4.2.1.