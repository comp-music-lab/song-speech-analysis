function analysis_Marseden
    %% configuration
    datainfo = readtable('datainfo_Marseden.csv');
    
    addpath('./lib/two-sample/');
    addpath('./lib/KDE/');
    addpath('./lib/CWT/');
    
    varNames = {'feature', 'lang', 'diff', 'method'};
    idx_pair = unique(datainfo.pair);
    results = table('Size', [0, numel(varNames)], 'VariableTypes', {'string', 'string', 'double', 'string'}, 'VariableNames', varNames);
    
    reffreq = 440;
    
    %% ELT
    N = size(datainfo, 1);
    t_onset = cell(N, 1);
    t_break = cell(N, 1);
    f0 = cell(N, 1);
    interval = cell(N, 1);
    
    for i=1:N
        onsetfilepath = strcat(datainfo.path{i}, 'onset_', datainfo.dataname{i}, '.csv');
        T = readtable(onsetfilepath);
        t_onset{i} = table2array(T(:, 1));
        
        breakfilepath = strcat(datainfo.path{i}, 'break_', datainfo.dataname{i}, '.csv');
        T = readtable(breakfilepath);
        
        if isempty(T)
            t_break{i} = [];
        else
            t_break{i} = table2array(T(:, 1));
        end
        
        f0filepath = strcat(datainfo.path{i}, datainfo.dataname{i}, '_f0.csv');
        T = readtable(f0filepath);
        f0{i} = table2array(T(:, 2));
        t_f0 = table2array(T(:, 1));
        
        f0_cent = 1200.*log2(f0{i}./reffreq);
        [~, ~, t_st, t_ed] = helper.h_ioi(t_onset{i}, t_break{i});
        I = helper.h_interval(f0_cent, t_f0, t_st, t_ed);
        I = cat(1, I{:});
        tmp = cell(1, 1);
        tmp{1} = I;
        interval{i} = helper.h_subsampling(tmp, 4096);
        interval{i} = interval{i}{1};
    end
    
    %% interval distance
    intervaldistance = cell(N, 1);
    for i=1:N
        intervaldistance{i} = abs(interval{i} - 0);
    end
    
    for i=1:numel(idx_pair)
        idx_song = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, 'song');
        idx_desc = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, 'desc');
        d = pb_effectsize(intervaldistance{idx_song}, intervaldistance{idx_desc});
        results(end + 1, :) = table({'Distance from the interval of 0'}, datainfo.language(idx_song), d, {'common language effect size'});
    end
    
    %% pitch discreteness (modulation-based)
    modulationmagnitude = cell(N, 1);
    for i=1:N
        modulationmagnitude{i} = abs(ft_deltaf0(f0{i}, 0.005, reffreq));
    end
    
    for i=1:numel(idx_pair)
        idx_song = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, 'song');
        idx_desc = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, 'desc');
        d = pb_effectsize(modulationmagnitude{idx_song}, modulationmagnitude{idx_desc});
        results(end + 1, :) = table({'Magnitude of F0 modulatioin'}, datainfo.language(idx_song), d, {'common language effect size'});
    end
    
    %% Register (mean F0)
    for i=1:numel(idx_pair)
        idx_song = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, 'song');
        idx_desc = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, 'desc');
        d = pb_effectsize(f0{idx_song}, f0{idx_desc});
        results(end + 1, :) = table({'F0'}, datainfo.language(idx_song), d, {'common language effect size'});
    end
    
    %% nPVI (Duratonal variability)
    nPVI = zeros(N, 1);
    for i=1:N
        nPVI(i) = ft_npvi(t_onset{i}, t_break{i});
    end
    
    for i=1:numel(idx_pair)
        idx_song = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, 'song');
        idx_desc = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, 'desc');
        d = nPVI(idx_song) - nPVI(idx_desc);
        results(end + 1, :) = table({'nPVI'}, datainfo.language(idx_song), d, {'simple difference'});
    end
    
    %% nPC (Duratonal variability)
    nPC = cell(N, 1);
    for i=1:N
        nPC{i} = ft_npc(t_onset{i}, t_break{i});
    end
    
    for i=1:numel(idx_pair)
        idx_song = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, 'song');
        idx_desc = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, 'desc');
        d = pb_effectsize(nPC{idx_song}, nPC{idx_desc});
        results(end + 1, :) = table({'nPC'}, datainfo.language(idx_song), d, {'common language effect size'});
    end
    
    %% Speed (IOI)
    IOI = cell(N, 1);
    for i=1:N
        IOI{i} = ft_ioi(t_onset{i}, t_break{i});
    end
    
    for i=1:numel(idx_pair)
        idx_song = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, 'song');
        idx_desc = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, 'desc');
        d = pb_effectsize(IOI{idx_song}, IOI{idx_desc});
        results(end + 1, :) = table({'IOI'}, datainfo.language(idx_song), d, {'common language effect size'});
    end
    
    %% Isochrony (2)
    IOIratiodist = cell(N, 1);
    for i=1:N
        IOIratiodist{i} = ft_ioiratiodist(t_onset{i}, t_break{i});
    end
    
    for i=1:numel(idx_pair)
        idx_song = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, 'song');
        idx_desc = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, 'desc');
        d = pb_effectsize(IOIratiodist{idx_song}, IOIratiodist{idx_desc});
        results(end + 1, :) = table({'Distance from the IOI ratio of 0.5'}, datainfo.language(idx_song), d, {'common language effect size'});
    end
    
    %% Isochrony (1)
    rad_al_IOIratio = cell(N, 1);
    for i=1:N
        rad_al_IOIratio{i} = ft_dctioiratio(t_onset{i}, t_break{i});
    end
    
    for i=1:numel(idx_pair)
        idx_song = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, 'song');
        idx_desc = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, 'desc');
        d = rad_al_IOIratio{idx_song} - rad_al_IOIratio{idx_desc};
        results(end + 1, :) = table({'Radian of the 95% power of DCT of the IOI ratio distribution'}, datainfo.language(idx_song), d, {'simple difference'});
    end
    
    %% Phrase length (first onset-final break interval)
    OBI = cell(N, 1);
    for i=1:N
        OBI{i} = ft_obi(t_onset{i}, t_break{i});
    end
    
    for i=1:numel(idx_pair)
        idx_song = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, 'song');
        idx_desc = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, 'desc');
        d = median(OBI{idx_song}) - median(OBI{idx_desc});
        results(end + 1, :) = table({'Median onset-break interval'}, datainfo.language(idx_song), d, {'simple difference'});
    end
    
    %% Brightness (spectral centroid)
    SC = cell(N, 1);
    for i=1:N
        audiofilepath = strcat(datainfo.audiofilepath{i}, datainfo.dataname{i}, '.wav');
        SC{i} = ft_spectralcentroid(audiofilepath);
    end
    
    for i=1:numel(idx_pair)
        idx_song = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, 'song');
        idx_desc = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, 'desc');
        d = pb_effectsize(SC{idx_song}, SC{idx_desc});
        results(end + 1, :) = table({'Spectral centroid'}, datainfo.language(idx_song), d, {'common language effect size'});
    end
    
    %%
    writetable(results, './output/results_Marseden.csv');
end