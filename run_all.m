%%
helper.h_addpath_MIRtoolbox();

%%
outputdir_analysis = './output/analysis/';
outputdir_fig = './output/figure/';

if not(isfolder(outputdir_analysis))
    mkdir(outputdir_analysis)
end

if not(isfolder(outputdir_fig))
    mkdir(outputdir_fig)
end

%%
datainfoid = {'datainfo_Marsden-all', 'datainfo_Marsden-complete'};
duration = [1, 2, 3, 4, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70];
typeflag_songdesc = 1;
exploratory = false;

for i=1:numel(duration)
    fprintf('%s: %d/%d\n', datetime, i, numel(duration));
    analysis_featureES_1(datainfoid{1}, duration(i), typeflag_songdesc, exploratory, outputdir_analysis);
    analysis_featureES_2(datainfoid{2}, duration(i), typeflag_songdesc, exploratory, outputdir_analysis);
    close all
end

%%
duration = Inf;
exploratory = true;

analysis_featureES_1(datainfoid{1}, duration, typeflag_songdesc, exploratory, outputdir_analysis);
analysis_featureES_2(datainfoid{2}, duration, typeflag_songdesc, exploratory, outputdir_analysis);

typeflag_instdesc = 2;
analysis_featureES_1(datainfoid{1}, duration, typeflag_instdesc, exploratory, outputdir_analysis);
analysis_featureES_2(datainfoid{2}, duration, typeflag_instdesc, exploratory, outputdir_analysis);

typeflag_songrecit = 3;
analysis_featureES_1(datainfoid{1}, duration, typeflag_songrecit, exploratory, outputdir_analysis);
analysis_featureES_2(datainfoid{2}, duration, typeflag_songrecit, exploratory, outputdir_analysis);

%%
q = [0.5, 0.9688, 0.0312, 0.9688];
%{
al = 0.05/6;
q = [0.5, 1 - al, 1 - al/2, al/2];
%}
typeid = {'song-desc', 'song-recit', 'inst-desc'};

for i=1:numel(typeid)
    esinfofile = strcat(outputdir_analysis, 'results_effectsize_acoustic_', typeid{i}, '_Infsec.csv');
    outputfile = strcat(outputdir_analysis, 'ma_acoustic_', typeid{i}, '_Infsec.csv');
    analysis_metaCI(esinfofile, outputfile, q);

    esinfofile = strcat(outputdir_analysis, 'results_effectsize_seg_', typeid{i}, '_Infsec.csv');
    outputfile = strcat(outputdir_analysis, 'ma_seg_', typeid{i}, '_Infsec.csv');
    analysis_metaCI(esinfofile, outputfile, q);
end

%%
analysis_durationeffect(outputdir_analysis, outputdir_fig);

%%
analysis_annotatoreffect(outputdir_analysis);

%%
analysis_rawdatastat(outputdir_analysis);

%% Simulation is stochastic so run several times.
for i=1:20
    fprintf('Power analysis simulation (%d/%d)\n', i, 20);
    ma_power();
end

%%
fig_script(outputdir_fig);