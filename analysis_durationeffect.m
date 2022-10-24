function analysis_durationeffect
    %%
    outputdir = './output/20220918/';
    datadir = './output/20220918/';
    fileid = {'results_Marsden-all_song-desc', 'results_Marsden-complete_song-desc'};
    T_ref = [readtable(strcat(datadir, fileid{1}, '_Infsec.csv')); readtable(strcat(datadir, fileid{2}, '_Infsec.csv'))];

    featurelist = {'f0', 'IOI rate', 'f0 ratio', 'Spectral centroid', 'Sign of f0 slope'};
    featurename = {{'Pitch height', '(f0)'}, {'Temporal rate', '(IOI rate)'}, {'Pitch interval size', '(f0 ratio)'},...
        {'Timbre brightness', '(Spectral centroid)'}, {'Pitch declination', '(Sign of f0 slope)'}...
    };
    subplotnum = [1, 2, 4, 5, 6];
    langlist = unique(T_ref.lang);

    cutoffduration = 20;
    
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
    h = zeros(numel(langlist) + 2, 1);
    es_d = zeros(numel(duration), 1);
    M = 10:10:max(duration);
    
    figobj = figure;
    figobj.Position = [90, 150, 1200, 720];
    %ax = axes;

    for i=1:numel(featurelist)
        subplot(2, 3, subplotnum(i));
        
        for j=1:numel(langlist)
            %idx = strcmp(T_ref.feature, featurelist{i}) & strcmp(T_ref.lang, langlist{j});
            %es_ref = T_ref.diff(idx);

            for k=1:numel(duration)
                idx = strcmp(T{k}.feature, featurelist{i}) & strcmp(T{k}.lang, langlist{j});
                es_d(k) = T{k}.diff(idx);
            end
            
            idx_st = find(isnan(es_d), 1, 'last') + 1;
            if isempty(idx_st)
                idx_st = 1;
            end

            scatter(duration(idx_st:idx_ed(j)), es_d(idx_st:idx_ed(j)),...
                'MarkerEdgeColor', pprm.langcolormap(langlist{j}), 'Marker', '.', 'CData', 2);
            hold on
            plot(duration(idx_st:idx_ed(j)), es_d(idx_st:idx_ed(j)), 'Color', pprm.langcolormap(langlist{j}), 'LineWidth', 1.2);
            %plot([duration(idx_st), duration(idx_ed(j))], es_ref.*[1, 1], 'linestyle', '--', 'Color', pprm.langcolormap(langlist{j}), 'LineWidth', 1.2);
        end
        
        for j=1:numel(M)
            plot(M(j).*[1, 1], [0, 1], ':k', 'linewidth', 1);
        end

        plot(cutoffduration.*[1, 1], [0, 1], '--r', 'linewidth', 1);

        %%
        %{
        if subplotnum(i) == 6
            ax = gca(figobj);

            for j=1:numel(langlist)
                h(j) = plot(NaN, NaN, 'Color', pprm.langcolormap(langlist{j}), 'LineWidth', 1.2);
            end
            h(end - 1) = plot(NaN, NaN, '-k', 'LineWidth', 1.2);
            h(end) = plot(NaN, NaN, '--k', 'LineWidth', 1.2);

            legend(ax, h(1:end - 2), langlist, 'Location', 'southeast', 'FontSize', 17, 'Position', [0.682, 0.665, 0.117, 0.175]);
            ax = copyobj(ax, gcf);
            legend(ax, h(end - 1:end), {'Excerpt', 'Full-length'}, 'Location', 'southeast', 'FontSize', 17, 'Position', [0.823, 0.701, 0.127, 0.119]);
        end
        %}
        
        if subplotnum(i) > 3
            xlabel('Excerpt length (sec.)', 'FontSize', 13);
        end

        if mod(subplotnum(i), 3) == 1
            ylabel('Effect size (relative effect)', 'FontSize', 13);
        end

        title(featurename{i}, 'FontSize', 18);

        hold off

        ax = gca(figobj);
        ax.FontSize = 12;
        ylim([0, 1]);
    end

    saveas(figobj, strcat(outputdir, 'durationeffect.png'));
end