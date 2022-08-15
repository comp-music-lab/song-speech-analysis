function analysis_Marsden_all
    %% configuration
    typelist = {'song', 'recit'};
    datainfo = readtable('datainfo_Marsden-all_song-recit.csv');
    outputdir = './output/20220705/';
    
    addpath('./lib/two-sample/');
    addpath('./lib/CWT/');
    
    varNames = {'feature', 'lang', 'diff', 'method'};
    idx_pair = unique(datainfo.pair);
    results = table('Size', [0, numel(varNames)], 'VariableTypes', {'string', 'string', 'double', 'string'}, 'VariableNames', varNames);
    
    reffreq = 440;
    
    %% ETL
    N = size(datainfo, 1);
    f0 = cell(N, 1);
    t_f0 = cell(N, 1);
    
    for i=1:N
        f0filepath = strcat(datainfo.path{i}, datainfo.dataname{i}, '_f0.csv');
        T = readtable(f0filepath);
        f0{i} = table2array(T(:, 2));
        t_f0{i} = table2array(T(:, 1));
    end
    
    %% Comparison
    modulationmagnitude = cell(N, 1); % pitch discreteness (modulation-based)
    for i=1:N
        tmp = abs(ft_deltaf0(f0{i}, 0.005, reffreq));
        modulationmagnitude{i} = tmp(~isnan(tmp));
    end

    SC = cell(N, 1); % Brightness (spectral centroid)
    for i=1:N
        audiofilepath = strcat(datainfo.audiofilepath{i}, datainfo.dataname{i}, '.wav');
        SC{i} = ft_spectralcentroid(audiofilepath, f0{i}, t_f0{i});
    end

    for i=1:numel(idx_pair)
        idx_song = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, typelist{1});
        idx_desc = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, typelist{2});

        d = pb_effectsize(f0{idx_song}, f0{idx_desc});
        results(end + 1, :) = table({'F0'}, datainfo.language(idx_song), d, {'common language effect size'});

        d = pb_effectsize(modulationmagnitude{idx_song}, modulationmagnitude{idx_desc});
        results(end + 1, :) = table({'Magnitude of F0 modulatioin'}, datainfo.language(idx_song), 1 - d, {'common language effect size'});

        d = pb_effectsize(SC{idx_song}, SC{idx_desc});
        results(end + 1, :) = table({'Spectral centroid'}, datainfo.language(idx_song), d, {'common language effect size'});
    end
    
    %%
    writetable(results, strcat(outputdir, 'results_Marsden-all_', typelist{1}, '-', typelist{2}, '.csv'));
end