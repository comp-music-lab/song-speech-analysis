# Globally, songs and instrumental melodies are slower, higher, and use more stable pitches stable than speech [Stage 2 Registered Report]. 
## Code and source data

Ozaki, Y., Tierney, A., Pfordresher, P. Q., McBride, J., Benetos, E., Proutskouva, P., Chiba, G., Liu, F., Jacoby, N., Purdy, S. C., Opondo, P., Fitch, W. T., Rocamora, M., Thorne, R., Nweke, F., Sadaphal, D., Sadaphal, P., Hadavi, S., Fujii, S., Choo, S., Naruse, M., Ehara, U., Sy, L., Parselelo, M. L., Anglada-Tort, M., Hansen, N. Chr., Haiduk, F., Færøvik, U., Magalhães, V., Krzyżanowski, W., Shcherbakova, O., Hereld, D., Barbosa, B. S., Varella M. A. C., van Tongeren, M., Dessiatnitchenko, P., Zar Zar, S., El Kahla, I., Muslu, O., Troy, J., Lomsadze, T., Kurdova, D., Tsope, C., Fredriksson, D., Arabadjiev, A., Sarbah, J. P., Arhine, A., Ó Meachair, T., Silva-Zurita, J., Soto-Silva, I., Millalonco, N. E. M., Ambrazevičius, R., Loui, P., Ravignani, A., Jadoul, Y., Larrouy-Maestri, P., Bruder, C., Teyxokawa, T. P., Kuikuro, K., Natsitsabui, R., Sagarzazu, N. B., Raviv, L., Zeng, M., Varnosfaderani, S. D., Gómez-Cañón, J. S., Kolff, K., Vanden Bosch der Nederlanden, C., Chhatwal, M., David R. M., I Putu Gede Setiawan, Lekakul, G., Borsan, V. N., Nguqu, N., & Savage, P. E. (2024). Globally, songs and instrumental melodies are slower, higher, and use more stable pitches than speech: A Registered Report. Science Advances.  https://doi.org/10.1126/sciadv.adm9797

To run the analyses and create the figures: 

1. Clone this repository.
1. Download the audio files (including video files) from the "Audio recordings" folder on the OSF repository (https://osf.io/mzxc8/).
	- The "audiodir" column of datainfo.csv, datainfo_pyin-praat.csv, datainfo_pyin-subset.csv and datainfo_subset.csv should refer to the directory where you store the audio files.
	- File names contain multi-byte characters, so please ensure compatibility when rewriting the csv files. Otherwise, multi-byte characters may be unexpectedly corrupted.
1. Download Hilton et al.'s audio files from their Zenodo repository (https://doi.org/10.5281/zenodo.5525161). Choose the "IDS-corpus-raw.zip".
	- The "audiodir" column of datainfo_Hilton-pyin-20sec.csv, datainfo_Hilton-pyin.csv, datainfo_Hilton-subset-pyin.csv, datainfo_pilot-Hilton-pyin.csv, and datainfo_pilot-Hilton-sa.csv should refer to the directory where you store Hilton et al.'s audio files.
1. Download the audio files of the pilot analysis from the OSF repository (https://osf.io/hw2sp).
	- Move the full-length audio files to /data/Stage 1 RR Audio/full-length/ and the excerpt version to /data/Stage 1 RR Audio/excerpt/.
1. Download the MIR Toolbox (https://www.jyu.fi/hytk/fi/laitokset/mutku/en/research/materials/mirtoolbox). Modify +helper/h_addpath_MIRtoolbox.m according to your environment so that the path to MIR Toolbox is appropriately configured.
1. Run the script `run_all.m` (Matlab script) and `run_all.R` (R script). Please run the Matlab script first.
	- `run_all_pilot.m` and `run_all_pilot.R` are the scripts for the pilot data analyses found in SI.

The above procedure reproduces the paper's analyses. Please note that some figures in the paper were manually arranged using the outputs of the scripts.

Some Matlab codes use GPU computation and the parallel toolbox to gain efficiency.

This codebase was developed on Matlab 2021b and R 4.2.1.