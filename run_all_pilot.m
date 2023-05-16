%% Setup
helper.h_addpath_MIRtoolbox();

outputdir_analysis = './output/analysis/Stage1/';
outputdir_fig = './output/figure/Stage1/';

if not(isfolder(outputdir_analysis))
    mkdir(outputdir_analysis)
end

if not(isfolder(outputdir_fig))
    mkdir(outputdir_fig)
end

blindedonly = false;
continuitycorrection = false;

%% Figure materials
fig_script(outputdir_fig);

%% Analysis
datainfofile = './datainfo_pilot.csv';
duration = [1, 2, 3, 4, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70];
typeflag_songdesc = 1;
exploratory = false;

for i=1:numel(duration)
    fprintf('%s: %d/%d\n', datetime, i, numel(duration));
    analysis_featureES_1(datainfofile, duration(i), typeflag_songdesc, exploratory, outputdir_analysis, blindedonly);
    analysis_featureES_2(datainfofile, duration(i), typeflag_songdesc, exploratory, outputdir_analysis, blindedonly, continuitycorrection);
    close all
end

%%
duration = Inf;
exploratory = true;

analysis_featureES_1(datainfofile, duration, typeflag_songdesc, exploratory, outputdir_analysis, blindedonly);
analysis_featureES_2(datainfofile, duration, typeflag_songdesc, exploratory, outputdir_analysis, blindedonly, continuitycorrection);

typeflag_instdesc = 2;
analysis_featureES_1(datainfofile, duration, typeflag_instdesc, exploratory, outputdir_analysis, blindedonly);
analysis_featureES_2(datainfofile, duration, typeflag_instdesc, exploratory, outputdir_analysis, blindedonly, continuitycorrection);

typeflag_songrecit = 3;
analysis_featureES_1(datainfofile, duration, typeflag_songrecit, exploratory, outputdir_analysis, blindedonly);
analysis_featureES_2(datainfofile, duration, typeflag_songrecit, exploratory, outputdir_analysis, blindedonly, continuitycorrection);

%%
al = 0.05/6;
typeid = {'song-desc', 'song-recit', 'inst-desc'};

for i=1:numel(typeid)
    esinfofile = strcat(outputdir_analysis, 'results_effectsize_acoustic_', typeid{i}, '_Infsec.csv');
    outputfile = strcat(outputdir_analysis, 'ma_acoustic_', typeid{i}, '_Infsec.csv');
    analysis_metaCI(esinfofile, outputfile, al);

    esinfofile = strcat(outputdir_analysis, 'results_effectsize_seg_', typeid{i}, '_Infsec.csv');
    outputfile = strcat(outputdir_analysis, 'ma_seg_', typeid{i}, '_Infsec.csv');
    analysis_metaCI(esinfofile, outputfile, al);
end

%%
analysis_durationeffect(datainfofile, outputdir_analysis, outputdir_fig);

%%
analysis_annotatoreffect(outputdir_analysis);

%%
analysis_rawdatastat_pilot(outputdir_analysis);

%% Power analysis simulation is stochastic so run several times.
al = 0.05/6;
be = 0.95;
numsim = 20;
ma_power(outputdir_analysis, al, be, numsim);

%% Analyze Hilton's data + pYIN data
duration = Inf;
typeflag_songdesc = 1;
exploratory = false;
al = 0.05/6;
blindedonly = false;

%%
outputdir_analysis = './output/analysis/Stage1/Hilton-pyin/';
if not(isfolder(outputdir_analysis))
    mkdir(outputdir_analysis)
end

datainfofile = './datainfo_pilot-Hilton-pyin.csv';
analysis_featureES_1(datainfofile, duration, typeflag_songdesc, exploratory, outputdir_analysis, blindedonly);

esinfofile = strcat(outputdir_analysis, 'results_effectsize_acoustic_song-desc_Infsec.csv');
outputfile = strcat(outputdir_analysis, 'ma_acoustic_song-desc_Infsec.csv');
analysis_metaCI(esinfofile, outputfile, al);

%%
outputdir_analysis = './output/analysis/Stage1/Hilton-sa/';
if not(isfolder(outputdir_analysis))
    mkdir(outputdir_analysis)
end

datainfofile = './datainfo_pilot-Hilton-sa.csv';
analysis_featureES_1(datainfofile, duration, typeflag_songdesc, exploratory, outputdir_analysis, blindedonly);

esinfofile = strcat(outputdir_analysis, 'results_effectsize_acoustic_song-desc_Infsec.csv');
outputfile = strcat(outputdir_analysis, 'ma_acoustic_song-desc_Infsec.csv');
analysis_metaCI(esinfofile, outputfile, al);

%%
outputdir_analysis = './output/analysis/Stage1/pilot-pyin/';
if not(isfolder(outputdir_analysis))
    mkdir(outputdir_analysis)
end

datainfofile = './datainfo_pilot-pyin.csv';
analysis_featureES_1(datainfofile, duration, typeflag_songdesc, exploratory, outputdir_analysis, blindedonly);

esinfofile = strcat(outputdir_analysis, 'results_effectsize_acoustic_song-desc_Infsec.csv');
outputfile = strcat(outputdir_analysis, 'ma_acoustic_song-desc_Infsec.csv');
analysis_metaCI(esinfofile, outputfile, al);