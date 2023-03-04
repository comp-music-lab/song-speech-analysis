function analysis_featureES_1(datainfofile, duration, typeflag, exploratory, outputdir)
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
    addpath('./lib/CWT/');
    
    varNames = {'feature', 'lang', 'diff', 'stderr', 'ci95_l', 'ci95_u', 'method'};
    varTypes = {'string', 'string', 'double', 'double', 'double', 'double', 'string'};
    idx_pair = unique(datainfo.groupid);
    results = table('Size', [0, numel(varNames)], 'VariableTypes', varTypes, 'VariableNames', varNames);
    
    reffreq = 440;
    
    %% ETL
    N = size(datainfo, 1);
    f0 = cell(N, 1);
    t_f0 = cell(N, 1);
    
    for i=1:N
        f0filepath = strcat(datainfo.annotationdir{i}, datainfo.dataname{i}, '_f0.csv');
        T = readtable(f0filepath);
        f0{i} = table2array(T(:, 2));
        t_f0{i} = table2array(T(:, 1));

        idx = find(t_f0{i} <= duration, 1, 'last');
        f0{i} = f0{i}(1:idx);
        t_f0{i} = t_f0{i}(1:idx);
    end
    
    %% Comparison - main 
    modulationmagnitude = cell(N, 1); % pitch discreteness (modulation-based)
    SC = cell(N, 1); % Brightness (spectral centroid)
    
    for i=1:N
        tmp = -abs(ft_deltaf0(f0{i}, 0.005, reffreq));
        modulationmagnitude{i} = tmp(~isnan(tmp));

        audiofilepath = strcat(datainfo.audiodir{i}, datainfo.dataname{i}, '.', datainfo.audioext{i});
        SC{i} = ft_spectralcentroid(audiofilepath, f0{i}, t_f0{i}, duration, false);
    end

    for i=1:numel(idx_pair)
        idx_song = datainfo.groupid == idx_pair(i) & strcmp(datainfo.type, typelist{1});
        idx_desc = datainfo.groupid == idx_pair(i) & strcmp(datainfo.type, typelist{2});
        
        X = f0{idx_song}(f0{idx_song} ~= 0);
        Y = f0{idx_desc}(f0{idx_desc} ~= 0);
        [d, tau, dof] = pb_effectsize(X, Y);
        u = tinv(1 - 0.05/2, dof);
        results(end + 1, :) = table({'f0'}, datainfo.language(idx_song), d, tau, d - tau*u, d + tau*u, {'common language effect size'});

        [d, tau, dof] = pb_effectsize(modulationmagnitude{idx_song}, modulationmagnitude{idx_desc});
        u = tinv(1 - 0.05/2, dof);
        results(end + 1, :) = table({'-|Δf0|'}, datainfo.language(idx_song), d, tau, d - tau*u, d + tau*u, {'common language effect size'});

        [d, tau, dof] = pb_effectsize(SC{idx_song}, SC{idx_desc});
        u = tinv(1 - 0.05/2, dof);
        results(end + 1, :) = table({'Spectral centroid'}, datainfo.language(idx_song), d, tau, d - tau*u, d + tau*u, {'common language effect size'});
    end

    %% Exploratory feature
    if exploratory
        PC = cell(N, 1); % Pulse clarity
        
        for i=1:N
            audiofilepath = strcat(datainfo.audiofilepath{i}, datainfo.dataname{i}, '.wav');
            tmp =  mirpulseclarity(miraudio(audiofilepath, 'Extract', 0, duration), 'Frame');
            PC{i} = mirgetdata(tmp);
        end

        for i=1:numel(idx_pair)
            idx_song = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, typelist{1});
            idx_desc = datainfo.pair == idx_pair(i) & strcmp(datainfo.type, typelist{2});

            [d, tau, dof] = pb_effectsize(PC{idx_song}, PC{idx_desc});
            u = tinv(1 - 0.05/2, dof);
            results(end + 1, :) = table({'Pulse clarity'}, datainfo.language(idx_song), d, tau, d - tau*u, d + tau*u, {'common language effect size'});
        end
    end
    
    %%
    writetable(results, strcat(outputdir, 'results_effectsize_acoustic_', typelist{1}, '-', typelist{2}, '_', fileid, '.csv'));
end