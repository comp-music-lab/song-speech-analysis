function analysis_interval
    %%
    dataname = {...
        'John_McBride_English_Irish_Traditional_ArthurMcBride_recit',...
        'John_McBride_English_Irish_Traditional_ArthurMcBride_song',...
        'John_McBride_English_Irish_Traditional_ArthurMcBride_desc',...
        'John_McBride_English_Irish_Traditional_ArthurMcBride_inst',...
        'Patrick_Savage_English_NewZealand+USA_Traditional_Scarborough Fair_20220208_recit',...
        'Patrick_Savage_English_NewZealand+USA_Traditional_Scarborough Fair_20220208_song',...
        'Patrick_Savage_English_NewZealand+USA_Traditional_Scarborough Fair_20220208_desc',...
        'Patrick_Savage_English_NewZealand+USA_Traditional_Scarborough Fair_20220220_inst',...
        'Emmanouil_Benetos_Greek_Greek_Traditional_SarantaPalikaria_20220214_recit',...
        'Emmanouil_Benetos_Greek_Greek_Traditional_SarantaPalikaria_20220214_song',...
        'Emmanouil_Benetos_Greek_Greek_Traditional_SarantaPalikaria_20220214_desc',...
        'Peter_Pfordresher_English_US_Traditional_ComingRoundMountain_recit',...
        'Peter_Pfordresher_English_US_Traditional_ComingRoundMountain_song',...
        'Peter_Pfordresher_English_US_Traditional_ComingRoundMountain_desc',...
        'Peter_Pfordresher_English_US_Traditional_ComingRoundMountain_inst',...
        };
    datatype = {'desc', 'recit', 'song', 'inst'};
    
    titlefontsize = 24;
    labelfontsize = 20;
    legendfontsize = 16;
    tickfontsize = 18;
    linewidth = 2;
    colorcode = {...
        [0 0.4470 0.7410], ...
        [0.8500 0.3250 0.0980], ...
        [0.9290 0.6940 0.1250], ...
        [0.4940 0.1840 0.5560]
        };
    xtickval = [-1200, -700, -200, 0, 200, 700, 1200];
    xangle = 50;
    
    outputdir = './output/fig/';

    %% Get f0 data
    f0dir = '../f0-annotation-tool/output/';
    ioidir = '../onset-annotation-tool/output/';
    D = h_ETL_intvl(dataname, f0dir, ioidir);

    %% KDE
    kernelfun = @(u) 1/sqrt(2*pi) .* exp(-0.5.*u.^2);
    maxbwid = 100;
    x = linspace(min(cellfun(@min, D)) - 100, max(cellfun(@max, D)) + 100, 512)';
    f = zeros(numel(x), numel(datatype));
    C = zeros(numel(datatype), 1);

    for i=1:numel(datatype)
        idx = contains(dataname, datatype{i});
        X = D(idx, 1);
        X = cat(1, X{:});

        h_x = kdebandwidth_disc(x, X, maxbwid);
        density = kde(x, X, kernelfun, h_x);
        
        f(:, i) = density;
        C(i) = trapz(x, f(:, i));

        fprintf('%s: h_x = %3.3f\n', datatype{i}, h_x);
    end

    f = bsxfun(@rdivide, f, C');

    %% plot
    yl = [0, max(f(:))*1.1];
    
    for i=1:numel(datatype)
        figobj = figure(i);
        figobj.Position = [100, 400, 700, 550];
        plot(x, f(:, i), 'LineWidth', linewidth, 'Color', colorcode{i});

        hold on
        stem(xtickval, repmat(yl(end), [numel(xtickval), 1]), 'Color', 'k', 'Marker', 'none', 'LineStyle', '--');
        hold off
        
        xlabel('Interval (cent)', 'FontSize', labelfontsize);
        ylabel('Probability density', 'FontSize', labelfontsize);
        title(['Interval distribution (', datatype{i}, ')'], 'FontSize', titlefontsize);
        axis tight;
        ylim(yl);
        
        xticks(xtickval);
        xtickangle(xangle);
        ax = gca(figobj);
        ax.FontSize = tickfontsize;

        saveas(figobj, strcat(outputdir, 'Intervaldist_', datatype{i}, '.png'));
    end

    %% plot 2D
    figobj = figure(5);
    figobj.Position = [100, 400, 700, 550];

    for i=1:numel(datatype)
        plot(x, f(:, i), 'LineWidth', linewidth, 'Color', colorcode{i});
        hold on
    end
    
    stem(xtickval, repmat(yl(end), [numel(xtickval), 1]), 'Color', 'k', 'Marker', 'none', 'LineStyle', '--');
        
    legend(datatype, 'FontSize', legendfontsize);
    hold off

    xlabel('Interval (cent)', 'FontSize', labelfontsize);
    ylabel('Probability density', 'FontSize', labelfontsize);
    title(['Interval distribution'], 'FontSize', titlefontsize);
    xlim([-1200, 1200]);
    ylim(yl);

    ax = gca(figobj);
    ax.FontSize = tickfontsize;

    saveas(figobj, strcat(outputdir, 'Intervaldist_all2D', '.png'));

    %% plot 3D
    figobj = figure(5);
    clf; cla;
    figobj.Position = [100, 100, 700, 550];

    for i=1:numel(datatype)
        plot3(x, f(:, i), i.*ones(numel(x), 1), 'LineWidth', linewidth, 'Color', colorcode{i});
        hold on
    end
    
    for i=1:numel(datatype)
        for j=1:numel(xtickval)
            [~, idx] = min(abs(xtickval(j) - x));
            scatter3(xtickval(j), f(idx, i), i, 'Marker', 'x', 'MarkerEdgeColor', 'm',...
                'LineWidth', 2, 'CData', 8);
        end
    end

    xticks(xtickval);
    stem3(xtickval, zeros(numel(xtickval), 1), repmat(numel(datatype), [numel(xtickval), 1]),...
        'Color', [0.5, 0.5, 0.5], 'Marker', 'none', 'LineStyle', '--');
    
    view(0, 85);
    camorbit(5, -35, 'camera');
    set(gca, 'Ztick', []);
    
    ylabel('Probability density', 'FontSize', labelfontsize);
    
    title(['Interval distribution'], 'FontSize', titlefontsize);
    axis tight;
    ylim(yl);

    xtickangle(xangle);
    ax = gca(figobj);
    ax.FontSize = tickfontsize;
    xlabel('Interval (cent)', 'FontSize', labelfontsize);
    
    legend(datatype, 'FontSize', legendfontsize,...
        'Position', [0.635486090233141,0.695000004768372,0.132857141069003,0.169999995231629]);
    hold off

    saveas(figobj, strcat(outputdir, 'Intervaldist_all3D', '.png'));
end

function D = h_ETL_intvl(dataname, f0dir, ioidir)
    %%
    D = cell(numel(dataname), 1);
    reffreq = 440;

    %%
    for i=1:numel(dataname)
        %%
        f0info = readtable(strcat(f0dir, dataname{i}, '_f0.csv'));
        onsetinfo = readtable(strcat(ioidir, 'SV_seg_', dataname{i}, '.csv'), 'ReadVariableNames', false);
        breakinfo = readtable(strcat(ioidir, 'SV_break_', dataname{i}, '.csv'), 'ReadVariableNames', false);
        
        %%
        f0 = f0info.voice_1;
        f0_cent = 1200.*log2(f0./reffreq);
        t_f0 = f0info.time;

        t_onset = onsetinfo.Var1;
        if iscell(breakinfo.Var1)
            t_break = str2double(breakinfo.Var1{:});
        else
            t_break = breakinfo.Var1;
        end
        [~, ~, t_st, t_ed] = helper.h_ioi(t_onset, t_break);
        
        I = helper.h_interval(f0_cent, t_f0, t_st, t_ed);
        D{i} = cat(1, I{:});
    end
end