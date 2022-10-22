function analysis_ioi
    %% Setting for the S1 RR
    %{
    onsetdir = './data/Stage 1 RR Excerpt/';
    typelist = {'desc', 'recit', 'song', 'inst'};
    datainfo = readtable('datainfo_S1RR.csv');
    outputdir = './output/S1RR/';
    outputfileid = '';
    %}

    %% Setting for FMA 2022
    %{
    typelist = {'song', 'speech'};
    outputdir = './output/FMA2022/';
    datainfo = readtable('datainfo_pilot+full.csv');
    outputfileid = '';
    %}
    
    %% Setting for JCoLE 2022
    %%{
    typelist = {'song', 'speech'};
    outputdir = './output/JCoLE2022/';
    datainfo = readtable('datainfo_pilot.csv');
    outputfileid = '';
    %}

    %%
    D = helper.h_ETL_ioi(datainfo.dataname, datainfo.path);
    
    %% Density estimation
    kde_all(D, datainfo.type, typelist, outputfileid, outputdir);
end

function kde_all(D, datatype, typelist, outputfileid, outputdir)
    %% KDE - setup
    pprm = plotprm();
    pprm.xtickval = {[0, 0.5, 1, 1.5, 2, 2.5], [1/4, 1/3, 1/2, 2/3, 3/4]};
    pprm.xticklabelstr = {'1/4', '1/3', '1/2', '2/3', '3/4'};

    addpath('./lib/KDE/');
    C = {zeros(numel(typelist), 1), zeros(numel(typelist), 1)};
    f = cell(2, 1);
    x = cell(2, 1);
    y = linspace(-5, 5, 1024);
    f_D = cell(2, numel(typelist));
    IR = cell(numel(typelist), 1);
    ioirdur = cell(numel(typelist), 1);
    
    %% KDE - computation
    for j=1:2
        %%
        switch j
            case 1
                a = 0;
                b = 3.0;
            case 2
                a = 0;
                b = 1;
        end
        
        %%
        x{j} = normcdf(y).*(b - a);
        f{j} = zeros(numel(x{j}), numel(typelist));
        
        for i=1:numel(typelist)
            idx = find(contains(datatype, typelist{i}));
            X = D{j}(idx, 1);
            X = cat(1, X{:});

            Y = norminv((X - a)./(b - a), 0, 1);
            h = kdebandwidth_lp(Y);
            density_y = kde(y, Y, h);
            density = density_y .* 1./normpdf(norminv((x{j} - a)./(b - a), 0, 1), 0, 1) .* (1/(b - a));

            f{j}(:, i) = density;
            C{j}(i) = trapz(x{j}, f{j}(:, i));

            fprintf('%s: h_x = %3.3f\n', typelist{i}, h);

            %
            f_D{i, j} = zeros(numel(x{j}), numel(idx));
            if j == 2
                IR{i} = cell(numel(idx), 1);
                ioirdur{i} = cell(numel(idx), 1);
            end

            for k=1:numel(idx)
                X = D{j}{idx(k)};
                Y = norminv((X - a)./(b - a), 0, 1);

                h = kdebandwidth_lp(Y);

                density_y = kde(y, Y, h);
                density = density_y .* 1./normpdf(norminv((x{j} - a)./(b - a), 0, 1), 0, 1) .* (1/(b - a));
                f_D{i, j}(:, k) = density;
                fprintf('integral: %e\n', trapz(x{j}, density));

                if j == 2
                    density_y = arrayfun(@(Y_i)mean(normpdf(0, Y_i - Y, h)), Y);
                    density = density_y .* 1./normpdf(norminv((X - a)./(b - a), 0, 1), 0, 1) .* (1/(b - a));
                    IR{i}{k} = -log(density)./D{3}{idx(k)};
                    ioirdur{i}{k} = D{3}{idx(k)};
                end
            end
        end

        f{j} = bsxfun(@rdivide, f{j}, C{j}');
    end
    
    %%
    dctcoef = cell(numel(typelist), 1);
    for i=1:numel(typelist)
        N = size(f_D{i, 2}, 2);
        dctcoef{i} = zeros(N, 1);
        
        for n=1:N
            A = dct(f_D{i, 2}(:, n));
            dctcoef{i}(n) = find(cumsum(A.^2)./sum(A.^2) > 0.95, 1, 'first') * (2*pi/numel(A));
        end
    end
    
    %%
    figobj = figure;
    figobj.Position = [100, 400, 700, 550];
    
    for i=1:numel(typelist)
        X = cat(2, dctcoef{i});
        scatter(normrnd(i, 0.1, [numel(X), 1]), X, 'MarkerEdgeColor', pprm.colorcode{i});
        hold on
        scatter(i, mean(X), 'MarkerEdgeColor', 'none', 'MarkerFaceColor', 'k', 'MarkerFaceAlpha', 0.6);
    end
    
    set(gca, 'XTick', 1:numel(typelist));
    set(gca, 'XTickLabel', typelist);
    xlim([1 - 0.8, numel(typelist) + 0.8]);
    hold off;
    
    title('95% power of DCT components of the IOI ratio distribution', 'FontSize', pprm.titlefontsize);
    ylabel('DCT frequency (radian)', 'FontSize', pprm.labelfontsize);
    ax = gca(figobj);
    ax.FontSize = pprm.tickfontsize;

    saveas(figobj, strcat(outputdir, 'IOIratiodist_', outputfileid, '_dctfreq.png'));

    %%
    addpath('./lib/PH/');
    j = 2;
    modes = cell(numel(typelist), 1);
    compositecoef = cell(numel(typelist), 1);

    for i=1:size(f_D(:, j), 1)
        X = f_D{i, j};
        modes_i = cell(size(X, 2), 1);
        compositecoef_i = zeros(size(X, 2), 1);

        for k=1:size(X, 2)
            idx = persistencemode_thresh(X(:, k), 0.9);
            modes_i{k} = x{j}(idx);

            Y = dct(X(:, k));
            YY = cumsum(Y.^2)./sum(Y.^2);
            compositecoef_i(k) = find(YY > 0.95, 1, 'first')./numel(YY).*(2*pi) * mean(ioirdur{i}{k});
        end

        modes{i} = modes_i;
        compositecoef{i} = compositecoef_i;
    end

    %% plot
    for j=1:2
        switch j
            case 1
                xlabelstr = 'IOI (second)';
                titlestr = 'IOI distribution';
                fileid = 'IOIdist';
            case 2
                xlabelstr = 'IOI ratio';
                titlestr = 'IOI ratio distribution';
                fileid = 'IOIratiodist';
        end
        
        yl = [0, max(f{j}(:))*1.1];
        
        for i=1:numel(typelist)
            figobj = figure(i);
            figobj.Position = [100, 400, 700, 550];
            plot(x{j}, f{j}(:, i), 'LineWidth', pprm.linewidth, 'Color', pprm.colorcode{i});
    
            if j == 2
                hold on
                stem(pprm.xtickval{j}, repmat(yl(end), [numel(pprm.xtickval{j}), 1]), 'Color', 'k', 'Marker', 'none', 'LineStyle', '--');
                hold off

                xticks(pprm.xtickval{j});
                xticklabels(pprm.xticklabelstr);
            end
            
            xlabel(xlabelstr, 'FontSize', pprm.labelfontsize);
            ylabel('Probability density', 'FontSize', pprm.labelfontsize);
            title([titlestr, ' (', typelist{i}, ')'], 'FontSize', pprm.titlefontsize);
            axis tight;
            ylim(yl);
            
            ax = gca(figobj);
            ax.FontSize = pprm.tickfontsize;
    
            saveas(figobj, strcat(outputdir, fileid, '_', typelist{i}, '_', outputfileid, '.png'));

            %
            figobj = figure;
            figobj.Position = [100, 400, 700, 550];

            p = waterfall(x{j}, 1:size(f_D{i, j}, 2), f_D{i, j}');
            set(p, 'EdgeAlpha', 0.5);
            set(p, 'FaceAlpha', 0.3);
            set(p, 'FaceColor', 'flat');
            set(p, 'EdgeColor', 'flat');
            set(gca, 'ZTickLabel', []);
            
            if j == 1
                xlim([-Inf, 1.5]);
            end

            title([titlestr, ' (', typelist{i}, ')'], 'FontSize', pprm.titlefontsize);
            xlabel(xlabelstr, 'FontSize', pprm.labelfontsize);
            ylabel('Audio file', 'FontSize', pprm.labelfontsize);
            if j == 2
                xticks(pprm.xtickval{j});
                xticklabels(pprm.xticklabelstr);
            end
            ax = gca(figobj);
            ax.FontSize = pprm.tickfontsize;

            view(-0.25, 80);

            saveas(figobj, strcat(outputdir, fileid, '_', typelist{i}, '_', outputfileid, '_wf.png'));
        end
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

    for i=1:numel(pprm.xtickval{2})
        plot(xl, pprm.xtickval{2}(i).*[1, 1], ':k');
    end
    hold off;
    
    ylim([0, 1]);
    set(gca, 'YTick', pprm.xtickval{2});
    set(gca, 'YTickLabel', pprm.xticklabelstr);

    title('Modes of IOI ratio', 'FontSize', pprm.titlefontsize);
    ylabel('Prominent modes on IOI ratio', 'FontSize', pprm.labelfontsize);
    ax = gca(figobj);
    ax.FontSize = pprm.tickfontsize;

    saveas(figobj, strcat(outputdir, 'IOIratiodist_', outputfileid, '_persistmodes.png'));
    
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

    title('Composite score', 'FontSize', pprm.titlefontsize);
    ylabel('95% DCT freq. x IOI ratio duration', 'FontSize', pprm.labelfontsize);
    ax = gca(figobj);
    ax.FontSize = pprm.tickfontsize;

    saveas(figobj, strcat(outputdir, 'IOIratiodist_', outputfileid, '_compcoef.png'));

    %% plot 2D
    for j=1:2
        switch j
            case 1
                xlabelstr = 'IOI (second)';
                titlestr = 'IOI distribution';
                fileid = 'IOIdist';
            case 2
                xlabelstr = 'IOI ratio';
                titlestr = 'IOI ratio distribution';
                fileid = 'IOIratiodist';
        end

        yl = [0, max(f{j}(:))*1.1];
    
        figobj = figure(5);
        figobj.Position = [100, 400, 700, 550];
    
        for i=1:numel(typelist)
            plot(x{j}, f{j}(:, i), 'LineWidth', pprm.linewidth, 'Color', pprm.colorcode{i});
            hold on
        end

        if j == 2
            hold on
            stem(pprm.xtickval{j}, repmat(yl(end), [numel(pprm.xtickval{j}), 1]), 'Color', 'k', 'Marker', 'none', 'LineStyle', '--');
            hold off

            xticks(pprm.xtickval{j});
            xticklabels({'1/4', '1/3', '1/2', '2/3', '3/4'});
        end

        legend(typelist, 'FontSize', pprm.legendfontsize, 'Location', 'northeast');
        hold off
    
        xlabel(xlabelstr, 'FontSize', pprm.labelfontsize);
        ylabel('Probability density', 'FontSize', pprm.labelfontsize);
        title(titlestr, 'FontSize', pprm.titlefontsize);
        axis tight;
        ylim(yl);
    
        ax = gca(figobj);
        ax.FontSize = pprm.tickfontsize;
    
        saveas(figobj, strcat(outputdir, fileid, '_', outputfileid, '_all', '.png'));
    end
end