function analysis_f0
    %% Setting for the S1 RR
    %{
    typelist = {'desc', 'recit', 'song', 'inst'};
    outputdir = './output/fig/';
    datainfo = readtable('datainfo_full.csv');
    %}

    %% Setting for FMA 2022
    %%{
    typelist = {'song', 'speech'};
    outputdir = './output/FMA2022/';
    datainfo = readtable('datainfo_pilot+full.csv');
    %}
    
    for i=1:2
        switch i
            case 1
                datainfo_i = datainfo(strcmp(datainfo.sex, 'F'), :);
                outputfileid = 'female';
            case 2
                datainfo_i = datainfo(strcmp(datainfo.sex, 'M'), :);
                outputfileid = 'male';
        end
        
        %% Get f0 data
        %D = helper.h_subsampling(helper.h_ETL_f0(datainfo_i.dataname, datainfo_i.path), 4096);
        
        %% Density estimation
        %kde_all(D, datainfo_i.type, typelist, outputfileid, outputdir);
    end

    %% Pitch discreteness
    dataname = datainfo.dataname;
    outputfileid = '';
    discreteness = pitchdiscreteness(datainfo.path, dataname, datainfo.type, typelist, datainfo.language, outputfileid, outputdir);

    %% Delta F0
    dataname = datainfo.dataname;
    outputfileid = '';
    deltaF0(datainfo.path, discreteness, dataname, datainfo.type, typelist, outputfileid, outputdir);
end

function deltaF0(datadir, discreteness, dataname, datatype, typelist, outputfileid, outputdir)
    %% Delta F0 - setup
    pprm = plotprm();
    reffreq = 440;

    %% Delta F0 - computation
    addpath('./lib/CWT/');
    D = cell(numel(typelist), 1);
    F0mean = cell(numel(typelist), 1);

    for i=1:numel(typelist)
        idx = find(contains(datatype, typelist{i}));
        D_i = cell(numel(idx), 1);
        F0mean_i = zeros(numel(idx), 1);

        for j=1:numel(idx)
            fprintf('%s\n', datetime);
            df0 = [];

            %%
            f0info = readtable(strcat(datadir{idx(j)}, dataname{idx(j)}, '_f0.csv'));
            f0 = table2array(f0info(:, 2));
            f0_cent = 1200.*log2(f0./reffreq);
            
            t_f0 = table2array(f0info(:, 1));
            dlt = mean(diff(t_f0));

            %%
            idx_ed = 0;
            idx_st = find(~isinf(f0_cent(idx_ed + 1:end)), 1, 'first') + idx_ed;

            while ~isempty(idx_st)
                idx_ed = find(isinf(f0_cent(idx_st:end)), 1, 'first') + idx_st - 2;
                f0_cent_i = f0_cent(idx_st:idx_ed);
                df0_j = cwtdiff(f0_cent_i, 0.02, 1/dlt, 1);
                %df0_j = (f0_cent_i(3:end) - f0_cent_i(1:end - 2))./(2*dlt);
                df0 = [df0; df0_j];

                idx_st = find(~isinf(f0_cent(idx_ed + 1:end)), 1, 'first') + idx_ed;
            end

            D_i{j} = df0;
            F0mean_i(j) = median(f0(f0 ~= 0));
        end

        D{i} = helper.h_subsampling(D_i, 4096);
        F0mean{i} = F0mean_i;
    end
    
    %% KDE - setup
    addpath('./lib/KDE/');
    x = linspace(min(cellfun(@(D_i) min(cellfun(@min, D_i)), D)), max(cellfun(@(D_i) max(cellfun(@max, D_i)), D)), 1024);
    f = zeros(numel(x), numel(typelist));
    C = zeros(numel(typelist), 1);
    
    %% KDE - computation
    for i=1:numel(typelist)
        X = D{i};
        X = cat(1, X{:});
        
	    h = kdebandwidth_lp(X);
        density = kde(x, X, h);
        
        f(:, i) = density;
        C(i) = trapz(x, f(:, i));

        fprintf('%s: h = %3.3f\n', typelist{i}, h);
    end

    f = bsxfun(@rdivide, f, C');

    f_D = cell(numel(typelist), 1);
    for i=1:numel(typelist)
        f_D{i} = zeros(numel(x), numel(D{i}));

        for j=1:numel(D{i})
            X = D{i}{j};
            h = kdebandwidth_lp(X);
            density = kde(x, X, h);
            C_i = trapz(x, density);
            f_D{i}(:, j) = density./C_i;
        end
    end
    
    %%
    figobj = figure;
    figobj.Position = [100, 400, 700, 550];

    for i=1:numel(typelist)
        plot(x, f(:, i), 'LineWidth', pprm.linewidth, 'Color', pprm.colorcode{i});
        hold on
    end
    legend(typelist, 'FontSize', pprm.legendfontsize);
    hold off

    xlabel('\partial F0/\partial t (cent)', 'FontSize', pprm.labelfontsize);
    ylabel('Probability density', 'FontSize', pprm.labelfontsize);
    title('\DeltaF0 distribution', 'FontSize', pprm.titlefontsize);
    axis tight;
    xlim([-10000, 10000]);

    ax = gca(figobj);
    ax.FontSize = pprm.tickfontsize;
    drawnow();

    saveas(figobj, strcat(outputdir, 'dF0dist_all_', outputfileid, '.png'));
    
    %%
    %{
    for i=1:numel(typelist)
        figobj = figure;
        figobj.Position = [100, 400, 700, 550];
        
        p = waterfall(x, 1:size(f_D{i}, 2), f_D{i}');
        set(p, 'EdgeAlpha', 0.5);
        set(p, 'FaceAlpha', 0.3);
        set(p, 'FaceColor', 'flat');
        set(p, 'EdgeColor', 'flat');
        set(gca, 'ZTickLabel', []);
        
        xlim([-10000, 10000]);
    
        title(['\DeltaF0 distribution', ' (', typelist{i}, ')'], 'FontSize', pprm.titlefontsize);
        xlabel(xlabelstr, 'FontSize', pprm.labelfontsize);
        ylabel('Audio file', 'FontSize', pprm.labelfontsize);
        ax = gca(figobj);
        ax.FontSize = pprm.tickfontsize;
    
        view(-0.25, 80);
    
        saveas(figobj, strcat(outputdir, 'dF0dist_', typelist{i}, '_', outputfileid, '_wf.png'));
    end
    %}
    
    %% Entropy
    H = cell(numel(typelist), 1);
    K = 10;

    for i=1:numel(typelist)
        H{i} = cellfun(@(D_i) klentropy(D_i, K), D{i});
    end

    %%
    figobj = figure;
    figobj.Position = [100, 400, 700, 550];
    
    for i=1:numel(typelist)
        X = H{i};
        scatter(normrnd(i, 0.1, [numel(X), 1]), X, 'MarkerEdgeColor', pprm.colorcode{i});
        hold on
        scatter(i, mean(X(~isinf(X))), 'MarkerEdgeColor', 'none', 'MarkerFaceColor', 'k', 'MarkerFaceAlpha', 0.6);
    end
    
    set(gca, 'XTick', 1:numel(typelist));
    set(gca, 'XTickLabel', typelist);
    xlim([1 - 0.8, numel(typelist) + 0.8]);
    hold off;

    title('\Delta F0 entropy', 'FontSize', pprm.titlefontsize);
    ylabel('\Delta F0 entropy', 'FontSize', pprm.labelfontsize);
    ax = gca(figobj);
    ax.FontSize = pprm.tickfontsize;

    saveas(figobj, strcat(outputdir, 'dF0dist_', outputfileid, '_entropy.png'));

    %%
    deltavar = cell(numel(typelist), 1);
    compositecoef = cell(numel(typelist), 1);

    for i=1:numel(typelist)
        deltavar{i} = cellfun(@(X) sqrt(var(X, 1)), D{i});
        compositecoef{i} = deltavar{i}.*cell2mat(discreteness{i}).*(1./F0mean{i});
    end
    
    %%
    figobj = figure;
    figobj.Position = [100, 400, 700, 550];
    
    for i=1:numel(typelist)
        X = compositecoef{i};
        scatter(normrnd(i, 0.1, [numel(X), 1]), X, 'MarkerEdgeColor', pprm.colorcode{i});
        hold on
    end
    
    set(gca, 'XTick', 1:numel(typelist));
    set(gca, 'XTickLabel', typelist);
    xlim([1 - 0.8, numel(typelist) + 0.8]);
    hold off;

    title('Composite score', 'FontSize', pprm.titlefontsize);
    ylabel('Pitch discreteness x Std[\DeltaF0] x median(F0)^{-1}', 'FontSize', pprm.labelfontsize);
    ax = gca(figobj);
    ax.FontSize = pprm.tickfontsize;

    saveas(figobj, strcat(outputdir, 'F0dist_', outputfileid, '_compcoef.png'));
end

function discreteness = pitchdiscreteness(datadir, dataname, datatype, typelist, datalang, outputfileid, outputdir)
    %% Entropy - setup
    pprm = plotprm();
    reffreq = 440;

    %% Entropy - computation
    addpath('./lib/KDE/');
    K = 8;
    dlt = 10;
    M = 1;
    H_eps = zeros(M, 1);
    discreteness = cell(numel(typelist), 1);

    for i=1:numel(typelist)
        idx = find(contains(datatype, typelist{i}));
        discreteness_i = cell(numel(idx), 1);

        for j=1:numel(idx)
            fprintf('%s\n', datetime);

            %%
            f0info = readtable(strcat(datadir{idx(j)}, dataname{idx(j)}, '_f0.csv'));
            f0_cent = 1200.*log2(table2array(f0info(:, 2))./reffreq);
            t_f0 = table2array(f0info(:, 1));
            
            %%
            onsetinfo = readtable(strcat(datadir{idx(j)}, 'onset_', dataname{idx(j)}, '.csv'));
            breakinfo = readtable(strcat(datadir{idx(j)}, 'break_', dataname{idx(j)}, '.csv'));
            [~, t_st, t_ed] = helper.h_ioi(table2array(onsetinfo(:, 1)), table2array(breakinfo(:, 1)));
    
            %%
            H = [];
            L = [];
            f0_cent = f0_cent(:);
    
            for k=1:numel(t_st)
                [~, idx_st] = min(abs(t_f0 - t_st(k)));
                [~, idx_ed] = min(abs(t_f0 - t_ed(k)));
    
                f0_cent_k = f0_cent(idx_st:idx_ed);
    
                idx_st_k = find(~isinf(f0_cent_k), 1, 'first');
                while ~isempty(idx_st_k)
                    idx_ed_k = find(isinf(f0_cent_k(idx_st_k:end)), 1, 'first') - 1 + idx_st_k - 1;
    
                    if isempty(idx_ed_k)
                        idx_ed_k = numel(f0_cent_k);
                    end
                    
                    if (idx_ed_k - idx_st_k + 1) > K
                        X = f0_cent_k(idx_st_k:idx_ed_k);
                        eps = dlt.*(rand(numel(X), M) - 0.5);
                        for m=1:M
                            Y = X + eps(:, m);
                            H_eps(m) = klentropy(Y, K);
                        end

                        H(end + 1) = mean(H_eps);
                        L(end + 1) = t_f0(idx_ed_k) - t_f0(idx_st_k);
                    end
    
                    idx_st_k = find(~isinf(f0_cent_k(idx_ed_k + 1:end)), 1, 'first') + idx_ed_k;
                end
            end

            %discreteness_i{j} = mean(H./L);
            %%{
            w = L./sum(L);
            discreteness_i{j} = w*H';
            %}
        end

        discreteness{i} = discreteness_i;
    end

    %% plot
    langlist = unique(datalang);
    
    figobj = figure;
    figobj.Position = [100, 400, 700, 550];
    h = zeros(numel(typelist) + numel(langlist) + 1, 1);

    for i=1:numel(typelist)
        X = cat(1, discreteness{i}{:});
        
        for j=1:numel(langlist)
            idx = strcmp(datalang(strcmp(datatype, typelist{i})), langlist{j});
            
            scatter(normrnd(i, 0.1, [numel(X(idx)), 1]), X(idx),...
                'Marker', pprm.langmarkermap(langlist{j}),  'MarkerEdgeColor', pprm.colorcode{i});
            hold on
        end

        scatter(i, mean(X), 'MarkerFaceColor', 'k', 'MarkerFaceAlpha', 0.6, 'MarkerEdgeColor', 'none');
        h(i) = scatter(NaN, NaN, 'MarkerEdgeColor', pprm.colorcode{i});
    end

    for i=1:numel(langlist)
        h(numel(typelist) + i) = scatter(NaN, NaN, 'Marker', pprm.langmarkermap(langlist{i}), 'MarkerEdgeColor', 'k');
    end
    
    h(end) = scatter(NaN, NaN, 'MarkerFaceColor', 'k', 'MarkerFaceAlpha', 0.6, 'MarkerEdgeColor', 'none');

    legend(h, [typelist, langlist', 'Mean'], 'FontSize', pprm.legendfontsize);
    hold off

    xlim([0, numel(typelist) + 1.0]);
    set(gca, 'XTick', 1:numel(typelist));
    set(gca, 'XTickLabel', typelist);

    ylabel('Discreteness score', 'FontSize', pprm.labelfontsize);
    title('Pitch discreteness', 'FontSize', pprm.titlefontsize);

    ax = gca(figobj);
    ax.FontSize = pprm.tickfontsize;
    drawnow();

    saveas(figobj, strcat(outputdir, 'pitchdiscreteness_', outputfileid, '.png'));
end

function kde_all(D, datatype, typelist, outputfileid, outputdir)
    %% KDE - setup
    pprm = plotprm();

    addpath('./lib/KDE/');
    dlt = 10;
    L = 64;
    h_L = zeros(L, 1);
    x = (dlt*round(min(cellfun(@min, D))/dlt) - 100 - dlt/2):dlt:(dlt*round(max(cellfun(@max, D))/dlt) + 100 + dlt/2);
    f = zeros(numel(x), numel(typelist));
    C = zeros(numel(typelist), 1);
    
    %% KDE - computation
    for i=1:numel(typelist)
        idx = contains(datatype, typelist{i});
        X = D(idx, 1);
        X = cat(1, X{:});
        
        n = size(X, 1);
        parfor l=1:L
		    Y = X + dlt.*rand(n, 1) - dlt/2;
		    h_L(l) = kdebandwidth_lp(Y);
        end
        h = mean(h_L);
        density = kde(x, X, h);
        
        f(:, i) = density;
        C(i) = trapz(x, f(:, i));

        fprintf('%s: h = %3.3f\n', typelist{i}, h);
    end

    f = bsxfun(@rdivide, f, C');
    
    %% plot
    yl = [0, max(f(:))*1.1];

    for i=1:numel(typelist)
        figobj = figure(i);
        figobj.Position = [100, 400, 700, 550];
        plot(x, f(:, i), 'LineWidth', pprm.linewidth, 'Color', pprm.colorcode{i});
        
        xlabel('Frequency (cent)', 'FontSize', pprm.labelfontsize);
        ylabel('Probability density', 'FontSize', pprm.labelfontsize);
        title(['F0 distribution (', typelist{i}, ')'], 'FontSize', pprm.titlefontsize);
        axis tight;
        ylim(yl);

        ax = gca(figobj);
        ax.FontSize = pprm.tickfontsize;

        saveas(figobj, strcat(outputdir, 'F0dist_', typelist{i}, '_', outputfileid, '.png'));
    end

    %%
    figobj = figure(5);
    figobj.Position = [100, 400, 700, 550];

    for i=1:numel(typelist)
        plot(x, f(:, i), 'LineWidth', pprm.linewidth, 'Color', pprm.colorcode{i});
        hold on
    end
    legend(typelist, 'FontSize', pprm.legendfontsize);
    hold off

    xlabel('Frequency (cent)', 'FontSize', pprm.labelfontsize);
    ylabel('Probability density', 'FontSize', pprm.labelfontsize);
    title('F0 distribution', 'FontSize', pprm.titlefontsize);
    axis tight;
    ylim(yl);

    ax = gca(figobj);
    ax.FontSize = pprm.tickfontsize;
    drawnow();

    saveas(figobj, strcat(outputdir, 'F0dist_all_', outputfileid, '.png'));
end