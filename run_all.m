%%
helper.h_addpath_MIRtoolbox();

%%
outputdir_analysis = './output/analysis/Stage2/';
outputdir_fig = './output/figure/Stage2/';

if not(isfolder(outputdir_analysis))
    mkdir(outputdir_analysis)
end

if not(isfolder(outputdir_fig))
    mkdir(outputdir_fig)
end

%% Confirmatory analysis
exploratory = false;
duration = 20;
typeflag_songdesc = 1;
datainfofile = './datainfo.csv';
analysis_featureES_1(datainfofile, duration, typeflag_songdesc, exploratory, outputdir_analysis);
analysis_featureES_2(datainfofile, duration, typeflag_songdesc, exploratory, outputdir_analysis);

%% Confirmatory analysis
al = 0.05/6;
typeid = 'song-desc';

esinfofile = strcat(outputdir_analysis, 'results_effectsize_acoustic_', typeid, '_', num2str(duration), 'sec.csv');
outputfile = strcat(outputdir_analysis, 'ma_acoustic_', typeid, '_', num2str(duration), 'sec.csv');
analysis_metaCI(esinfofile, outputfile, al);
outputfile = strcat(outputdir_analysis, 'equiv_acoustic_', typeid, '_', num2str(duration), 'sec.csv');
analysis_equivtest(esinfofile, outputfile, al);

esinfofile = strcat(outputdir_analysis, 'results_effectsize_seg_', typeid, '_', num2str(duration), 'sec.csv');
outputfile = strcat(outputdir_analysis, 'ma_seg_', typeid, '_', num2str(duration), 'sec.csv');
analysis_metaCI(esinfofile, outputfile, al);
outputfile = strcat(outputdir_analysis, 'equiv_seg_', typeid, '_', num2str(duration), 'sec.csv');
analysis_equivtest(esinfofile, outputfile, al);

%% 
analysis_rawdatastat(datainfofile, outputdir_analysis, duration);

%% Exploratory
exploratory = false;
duration = 30;
typeflag_songdesc = 1;
datainfofile = './datainfo.csv';

analysis_featureES_2(datainfofile, duration, typeflag_songdesc, exploratory, outputdir_analysis);

al = 0.05/6;
typeid = 'song-desc';

esinfofile = strcat(outputdir_analysis, 'results_effectsize_seg_', typeid, '_', num2str(duration), 'sec.csv');
outputfile = strcat(outputdir_analysis, 'ma_seg_', typeid, '_', num2str(duration), 'sec.csv');
analysis_metaCI(esinfofile, outputfile, al);
outputfile = strcat(outputdir_analysis, 'equiv_seg_', typeid, '_', num2str(duration), 'sec.csv');
analysis_equivtest(esinfofile, outputfile, al);

analysis_rawdatastat(datainfofile, outputdir_analysis, duration);