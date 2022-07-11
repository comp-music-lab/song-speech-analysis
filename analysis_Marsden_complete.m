function analysis_Marsden_complete
    %% configuration
    typelist = {'inst', 'desc'};
    datainfo = readtable('datainfo_Marsden-complete_inst-desc.csv');
    outputdir = './output/20220705/';
    
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
        T = readtable(breakfilepath, 'ReadVariableNames', false);
        
        if isempty(T)
            t_break{i} = [];
        else
            t_break{i} = table2array(T(:, 1));

            if iscell(t_break{i})
                t_break{i} = str2double(cell2mat(t_break{i}));
            end
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
    
    %% Comparison
    IOI = cell(N, 1); % Speed (IOI)
    OBI = cell(N, 1); % Phrase length (first onset-final break interval)
    IOIrationndist = cell(N, 1); % IOI regularity
    intervalnndist = cell(N, 1); % interval regularity
    
    for i=1:N
        IOI{i} = ft_ioi(t_onset{i}, t_break{i});
        OBI{i} = ft_obi(t_onset{i}, t_break{i});
        IOIrationndist{i} = ft_ioirationndist(t_onset{i}, t_break{i});

        inteval_i = interval{i} + 10.*(rand(numel(interval{i}), 1) - 0.5);
        X = sort(inteval_i);
        intervalnndist{i} = conv(diff(X), [0.5; 0.5]);
        %{
        NS = createns(inteval_i, 'NSMethod', 'exhaustive');
        [~, D] = knnsearch(NS, inteval_i, 'K', 13);
        intervalnndist{i} = D(:, end);
        %}
    end

    for i=1:numel(idx_pair)
        idx_song = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, typelist{1});
        idx_desc = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, typelist{2});

        d = pb_effectsize(IOI{idx_song}, IOI{idx_desc});
        results(end + 1, :) = table({'IOI'}, datainfo.language(idx_song), d, {'common language effect size'});
        
        d = pb_effectsize(OBI{idx_song}, OBI{idx_desc});
        results(end + 1, :) = table({'Onset-break interval'}, datainfo.language(idx_song), d, {'common language effect size'});

        d = pb_effectsize(IOIrationndist{idx_song}, IOIrationndist{idx_desc});
        results(end + 1, :) = table({'NN distance among IOI ratios'}, datainfo.language(idx_song), d, {'common language effect size'});

        d = pb_effectsize(intervalnndist{idx_song}, intervalnndist{idx_desc});
        results(end + 1, :) = table({'NN distance among intervals'}, datainfo.language(idx_song), d, {'common language effect size'});
    end
    
    %% nPVI (Duratonal variability)
    %{
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
    %}
    
    %% nPC (Duratonal variability)
    %{
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
    %}
    
    %% Isochrony (1)
    %{
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
    %}
    
    %%
    writetable(results, strcat(outputdir, 'results_Marsden-complete.csv'));
end