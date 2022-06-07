function analysis_interval
    %{
    %% Setting for the S1 RR
    f0dir = '../f0-annotation-tool/output/';
    ioidir = '../onset-annotation-tool/output/';
    typelist = {'desc', 'recit', 'song', 'inst'};
    datainfo = readtable('datainfo_full.csv');
    dataname = datainfo.dataname;
    outputdir = './output/fig/';
    %}

    %% Setting for FMA 2022
    f0dir = './data/Pilot data/';
    ioidir = './data/Pilot data/';
    typelist = {'song', 'speech'};
    outputdir = './output/FMA2022/';
    datainfo = readtable('datainfo_pilot.csv');
    outputfileid = '';
    
    %%
    dataname = datainfo.dataname;
    
    %% Density estimation
    D = helper.h_subsampling(helper.h_ETL_intvl(dataname, f0dir, ioidir), 2048);
    kde_all(D, datainfo.type, typelist, outputfileid, outputdir);
end

function kde_all(D, datatype, typelist, outputfileid, outputdir)
    %% KDE - setup
    pprm = plotprm();
    pprm.xtickval = [-1200, -700, -500, -200, 0, 200, 500, 700, 1200];
    pprm.xticklabelstr = {'-1200', '-700', '-500', '-200', '0', '200', '500', '700', '1200'};

    addpath('./lib/KDE/');
    dlt = 10;
    L = 64;
    h_L = zeros(L, 1);
    x = (dlt*round(min(cellfun(@min, D))/dlt) - 100 - dlt/2):dlt:(dlt*round(max(cellfun(@max, D))/dlt) + 100 + dlt/2);
    f = zeros(numel(x), numel(typelist));
    f_D = cell(numel(typelist), 1);
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
    
    %%
    addpath('./lib/PH/');
    modes = cell(numel(typelist), 1);

    for i=1:numel(typelist)
        idx = find(contains(datatype, typelist{i}));
        
        f_D{i} = zeros(numel(x), numel(idx));
        for k=1:numel(idx)
            X = D{idx(k)};

            n = size(X, 1);
            parfor l=1:L
		        Y = X + dlt.*rand(n, 1) - dlt/2;
		        h_L(l) = kdebandwidth_lp(Y);
            end
            h = mean(h_L);
            f_D{i}(:, k) = kde(x, X, h);
        end
    end

    %%
    compositecoef = cell(numel(typelist), 1);

    for i=1:numel(typelist)
        modes_i = cell(size(f_D{i}, 2), 1);
        compositecoef_i = zeros(size(f_D{i}, 2), 1);

        for k=1:size(f_D{i}, 2)
            idx_mode = persistencemode_thresh(f_D{i}(:, k), 0.9);
            modes_i{k} = x(idx_mode);

            Y = dct(f_D{i}(:, k));
            YY = cumsum(Y.^2)./sum(Y.^2);
            compositecoef_i(k) = find(YY > 0.95, 1, 'first')./numel(YY).*(2*pi);
        end

        modes{i} = modes_i;
        compositecoef{i} = compositecoef_i;
    end

    %% plot
    yl = [0, max(f(:))*1.1];
    
    for i=1:numel(typelist)
        figobj = figure(i);
        figobj.Position = [100, 400, 700, 550];
        plot(x, f(:, i), 'LineWidth', pprm.linewidth, 'Color', pprm.colorcode{i});

        hold on
        stem(pprm.xtickval, repmat(yl(end), [numel(pprm.xtickval), 1]), 'Color', 'k', 'Marker', 'none', 'LineStyle', '--');
        hold off
        
        xlabel('Interval (cent)', 'FontSize', pprm.labelfontsize);
        ylabel('Probability density', 'FontSize', pprm.labelfontsize);
        title(['Interval distribution (', typelist{i}, ')'], 'FontSize', pprm.titlefontsize);
        axis tight;
        ylim(yl);
        
        xticks(pprm.xtickval);
        xticklabels(pprm.xticklabelstr);
        xtickangle(pprm.xangle);
        ax = gca(figobj);
        ax.FontSize = pprm.tickfontsize;

        saveas(figobj, strcat(outputdir, 'Intervaldist_', typelist{i}, '_', outputfileid, '.png'));
    end
    
    %%
    for i=1:numel(typelist)
        figobj = figure;
        figobj.Position = [100, 400, 700, 550];

        p = waterfall(x, 1:size(f_D{i}, 2), f_D{i}');
        set(p, 'EdgeAlpha', 0.5);
        set(p, 'FaceAlpha', 0.3);
        set(p, 'FaceColor', 'flat');
        set(p, 'EdgeColor', 'flat');
        set(gca, 'ZTickLabel', []);
        
        title(['Interval distribution (', typelist{i}, ')'], 'FontSize', pprm.titlefontsize);
        xlabel('Interval (cent)', 'FontSize', pprm.labelfontsize);
        ylabel('Audio file', 'FontSize', pprm.labelfontsize);
        xticks(pprm.xtickval);
        xticklabels(pprm.xticklabelstr);
        xtickangle(pprm.xangle);
        ax = gca(figobj);
        ax.FontSize = pprm.tickfontsize;

        xlim([-1200, 1200]);
        view(-0.25, 80);

        saveas(figobj, strcat(outputdir, 'Intervaldist_', typelist{i}, '_', outputfileid, '_wf.png'));
    end
    
    %%
    figobj = figure;
    figobj.Position = [100, 400, 700, 550];
    
    for i=1:numel(typelist)
        X = cat(2, modes{i}{:});
        scatter(normrnd(i, 0.1, [numel(X), 1]), X, 'MarkerEdgeColor', pprm.colorcode{i});
        hold on
    end
    
    set(gca, 'XTick', 1:numel(typelist));
    set(gca, 'XTickLabel', typelist);
    xlim([1 - 0.8, numel(typelist) + 0.8]);
    xl = xlim();

    for i=1:numel(pprm.xtickval)
        plot(xl, pprm.xtickval(i).*[1, 1], ':k');
    end
    hold off;
    
    set(gca, 'YTick', pprm.xtickval);
    set(gca, 'YTickLabel', pprm.xticklabelstr);

    title('Modes of intervals', 'FontSize', pprm.titlefontsize);
    ylabel('Prominent modes on intervals', 'FontSize', pprm.labelfontsize);
    ax = gca(figobj);
    ax.FontSize = pprm.tickfontsize;

    saveas(figobj, strcat(outputdir, 'Intervaldist_', outputfileid, '_persistmodes.png'));
    
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
    ylabel('95% DCT freq.', 'FontSize', pprm.labelfontsize);
    ax = gca(figobj);
    ax.FontSize = pprm.tickfontsize;

    saveas(figobj, strcat(outputdir, 'Intervaldist_', outputfileid, '_compcoef.png'));

    %% plot 2D
    figobj = figure(5);
    figobj.Position = [100, 400, 700, 550];

    for i=1:numel(typelist)
        plot(x, f(:, i), 'LineWidth', pprm.linewidth, 'Color', pprm.colorcode{i});
        hold on
    end
    
    stem(pprm.xtickval, repmat(yl(end), [numel(pprm.xtickval), 1]), 'Color', 'k', 'Marker', 'none', 'LineStyle', '--');
    xticks(pprm.xtickval);
    xticklabels(pprm.xticklabelstr);

    legend(typelist, 'FontSize', pprm.legendfontsize);
    hold off

    xlabel('Interval (cent)', 'FontSize', pprm.labelfontsize);
    ylabel('Probability density', 'FontSize', pprm.labelfontsize);
    title('Interval distribution', 'FontSize', pprm.titlefontsize);
    xlim([-1200, 1200]);
    ylim(yl);

    ax = gca(figobj);
    ax.FontSize = pprm.tickfontsize;

    saveas(figobj, strcat(outputdir, 'Intervaldist_all', '_', outputfileid, '.png'));
end