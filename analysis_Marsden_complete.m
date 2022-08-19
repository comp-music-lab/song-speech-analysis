function analysis_Marsden_complete
    %% configuration
    typelist = {'inst', 'desc'};
    datainfo = readtable('datainfo_Marsden-complete_inst-desc.csv');
    outputdir = './output/20220819/';
    
    addpath('./lib/two-sample/');
    addpath('./lib/KDE/');
    addpath('./lib/CWT/');
    
    varNames = {'feature', 'lang', 'diff', 'stderr', 'method'};
    idx_pair = unique(datainfo.pair);
    results = table('Size', [0, numel(varNames)], 'VariableTypes', {'string', 'string', 'double', 'double', 'string'}, 'VariableNames', varNames);
    
    reffreq = 440;
    
    %% ETL
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
        interval{i} = helper.h_subsampling(tmp, 2048);
        interval{i} = interval{i}{1};
    end
    
    %% Comparison
    IOI = cell(N, 1); % Speed (IOI)
    OBI = cell(N, 1); % Phrase length (first onset-final break interval)
    IOIratiodev = cell(N, 1); % IOI regularity
    intervaldev = cell(N, 1); % interval regularity
    
    for i=1:N
        IOI{i} = ft_ioi(t_onset{i}, t_break{i});
        OBI{i} = ft_obi(t_onset{i}, t_break{i});
        IOIratiodev{i} = ft_ioiratiodev(t_onset{i}, t_break{i});
        intervaldev{i} = ft_intervaldev(interval{i});
    end

    for i=1:numel(idx_pair)
        idx_song = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, typelist{1});
        idx_desc = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, typelist{2});

        [d, tau] = pb_effectsize(IOI{idx_song}, IOI{idx_desc});
        results(end + 1, :) = table({'IOI'}, datainfo.language(idx_song), d, tau, {'common language effect size'});
        
        [d, tau] = pb_effectsize(OBI{idx_song}, OBI{idx_desc});
        results(end + 1, :) = table({'Onset-break interval'}, datainfo.language(idx_song), d, tau, {'common language effect size'});

        [d, tau] = pb_effectsize(IOIratiodev{idx_song}, IOIratiodev{idx_desc});
        results(end + 1, :) = table({'IOI ratio deviation'}, datainfo.language(idx_song), 1 - d, tau, {'common language effect size'});

        [d, tau] = pb_effectsize(intervaldev{idx_song}, intervaldev{idx_desc});
        results(end + 1, :) = table({'Interval deviation'}, datainfo.language(idx_song), 1 - d, tau, {'common language effect size'});
    end
    
    %%
    writetable(results, strcat(outputdir, 'results_Marsden-complete_', typelist{1}, '-', typelist{2}, '.csv'));
end