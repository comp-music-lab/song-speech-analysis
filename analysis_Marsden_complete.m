function analysis_Marsden_complete(duration)
    %% configuration
    fileid = strcat(num2str(duration, '%d'), 'sec');

    typelist = {'song', 'desc'};
    datainfo = readtable(strcat('datainfo_Marsden-complete_', typelist{1}, '-', typelist{2}, '.csv'));
    outputdir = './output/20220918/';
    
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
    t_f0 = cell(N, 1);
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
        
        idx = find(t_onset{i} <= duration, 1, 'last');
        t_onset{i} = t_onset{i}(1:idx);
        idx = find(t_break{i} <= duration, 1, 'last');
        t_break{i} = t_break{i}(1:idx);

        f0filepath = strcat(datainfo.path{i}, datainfo.dataname{i}, '_f0.csv');
        T = readtable(f0filepath);
        f0{i} = table2array(T(:, 2));
        t_f0{i} = table2array(T(:, 1));
        
        idx = find(t_f0{i} <= duration, 1, 'last');
        f0{i} = f0{i}(1:idx);
        t_f0{i} = t_f0{i}(1:idx);

        f0_cent = 1200.*log2(f0{i}./reffreq);
        [~, ~, t_st, t_ed] = helper.h_ioi(t_onset{i}, t_break{i});
        I = helper.h_interval(f0_cent, t_f0{i}, t_st, t_ed);
        I = cat(1, I{:});
        tmp = cell(1, 1);
        tmp{1} = I;
        interval{i} = helper.h_subsampling(tmp, 2048);
        interval{i} = interval{i}{1};
    end
    
    %% Comparison
    IOI = cell(N, 1); % Speed (IOI)
    pitchdeclination = cell(N, 1); % pitch declination
    intervalsize = cell(N, 1); % interval range
    %OBI = cell(N, 1); % Phrase length (first onset-final break interval)
    %IOIratiodev = cell(N, 1); % IOI regularity
    %intervaldev = cell(N, 1); % interval regularity
    %pitchrange = cell(N, 1); % melodic range
    %E = cell(N, 1);
    
    for i=1:N
        %audiofilepath = strcat(datainfo.audiofilepath{i}, datainfo.dataname{i}, '.wav');
        %E{i} = ft_energy(audiofilepath, t_onset{i}, t_break{i}, duration);

        IOI{i} = ft_ioi(t_onset{i}, t_break{i});
        %OBI{i} = ft_obi(t_onset{i}, t_break{i});
        %IOIratiodev{i} = ft_ioiratiodev(t_onset{i}, t_break{i});
        %intervaldev{i} = ft_intervaldev(interval{i});
        %intervalsize{i} = abs(interval{i});
        intervalsize{i} = interval{i};
        %pitchrange{i} = ft_pitchrange(t_onset{i}, t_break{i}, f0{i}, t_f0{i});
        try
            pitchdeclination{i} = ft_f0declination(t_onset{i}, t_break{i}, f0{i}, t_f0{i});
        catch
            pitchdeclination{i} = NaN;
        end
    end

    for i=1:numel(idx_pair)
        idx_song = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, typelist{1});
        idx_desc = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, typelist{2});

        [d, tau] = pb_effectsize(IOI{idx_song}, IOI{idx_desc});
        results(end + 1, :) = table({'IOI'}, datainfo.language(idx_song), d, tau, {'common language effect size'});
        
        %[d, tau] = pb_effectsize(OBI{idx_song}, OBI{idx_desc});
        %results(end + 1, :) = table({'Onset-break interval'}, datainfo.language(idx_song), d, tau, {'common language effect size'});

        %[d, tau] = pb_effectsize(IOIratiodev{idx_song}, IOIratiodev{idx_desc});
        %results(end + 1, :) = table({'IOI ratio deviation'}, datainfo.language(idx_song), 1 - d, tau, {'common language effect size'});

        %[d, tau] = pb_effectsize(intervaldev{idx_song}, intervaldev{idx_desc});
        %results(end + 1, :) = table({'Interval deviation'}, datainfo.language(idx_song), 1 - d, tau, {'common language effect size'});

        [d, tau] = pb_effectsize(intervalsize{idx_song}, intervalsize{idx_desc});
        results(end + 1, :) = table({'f0 ratio'}, datainfo.language(idx_song), d, tau, {'common language effect size'});

        %[d, tau] = pb_effectsize(pitchrange{idx_song}, pitchrange{idx_desc});
        %results(end + 1, :) = table({'Pitch range'}, datainfo.language(idx_song), d, tau, {'common language effect size'});
        
        [d, tau] = pb_effectsize(pitchdeclination{idx_song}, pitchdeclination{idx_desc});
        results(end + 1, :) = table({'Sign of f0 slope'}, datainfo.language(idx_song), d, tau, {'common language effect size'});

        %[d, tau] = pb_effectsize(E{idx_song}, E{idx_desc});
        %results(end + 1, :) = table({'Energy'}, datainfo.language(idx_song), d, tau, {'common language effect size'});
    end
    
    %%
    writetable(results, strcat(outputdir, 'results_Marsden-complete_', typelist{1}, '-', typelist{2}, '_', fileid, '.csv'));
end