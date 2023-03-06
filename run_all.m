%%
helper.h_addpath_MIRtoolbox();

%% Confirmatory analysis
outputdir_analysis = './output/analysis/Stage2/';
outputdir_fig = './output/figure/Stage2/';
exploratory = false;
duration = 20;
typeflag_songdesc = 1;
typeid = 'song-desc';
datainfofile = './datainfo.csv';
al = 0.05/6;
blindedonly = false;

local_main(datainfofile, duration, typeflag_songdesc, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly);
analysis_rawdatastat(datainfofile, outputdir_analysis, duration);

%% Exploratory - other combinations
typeflag_instdesc = 2;
typeid = 'inst-desc';
local_main(datainfofile, duration, typeflag_instdesc, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly);

typeflag_songrect = 3;
typeid = 'song-recit';
local_main(datainfofile, duration, typeflag_songrect, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly);

%% Exploratory - 30 seconds
typeflag_songdesc = 1;
typeid = 'song-desc';
duration = 30;
local_main(datainfofile, duration, typeflag_songdesc, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly);

%% Robustness check - hypothesis blinding
outputdir_analysis = './output/analysis/Stage2/blinding/';
duration = 20;
blindedonly = true;
local_main(datainfofile, duration, typeflag_songdesc, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly);

function local_main(datainfofile, duration, typeflag, typeid, exploratory, al, outputdir_analysis, outputdir_fig, blindedonly)
    if not(isfolder(outputdir_analysis))
        mkdir(outputdir_analysis)
    end
    
    if not(isfolder(outputdir_fig))
        mkdir(outputdir_fig)
    end

    analysis_featureES_1(datainfofile, duration, typeflag, exploratory, outputdir_analysis, blindedonly);
    analysis_featureES_2(datainfofile, duration, typeflag, exploratory, outputdir_analysis, blindedonly);

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
end