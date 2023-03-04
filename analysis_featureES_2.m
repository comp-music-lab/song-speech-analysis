function analysis_featureES_2(datainfofile, duration, typeflag, exploratory, outputdir)
    switch typeflag
        case 1
            typelist = {'song', 'desc'};
        case 2
            typelist = {'inst', 'desc'};
        case 3
            typelist = {'song', 'recit'};
    end

    %% configuration
    fileid = strcat(num2str(duration, '%d'), 'sec');
    datainfo = readtable(datainfofile);
    datainfo = datainfo(strcmp(datainfo.type, typelist{1}) | strcmp(datainfo.type, typelist{2}), :);

    addpath('./lib/two-sample/');
    
    varNames = {'feature', 'lang', 'diff', 'stderr', 'ci95_l', 'ci95_u', 'method'};
    varTypes = {'string', 'string', 'double', 'double', 'double', 'double', 'string'};
    idx_pair = unique(datainfo.groupid);
    results = table('Size', [0, numel(varNames)], 'VariableTypes', varTypes, 'VariableNames', varNames);
    
    reffreq = 440;
    
    %% ETL
    N = size(datainfo, 1);
    t_onset = cell(N, 1);
    t_break = cell(N, 1);
    f0 = cell(N, 1);
    t_f0 = cell(N, 1);
    interval = cell(N, 1);
    
    for i=1:N
        onsetfilepath = strcat(datainfo.annotationdir{i}, 'onset_', datainfo.dataname{i}, '.csv');
        T = readtable(onsetfilepath);
        t_onset{i} = table2array(T(:, 1));
        
        breakfilepath = strcat(datainfo.annotationdir{i}, 'break_', datainfo.dataname{i}, '.csv');
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

        f0filepath = strcat(datainfo.annotationdir{i}, datainfo.dataname{i}, '_f0.csv');
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
        interval{i} = helper.h_subsampling(tmp, 1024);
        interval{i} = interval{i}{1};
    end
    
    %% Comparison
    IOIrate = cell(N, 1); % Speed (IOI)
    pitchdeclination = cell(N, 1); % pitch declination
    intervalsize = cell(N, 1); % pitch interval size
    
    for i=1:N
        IOIrate{i} = 1./ft_ioi(t_onset{i}, t_break{i});
        intervalsize{i} = abs(interval{i});
        try
            pitchdeclination{i} = ft_f0declination(t_onset{i}, t_break{i}, f0{i}, t_f0{i});
        catch
            pitchdeclination{i} = NaN;
        end
    end

    for i=1:numel(idx_pair)
        idx_song = datainfo.groupid == idx_pair(i) & strcmp(datainfo.type, typelist{1});
        idx_desc = datainfo.groupid == idx_pair(i) & strcmp(datainfo.type, typelist{2});

        [d, tau, dof] = pb_effectsize(IOIrate{idx_song}, IOIrate{idx_desc});
        u = tinv(1 - 0.05/2, dof);
        results(end + 1, :) = table({'IOI rate'}, datainfo.language(idx_song), 1 - d, tau, 1 - d - tau*u, 1 - d + tau*u, {'common language effect size'});
        
        [d, tau, dof] = pb_effectsize(intervalsize{idx_song}, intervalsize{idx_desc});
        u = tinv(1 - 0.05/2, dof);
        results(end + 1, :) = table({'f0 ratio'}, datainfo.language(idx_song), d, tau, d - tau*u, d + tau*u, {'common language effect size'});

        [d, tau, dof] = pb_effectsize(pitchdeclination{idx_song}, pitchdeclination{idx_desc});
        u = tinv(1 - 0.05/2, dof);
        results(end + 1, :) = table({'Sign of f0 slope'}, datainfo.language(idx_song), d, tau, d - tau*u, d + tau*u, {'common language effect size'});
    end
    
    %% Exploratory feature
    if exploratory
        addpath('./lib/KDE/');
        
        SF = cell(N, 1); % Spectral flatness
        OBI = cell(N, 1); % Phrase length (first onset-final break interval)
        IOIratiodev = cell(N, 1); % IOI regularity
        intervaldev = cell(N, 1); % interval regularity
        pitchrange = cell(N, 1); % melodic range
        E = cell(N, 1);

        for i=1:N
            audiofilepath = strcat(datainfo.audiodir{i}, datainfo.dataname{i}, '.', datainfo.audioext{i});
    
            SF{i} = ft_spectralflatness(audiofilepath, t_onset{i}, t_break{i}, duration);
            E{i} = ft_energy(audiofilepath, t_onset{i}, t_break{i}, duration);
            OBI{i} = ft_obi(t_onset{i}, t_break{i});
            IOIratiodev{i} = ft_ioiratiodev(t_onset{i}, t_break{i});
            intervaldev{i} = ft_intervaldev(interval{i});
            pitchrange{i} = ft_pitchrange(t_onset{i}, t_break{i}, f0{i}, t_f0{i});
        end

        for i=1:numel(idx_pair)
            idx_song = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, typelist{1});
            idx_desc = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, typelist{2});
            
            [d, tau, dof] = pb_effectsize(SF{idx_song}, SF{idx_desc});
            u = tinv(1 - 0.05/2, dof);
            results(end + 1, :) = table({'Spectral flatness'}, datainfo.language(idx_song), 1 - d, tau, 1 - d - tau*u, 1 - d + tau*u, {'common language effect size'});
    
            [d, tau, dof] = pb_effectsize(OBI{idx_song}, OBI{idx_desc});
            u = tinv(1 - 0.05/2, dof);
            results(end + 1, :) = table({'Onset-break interval'}, datainfo.language(idx_song), d, tau, d - tau*u, d + tau*u, {'common language effect size'});
    
            [d, tau, dof] = pb_effectsize(IOIratiodev{idx_song}, IOIratiodev{idx_desc});
            u = tinv(1 - 0.05/2, dof);
            results(end + 1, :) = table({'IOI ratio deviation'}, datainfo.language(idx_song), 1 - d, tau, 1 - d - tau*u, 1 - d + tau*u, {'common language effect size'});
    
            [d, tau, dof] = pb_effectsize(intervaldev{idx_song}, intervaldev{idx_desc});
            u = tinv(1 - 0.05/2, dof);
            results(end + 1, :) = table({'f0 ratio deviation'}, datainfo.language(idx_song), 1 - d, tau, 1 - d - tau*u, 1 - d + tau*u, {'common language effect size'});
    
            [d, tau, dof] = pb_effectsize(pitchrange{idx_song}, pitchrange{idx_desc});
            u = tinv(1 - 0.05/2, dof);
            results(end + 1, :) = table({'90% f0 quantile length'}, datainfo.language(idx_song), d, tau, d - tau*u, d + tau*u, {'common language effect size'});
            
            [d, tau, dof] = pb_effectsize(E{idx_song}, E{idx_desc});
            u = tinv(1 - 0.05/2, dof);
            results(end + 1, :) = table({'Short-term energy'}, datainfo.language(idx_song), d, tau, d - tau*u, d + tau*u, {'common language effect size'});
        end
    end

    %%
    writetable(results, strcat(outputdir, 'results_effectsize_seg_', typelist{1}, '-', typelist{2}, '_', fileid, '.csv'));
end