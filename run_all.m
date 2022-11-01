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
duration = [1, 2, 3, 4, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70];
typeflag_songdesc = 1;
exploratory = false;

for i=1:numel(duration)
    fprintf('%s: %d/%d\n', datetime, i, numel(duration));
    analysis_featureES_1(duration(i), typeflag_songdesc, exploratory, outputdir_analysis);
    analysis_featureES_2(duration(i), typeflag_songdesc, exploratory, outputdir_analysis);
    close all
end

%%
duration = Inf;
exploratory = true;

analysis_featureES_1(duration, typeflag_songdesc, exploratory, outputdir_analysis);
analysis_featureES_2(duration, typeflag_songdesc, exploratory, outputdir_analysis);

typeflag_instdesc = 2;
analysis_featureES_1(duration, typeflag_instdesc, exploratory, outputdir_analysis);
analysis_featureES_2(duration, typeflag_instdesc, exploratory, outputdir_analysis);

typeflag_songrecit = 3;
analysis_featureES_1(duration, typeflag_songrecit, exploratory, outputdir_analysis);
analysis_featureES_2(duration, typeflag_songrecit, exploratory, outputdir_analysis);

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