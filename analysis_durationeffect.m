function analysis_durationeffect
    %%
    outputdir = './output/20220918/';
    datadir = './output/20220918/';
    fileid = {'results_Marsden-all_song-desc', 'results_Marsden-complete_song-desc'};
    T_ref = [readtable(strcat(datadir, fileid{1}, '_Infsec.csv')); readtable(strcat(datadir, fileid{2}, '_Infsec.csv'))];

    featurelist = unique(T_ref.feature);
    featurename = {{'Loudness', '(Short-term energy)'}, {'Pitch', '(f0)'}, {'Vocal production speed', '(IOI)'},...
        {'Rhythmic regularity', '(IOI ratio deviation)'}, {'Interval regularity', '(Pitch ratio deviation)'},...
        {'Interval size', '(Pitch ratio)'}, {'Pitch discreteness', '(Rate of change of f0)'},...
        {'Phrase length', '(Onset-break interval)'}, {'Pitch range', '(90% f0 quantile length)'},...
        {'Pulse clarity', '(Pulse clarity)'}, {'Brightness', '(Spectral centroid)'}};
    langlist = unique(T_ref.lang);
    
    %%
    duration = [1, 2, 3, 4, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70];
    T = cell(numel(duration), 1);

    for i=1:numel(duration)
        T{i} = [readtable(strcat(datadir, fileid{1}, '_', num2str(duration(i), '%d'), 'sec.csv')); ...
            readtable(strcat(datadir, fileid{2}, '_', num2str(duration(i), '%d'), 'sec.csv'))];
    end
    
    %%
    idx_ed = zeros(numel(langlist), 1);
    T_audio = readtable('./datainfo_Marsden-complete_song-desc.csv');

    for i=1:numel(langlist)
        idx = strcmp(T_audio.language, langlist{i});
        audiofilepath = strcat(T_audio.audiofilepath(idx), T_audio.dataname(idx), '.wav');
        [x, fs_x] = audioread(audiofilepath{1});
        [y, fs_y] = audioread(audiofilepath{2});
        duration_i = max(size(x, 1)/fs_x, size(y, 1)/fs_y);
        idx_ed(i) = find(duration_i < duration, 1, 'first');
    end

    %%
    pprm = plotprm();
    h = zeros(numel(langlist), 1);
    es_d = zeros(numel(duration), 1);
    M = 10:10:max(duration);

    for i=1:numel(featurelist)
        figobj = figure(i);

        for j=1:numel(langlist)
            idx = strcmp(T_ref.feature, featurelist{i}) & strcmp(T_ref.lang, langlist{j});
            es_ref = T_ref.diff(idx);

            for k=1:numel(duration)
                idx = strcmp(T{k}.feature, featurelist{i}) & strcmp(T{k}.lang, langlist{j});
                es_d(k) = T{k}.diff(idx);
            end
            
            idx_st = find(isnan(es_d), 1, 'last') + 1;
            if isempty(idx_st)
                idx_st = 1;
            end

            scatter(duration(idx_st:idx_ed(j)), es_d(idx_st:idx_ed(j)), 'MarkerEdgeColor', pprm.langcolormap(langlist{j}));
            hold on
            plot(duration(idx_st:idx_ed(j)), es_d(idx_st:idx_ed(j)), 'Color', pprm.langcolormap(langlist{j}));
            plot([duration(idx_st), duration(idx_ed(j))], es_ref.*[1, 1], 'linestyle', '--', 'Color', pprm.langcolormap(langlist{j}));
        end
        
        for j=1:numel(M)
            plot(M(j).*[1, 1], [0, 1], ':k', 'linewidth', 1);
        end

        for j=1:numel(langlist)
            h(j) = plot(NaN, NaN, 'Color', pprm.langcolormap(langlist{j}));
        end
        legend(h, langlist, 'Location', 'southeast');
        
        xlabel('Excerpt length (sec.)', 'FontSize', 13);
        ylabel('Effect size (relative effect)', 'FontSize', 13);

        hold off
        ylim([0, 1]);
        title(featurename{i}, 'FontSize', 18);

        saveas(figobj, strcat(outputdir, featurelist{i}, '.png'));
    end
end