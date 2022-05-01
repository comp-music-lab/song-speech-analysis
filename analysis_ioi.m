function analysis_ioi
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
    %datatype = {'desc', 'recit', 'song'};
    
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
    xtickval = {[0, 0.5, 1, 1.5, 2, 2.5], [1/4, 1/3, 1/2, 2/3, 3/4]};
    xangle = 50;
    
    outputdir = './output/fig/';

    %% Get f0 data
    ioidir = '../onset-annotation-tool/output/';
    D = h_ETL_ioi(dataname, ioidir);

    %% KDE
    addpath('./lib/KDE/');
    kernelfun = @(u) 1/sqrt(2*pi) .* exp(-0.5.*u.^2);
    C = {zeros(numel(datatype), 1), zeros(numel(datatype), 1)};
    f = cell(2, 1);
    x = cell(2, 1);
    
    for j=1:2
        %%
        switch j
            case 1
                maxbwid = 2;
                x{j} = linspace(0, max(cellfun(@max, D{j})) + 1, 512)';
            case 2
                maxbwid = 0.4;
                x{j} = linspace(0, 1, 512)';
        end
        
        %%
        f{j} = zeros(numel(x{j}), numel(datatype));

        for i=1:numel(datatype)
            idx = contains(dataname, datatype{i});
            X = D{j}(idx, 1);
            X = cat(1, X{:});
    
            h_x = kdebandwidth_disc(x{j}, X, maxbwid);
            density = kde(x{j}, X, kernelfun, h_x);

            f{j}(:, i) = density;
            C{j}(i) = trapz(x{j}, f{j}(:, i));

            fprintf('%s: h_x = %3.3f\n', datatype{i}, h_x);
        end

        f{j} = bsxfun(@rdivide, f{j}, C{j}');
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
        
        for i=1:numel(datatype)
            figobj = figure(i);
            figobj.Position = [100, 400, 700, 550];
            plot(x{j}, f{j}(:, i), 'LineWidth', linewidth, 'Color', colorcode{i});
    
            if j == 2
                hold on
                stem(xtickval{j}, repmat(yl(end), [numel(xtickval{j}), 1]), 'Color', 'k', 'Marker', 'none', 'LineStyle', '--');
                hold off

                xticks(xtickval{j});
                xticklabels({'1/4', '1/3', '1/2', '2/3', '3/4'});
            end
            
            xlabel(xlabelstr, 'FontSize', labelfontsize);
            ylabel('Probability density', 'FontSize', labelfontsize);
            title([titlestr, ' (', datatype{i}, ')'], 'FontSize', titlefontsize);
            axis tight;
            ylim(yl);
            
            ax = gca(figobj);
            ax.FontSize = tickfontsize;
    
            saveas(figobj, strcat(outputdir, fileid, '_', datatype{i}, '.png'));
        end
    end

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
    
        for i=1:numel(datatype)
            plot(x{j}, f{j}(:, i), 'LineWidth', linewidth, 'Color', colorcode{i});
            hold on
        end

        if j == 2
            hold on
            stem(xtickval{j}, repmat(yl(end), [numel(xtickval{j}), 1]), 'Color', 'k', 'Marker', 'none', 'LineStyle', '--');
            hold off

            xticks(xtickval{j});
            xticklabels({'1/4', '1/3', '1/2', '2/3', '3/4'});
        end

        legend(datatype, 'FontSize', legendfontsize);
        hold off
    
        xlabel(xlabelstr, 'FontSize', labelfontsize);
        ylabel('Probability density', 'FontSize', labelfontsize);
        title(titlestr, 'FontSize', titlefontsize);
        axis tight;
        ylim(yl);
    
        ax = gca(figobj);
        ax.FontSize = tickfontsize;
    
        saveas(figobj, strcat(outputdir, fileid, '_all2D', '.png'));
    end
    
    %% plot 3D
    for j=1:2
        switch j
            case 1
                xlabelstr = 'IOI (second)';
                titlestr = 'IOI distribution';
                fileid = 'IOIdist';
                dtheta = -5;
                dphi = -60;
            case 2
                xlabelstr = 'IOI ratio';
                titlestr = 'IOI ratio distribution';
                fileid = 'IOIratiodist';
                dtheta = 5;
                dphi = -45;
        end

        yl = [0, max(f{j}(:))*1.1];

        figobj = figure(5);
        clf; cla;
        figobj.Position = [100, 100, 700, 550];
    
        for i=1:numel(datatype)
            plot3(x{j}, f{j}(:, i), i.*ones(numel(x{j}), 1), 'LineWidth', linewidth, 'Color', colorcode{i});
            hold on
        end
        
        for i=1:numel(datatype)
            plot3([x{j}(1), x{j}(end)], [0, 0], [i, i], 'LineStyle', '-', 'Color', [0.5, 0.5, 0.5]);
        end
        
        xticks(xtickval{j});

        if j == 2
            for i=1:numel(datatype)
                for k=1:numel(xtickval{j})
                    [~, idx] = min(abs(xtickval{j}(k) - x{j}));
                    scatter3(xtickval{j}(k), f{j}(idx, i), i, 'Marker', 'x', 'MarkerEdgeColor', 'm',...
                        'LineWidth', 2, 'CData', 8);
                end
            end

            xticklabels({'1/4', '1/3', '1/2', '2/3', '3/4'});
        end
        
        stem3(xtickval{j}, zeros(numel(xtickval{j}), 1), repmat(numel(datatype), [numel(xtickval{j}), 1]),...
            'Color', [0.5, 0.5, 0.5], 'Marker', 'none', 'LineStyle', '--');
        
        view(0, 85); camorbit(dtheta, dphi, 'camera');
        set(gca, 'Ztick', []);
        
        ylabel('Probability density', 'FontSize', labelfontsize);
        
        title(titlestr, 'FontSize', titlefontsize);
        axis tight;
        ylim(yl);
    
        xtickangle(xangle);
        ax = gca(figobj);
        ax.FontSize = tickfontsize;
        xlabel(xlabelstr, 'FontSize', labelfontsize);
        
        legend(datatype, 'FontSize', legendfontsize,...
            'Position', [0.699771804518855,0.718636368404736,0.132857141069003,0.169999995231629]);
        hold off
    
        saveas(figobj, strcat(outputdir, fileid, '_all3D', '.png'));
    end
end

function D = h_ETL_ioi(dataname, ioidir)
    %%
    D = {cell(numel(dataname), 1), cell(numel(dataname), 1)};

    %%
    for i=1:numel(dataname)
        %%
        onsetinfo = readtable(strcat(ioidir, 'SV_seg_', dataname{i}, '.csv'), 'ReadVariableNames', false);
        breakinfo = readtable(strcat(ioidir, 'SV_break_', dataname{i}, '.csv'), 'ReadVariableNames', false);
        
        %%
        t_onset = onsetinfo.Var1;
        if iscell(breakinfo.Var1)
            t_break = str2double(breakinfo.Var1{:});
        else
            t_break = breakinfo.Var1;
        end
        [ioi, ioiratio] = helper.h_ioi(t_onset, t_break);

        D{1}{i} = ioi(:);
        D{2}{i} = ioiratio(:);
    end
end