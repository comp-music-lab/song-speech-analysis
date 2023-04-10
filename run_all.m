%%
helper.h_addpath_MIRtoolbox();

%% Confirmatory + Exploratory analysis
outputdir_analysis = './output/analysis/Stage2/';
exploratory = true;
duration = 20;
typeflag_songdesc = 1;
typeid = 'song-desc';
datainfofile = './datainfo.csv';
al = 0.05/6;
blindedonly = false;
continuitycorrection = false;
onsetavailable = true;

analysis_rawdatastat(datainfofile, outputdir_analysis, duration, exploratory);
local_main(datainfofile, duration, typeflag_songdesc, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly, continuitycorrection, onsetavailable);

%% Exploratory - normalized f0 contour
datainfo = readtable('./datainfo.csv');
duration = 30;
outputdir_fig = './output/figure/Stage2/';
analysis_normalizedcontour(datainfo, duration, outputdir_fig);

%% Exploratory - Hilton's data + α
typeflag_songdesc = 1;
typeid = 'song-desc';
exploratory = false;
al = 0.05/6;
blindedonly = false;
continuitycorrection = false;

duration = Inf;
onsetavailable = false;
datainfofile = './datainfo_Hilton-subset-pyin.csv';
outputdir_analysis = './output/analysis/Stage2/Hilton-subset/';
outputdir_fig = './output/figure/Stage2/Hilton-subset/';
local_main(datainfofile, duration, typeflag_songdesc, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly, continuitycorrection, onsetavailable);

duration = Inf;
onsetavailable = false;
datainfofile = './datainfo_Hilton-pyin.csv';
outputdir_analysis = './output/analysis/Stage2/Hilton/';
outputdir_fig = './output/figure/Stage2/Hilton/';
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

duration = Inf;
onsetavailable = false;
datainfofile = './datainfo_pyin.csv';
outputdir_analysis = './output/analysis/Stage2/pyin/';
outputdir_fig = './output/figure/Stage2/pyin/';
local_main(datainfofile, duration, typeflag_songdesc, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly, continuitycorrection, onsetavailable);

duration = Inf;
onsetavailable = true;
datainfofile = './datainfo_pyin-praat.csv';
outputdir_analysis = './output/analysis/Stage2/pyin-praat/';
outputdir_fig = './output/figure/Stage2/pyin-praat/';
local_main(datainfofile, duration, typeflag_songdesc, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly, continuitycorrection, onsetavailable);

%% Exploratory - zero cell correction
exploratory = false;
outputdir_analysis = './output/analysis/Stage2/continuity/';
continuitycorrection = true;

local_main(datainfofile, duration, typeflag_songdesc, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly, continuitycorrection, onsetavailable);

%% Exploratory - other combinations
outputdir_analysis = './output/analysis/Stage2/';
continuitycorrection = false;

typeflag_instdesc = 2;
typeid = 'inst-desc';
local_main(datainfofile, duration, typeflag_instdesc, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly, continuitycorrection, onsetavailable);

typeflag_songrect = 3;
typeid = 'song-recit';
local_main(datainfofile, duration, typeflag_songrect, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly, continuitycorrection, onsetavailable);

%% Exploratory - 30 seconds
typeflag_songdesc = 1;
typeid = 'song-desc';
duration = 30;
analysis_rawdatastat(datainfofile, outputdir_analysis, duration);
local_main(datainfofile, duration, typeflag_songdesc, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly, continuitycorrection, onsetavailable);

%% Robustness check - hypothesis blinding
continuitycorrection = false;
outputdir_analysis = './output/analysis/Stage2/blinding/';
duration = 20;
blindedonly = true;
local_main(datainfofile, duration, typeflag_songdesc, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly, continuitycorrection, onsetavailable);

function local_main(datainfofile, duration, typeflag, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly, continuitycorrection, onsetavailable)
    if not(isfolder(outputdir_analysis))
        mkdir(outputdir_analysis)
    end
    
    if not(isfolder(outputdir_fig))
        mkdir(outputdir_fig)
    end

    analysis_featureES_1(datainfofile, duration, typeflag, exploratory, outputdir_analysis, blindedonly);
    
    esinfofile = strcat(outputdir_analysis, 'results_effectsize_acoustic_', typeid, '_', num2str(duration), 'sec.csv');
    outputfile = strcat(outputdir_analysis, 'ma_acoustic_', typeid, '_', num2str(duration), 'sec.csv');
    analysis_metaCI(esinfofile, outputfile, al);
    outputfile = strcat(outputdir_analysis, 'equiv_acoustic_', typeid, '_', num2str(duration), 'sec.csv');
    analysis_equivtest(esinfofile, outputfile, al);
    
    if onsetavailable
        analysis_featureES_2(datainfofile, duration, typeflag, exploratory, outputdir_analysis, blindedonly, continuitycorrection);
    
        esinfofile = strcat(outputdir_analysis, 'results_effectsize_seg_', typeid, '_', num2str(duration), 'sec.csv');
        outputfile = strcat(outputdir_analysis, 'ma_seg_', typeid, '_', num2str(duration), 'sec.csv');
        analysis_metaCI(esinfofile, outputfile, al);
        outputfile = strcat(outputdir_analysis, 'equiv_seg_', typeid, '_', num2str(duration), 'sec.csv');
        analysis_equivtest(esinfofile, outputfile, al);
    end
end