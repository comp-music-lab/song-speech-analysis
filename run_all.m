%%
helper.h_addpath_MIRtoolbox();

%% Exploratory - other combinations
datainfofile = './datainfo.csv';
outputdir_analysis = './output/analysis/Stage2/';
outputdir_fig = './output/figure/Stage2/';
duration = 20;
al = 0.05/6;
exploratory = false;
blindedonly = false;
continuitycorrection = false;
onsetavailable = true;

typeflag_songrect = 4;
typeid = 'inst-song';
local_main(datainfofile, duration, typeflag_songrect, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly, continuitycorrection, onsetavailable);

typeflag_instdesc = 2;
typeid = 'inst-desc';
local_main(datainfofile, duration, typeflag_instdesc, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly, continuitycorrection, onsetavailable);

typeflag_songrect = 6;
typeid = 'inst-recit';
local_main(datainfofile, duration, typeflag_songrect, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly, continuitycorrection, onsetavailable);

typeflag_songrect = 3;
typeid = 'song-recit';
local_main(datainfofile, duration, typeflag_songrect, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly, continuitycorrection, onsetavailable);

typeflag_songrect = 5;
typeid = 'recit-desc';
local_main(datainfofile, duration, typeflag_songrect, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly, continuitycorrection, onsetavailable);

%% Confirmatory + Exploratory analysis
datainfofile = './datainfo.csv';
outputdir_analysis = './output/analysis/Stage2/';
outputdir_fig = './output/figure/Stage2/';
duration = 20;
typeflag_songdesc = 1;
typeid = 'song-desc';
al = 0.05/6;
exploratory = true;
blindedonly = false;
continuitycorrection = false;
onsetavailable = true;

local_main(datainfofile, duration, typeflag_songdesc, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly, continuitycorrection, onsetavailable);
analysis_rawdatastat(datainfofile, outputdir_analysis, duration, exploratory);

%% Exploratory - normalized f0 contour
datainfo = readtable('./datainfo.csv');
duration = 30;
outputdir_fig = './output/figure/Stage2/';
analysis_normalizedcontour(datainfo, duration, outputdir_fig);

%% Exploratory - permutation importance analysis
pyrunfile("analysis_permi.py")

%% Exploratory - nPVI
datainfofile = './datainfo.csv';
outputdir_analysis = './output/analysis/Stage2/';
duration = 20;

typeid_songdesc = 1;
analysis_npvi(datainfofile, outputdir_analysis, duration, typeid_songdesc);

typeid_songinst = 2;
analysis_npvi(datainfofile, outputdir_analysis, duration, typeid_songinst);

typeid_songrecit = 3;
analysis_npvi(datainfofile, outputdir_analysis, duration, typeid_songrecit);

%% Exploratory - Automated
typeflag_songdesc = 1;
typeid = 'song-desc';
exploratory = false;
al = 0.05/6;
blindedonly = false;
continuitycorrection = false;

duration = Inf;
datainfofile = './datainfo_pyin-praat.csv';

onsetavailable = false;
outputdir_analysis = './output/analysis/Stage2/pyin/';
outputdir_fig = './output/figure/Stage2/pyin/';
local_main(datainfofile, duration, typeflag_songdesc, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly, continuitycorrection, onsetavailable);
analysis_rawdatastat(datainfofile, outputdir_analysis, duration, exploratory);

onsetavailable = true;
outputdir_analysis = './output/analysis/Stage2/pyin-praat/';
outputdir_fig = './output/figure/Stage2/pyin-praat/';
local_main(datainfofile, duration, typeflag_songdesc, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly, continuitycorrection, onsetavailable);

duration = 20;
onsetavailable = false;
datainfofile = './datainfo_subset.csv';
outputdir_analysis = './output/analysis/Stage2/subset/';
outputdir_fig = './output/figure/Stage2/subset/';
local_main(datainfofile, duration, typeflag_songdesc, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly, continuitycorrection, onsetavailable);

duration = Inf;
onsetavailable = false;
datainfofile = './datainfo_pyin-subset.csv';
outputdir_analysis = './output/analysis/Stage2/pyin-subset/';
outputdir_fig = './output/figure/Stage2/pyin-subset/';
local_main(datainfofile, duration, typeflag_songdesc, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly, continuitycorrection, onsetavailable);

%% Exploratory - zero cell correction
datainfofile = './datainfo.csv';
outputdir_analysis = './output/analysis/Stage2/continuity/';
outputdir_fig = './output/figure/Stage2/continuity/';
duration = 20;
typeflag_songdesc = 1;
typeid = 'song-desc';
al = 0.05/6;
blindedonly = false;
exploratory = false;
continuitycorrection = true;
onsetavailable = true;

local_main(datainfofile, duration, typeflag_songdesc, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly, continuitycorrection, onsetavailable);

%% Exploratory - 30 seconds
datainfofile = './datainfo.csv';
outputdir_analysis = './output/analysis/Stage2/';
outputdir_fig = './output/figure/Stage2/';
duration = 30;
typeflag_songdesc = 1;
typeid = 'song-desc';
al = 0.05/6;
blindedonly = false;
exploratory = false;
continuitycorrection = false;
onsetavailable = true;

local_main(datainfofile, duration, typeflag_songdesc, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly, continuitycorrection, onsetavailable);

%% Exploratory - Hilton's data [20sec]
typeflag_songdesc = 1;
typeid = 'song-desc';
exploratory = false;
al = 0.05/6;
blindedonly = false;
continuitycorrection = false;
onsetavailable = false;
duration = 20;

datainfofile = './datainfo_Hilton-pyin-20sec.csv';
outputdir_analysis = './output/analysis/Stage2/Hilton (20sec)/';
outputdir_fig = './output/figure/Stage2/Hilton (20sec)/';
local_main(datainfofile, duration, typeflag_songdesc, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly, continuitycorrection, onsetavailable);

%% Robustness check - hypothesis blinding
datainfofile = './datainfo.csv';
duration = 20;
typeflag_songdesc = 1;
typeid = 'song-desc';
exploratory = false;
al = 0.05/6;
outputdir_analysis = './output/analysis/Stage2/blinding/';
outputdir_fig = './output/figure/Stage2/blinding/';
blindedonly = true;
continuitycorrection = false;
onsetavailable = true;

local_main(datainfofile, duration, typeflag_songdesc, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly, continuitycorrection, onsetavailable);

%% Exploratory - Hilton's data
typeflag_songdesc = 1;
typeid = 'song-desc';
exploratory = false;
al = 0.05/6;
blindedonly = false;
continuitycorrection = false;
onsetavailable = false;
duration = Inf;

datainfofile = './datainfo_Hilton-pyin.csv';
outputdir_analysis = './output/analysis/Stage2/Hilton/';
outputdir_fig = './output/figure/Stage2/Hilton/';
local_main(datainfofile, duration, typeflag_songdesc, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly, continuitycorrection, onsetavailable);

analysis_rawdatastat(datainfofile, outputdir_analysis, duration, exploratory);

datainfofile = './datainfo_Hilton-subset-pyin.csv';
outputdir_analysis = './output/analysis/Stage2/Hilton-subset/';
outputdir_fig = './output/figure/Stage2/Hilton-subset/';
local_main(datainfofile, duration, typeflag_songdesc, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly, continuitycorrection, onsetavailable);

%% local functions
function local_main(datainfofile, duration, typeflag, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly, continuitycorrection, onsetavailable)
    if not(isfolder(outputdir_analysis))
        mkdir(outputdir_analysis)
    end
    
    if not(isfolder(outputdir_fig))
        mkdir(outputdir_fig)
    end
    
    analysis_featureES_1(datainfofile, duration, typeflag, exploratory, outputdir_analysis, blindedonly);
    
    esinfofile = strcat(outputdir_analysis, 'results_effectsize_acoustic_', typeid, '_', num2str(duration), 'sec.csv');

    % --------------------------
    % Workaround until Rob and Diana's data get updated
    T = readtable('./output/analysis/Stage2/results_effectsize_acoustic_song-desc_20sec.csv');
    idx_rob = (T.groupid == 74 & strcmp(T.feature, 'f0')) ...
        | (T.groupid == 74 & strcmp(T.feature, '-|Δf0|')) ...
        | (T.groupid == 74 & strcmp(T.feature, 'Spectral centroid'));
    idx_dna = (T.groupid == 75 & strcmp(T.feature, 'f0')) ...
        | (T.groupid == 75 & strcmp(T.feature, '-|Δf0|')) ...
        | (T.groupid == 75 & strcmp(T.feature, 'Spectral centroid'));
    writetable(T(~(idx_rob | idx_dna), :), './output/analysis/Stage2/results_effectsize_acoustic_song-desc_20sec.csv');
    % --------------------------

    outputfile = strcat(outputdir_analysis, 'ma_acoustic_', typeid, '_', num2str(duration), 'sec.csv');
    analysis_metaCI(esinfofile, outputfile, al);
    outputfile = strcat(outputdir_analysis, 'equiv_acoustic_', typeid, '_', num2str(duration), 'sec.csv');
    analysis_equivtest(esinfofile, outputfile, al);

    if onsetavailable
        analysis_featureES_2(datainfofile, duration, typeflag, exploratory, outputdir_analysis, blindedonly, continuitycorrection);
    
        esinfofile = strcat(outputdir_analysis, 'results_effectsize_seg_', typeid, '_', num2str(duration), 'sec.csv');

        % --------------------------
        % Workaround until Rob and Diana's data get updated
        T = readtable('./output/analysis/Stage2/results_effectsize_seg_song-desc_20sec.csv');
        idx_rob = (T.groupid == 74 & strcmp(T.feature, 'IOI rate')) ...
            | (T.groupid == 74 & strcmp(T.feature, 'f0 ratio')) ...
            | (T.groupid == 74 & strcmp(T.feature, 'Sign of f0 slope'));
        idx_dna = (T.groupid == 75 & strcmp(T.feature, 'IOI rate')) ...
            | (T.groupid == 75 & strcmp(T.feature, 'f0 ratio')) ...
            | (T.groupid == 75 & strcmp(T.feature, 'Sign of f0 slope'));
        writetable(T(~(idx_rob | idx_dna), :), './output/analysis/Stage2/results_effectsize_seg_song-desc_20sec.csv');
        % --------------------------

        outputfile = strcat(outputdir_analysis, 'ma_seg_', typeid, '_', num2str(duration), 'sec.csv');
        analysis_metaCI(esinfofile, outputfile, al);
        outputfile = strcat(outputdir_analysis, 'equiv_seg_', typeid, '_', num2str(duration), 'sec.csv');
        analysis_equivtest(esinfofile, outputfile, al);
    end
end