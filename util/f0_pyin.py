import librosa
import numpy as np
import datetime

def get_f0(dataname):
    ####
    audiodir = r'G:\Datasets\Hilton\IDS-corpus-raw\IDS-corpus-raw' + '\\'
    outputdir = r'C:\Users\yuto\Documents\MATLAB\projects\song-speech-analysis\data\Automated F0' + '\\'

    N = 2048
    M = 512

    ####
    for d in dataname:
        print(datetime.datetime.now().isoformat() + " - " + d)

        ####
        audiofilepath = audiodir + d + ".wav"
        y, sr = librosa.load(audiofilepath, mono=True)
        f0, voiced_flag, voiced_probs = librosa.pyin(y, sr=sr, fmin=25, fmax=2048, frame_length=N, hop_length=M)
        t = librosa.times_like(f0, sr=sr, hop_length=M)

        f0[np.isnan(f0)] = 0

        ####
        outputfilepath = outputdir + d + "_f0.csv"
        np.savetxt(outputfilepath, np.vstack([t, f0]).transpose(), delimiter=',', header="time,voice_1", comments="")

    print(datetime.datetime.now().isoformat() + " - done")

if __name__ == "__main__":
    dataname = ["ACO02A", "ACO02B", "ACO02C", "ACO02D",
                "ACO05A", "ACO05B", "ACO05C", "ACO05D",
                "ACO09A", "ACO09B", "ACO09C", "ACO09D",
                "BEJ01A", "BEJ01B", "BEJ01C", "BEJ01D",
                "BEJ16A", "BEJ16B", "BEJ16C", "BEJ16D",
                "BEJ21A", "BEJ21B", "BEJ21C", "BEJ21D",
                "WEL01A", "WEL01B", "WEL01C", "WEL01D",
                "WEL21A", "WEL21B", "WEL21C", "WEL21D",
                "WEL51A", "WEL51B", "WEL51C", "WEL51D",]

    get_f0(dataname)