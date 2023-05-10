function analysis_normalizedcontour(datainfo, duration, outputdir)
    %%
    N = 128;
    datatype = {'desc', 'song', 'recit', 'inst'};
    plottitle = {'Spoken description', 'Song', 'Lyrics recitation', 'Instrumental'};

    %%
    for i=1:numel(datatype)
        datainfo_i = datainfo(strcmp(datainfo.type, datatype{i}), :);
        C = zeros(0, N);

        for j=1:size(datainfo_i, 1)
            f0filepath = strcat(datainfo_i.annotationdir{j}, datainfo_i.dataname{j}, '_f0.csv');
            if isfile(f0filepath)
                T = readtable(f0filepath);
                f0 = T.voice_1;
                t_f0 = T.time;

                onsetfilepath = strcat(datainfo_i.annotationdir{j}, 'onset_', datainfo_i.dataname{j}, '.csv');
                breakfilepath = strcat(datainfo_i.annotationdir{j}, 'break_', datainfo_i.dataname{j}, '.csv');
                onsetinfo = readtable(onsetfilepath, 'ReadVariableNames', false);
                breakinfo = readtable(breakfilepath, 'ReadVariableNames', false);
                t_onset = table2array(onsetinfo(:, 1));
                if iscell(t_onset)
                    t_onset = cell2mat(t_onset);
                end
                if ~isempty(breakinfo)
                    t_break = table2array(breakinfo(:, 1));
                    if iscell(t_break)
                        t_break = str2double(cell2mat(t_break));
                    end
                else
                    t_break = [];
                end

                t_onset = t_onset(t_onset <= duration);
                t_break = t_break(t_break <= duration);
                t_seg = helper.h_phraseseg(t_onset, t_break);

                for k=1:size(t_seg, 1)
                    [~, idx_st] = min(abs(t_seg(k, 1) - t_f0));
                    [~, idx_ed] = min(abs(t_seg(k, 2) - t_f0));
                    f0_k = f0(idx_st:idx_ed);

                    if f0_k(1) == 0
                        idx = find(f0_k ~= 0, 1, 'first');
                        f0_k = f0_k(idx:end);
                    end

                    f0_k = flipud(f0_k);
                    if f0_k(1) == 0
                        idx = find(f0_k ~= 0, 1, 'first');
                        f0_k = f0_k(idx:end);
                    end
                    f0_k = flipud(f0_k);
                   
                    f0_n = f0_k - mean(f0_k(f0_k ~= 0));
                    f0_n = f0_n./std(f0_n(f0_n ~= 0), 0);
                    f0_min = min(f0_n(f0_n ~= min(f0_n)));
                    
                    C_k = f0_n;
                    C_k(isinf(C_k)) = NaN;
                    x = 1:numel(C_k);
                    C_k(isnan(C_k)) = interp1(x(~isnan(C_k)), C_k(~isnan(C_k)), x(isnan(C_k)), 'spline') ;

                    C_k = interpft(C_k, N);
                    C_k(C_k < f0_min) = NaN;
                    
                    C(end + 1, :) = C_k;
                end
            end
        end
        
        writematrix(C, strcat('./output/analysis/Stage2/contour_', datatype{i}, '.csv'));

        df = arrayfun(@(n) sum(~isnan(C(:, n))), 1:N);
        t = tinv(1 - 0.05/2, df - 1);
        s = std(C, 0, 1,'omitnan')./sqrt(size(C, 1));
        mu = mean(C, 1,'omitnan');

        fobj = figure;
        plot(mu, 'linewidth', 2.5);
        hold on
        plot(mu - t.*s, 'linewidth', 1.5, 'LineStyle', '-.', 'Color', [80, 80, 80]./256);
        plot(mu + t.*s, 'linewidth', 1.5, 'LineStyle', '-.', 'Color', [80, 80, 80]./256);
        hold off
        ax = gca(fobj);
        ax.FontSize = 18;
        title(plottitle{i}, 'FontSize', 22);
        xlim([1, N]);
        ylim([-0.4, 0.4]);
        xlabel('Normalized sampling point', 'FontSize', 18);
        ylabel('Normalized frequency', 'FontSize', 18);
        fprintf('%s: %3.4f\n', plottitle{i}, mean(2.*t.*s));

        saveas(fobj, strcat(outputdir, 'meancontour_', plottitle{i}, '_', num2str(duration, '%d'), 'sec.png')); 
    end
end