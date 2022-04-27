function analysis_f0
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
    
    outputdir = './output/fig/';

    %% Get f0 data
    f0dir = '../f0-annotation-tool/output/';
    D = h_ETL_f0(dataname, f0dir);

    %% KDE
    addpath('./lib/KDE/');
    kernelfun = @(u) 1/sqrt(2*pi) .* exp(-0.5.*u.^2);
    maxwid = 20;
    x = linspace(min(cellfun(@min, D)) - 100, max(cellfun(@max, D)) + 100, 512)';
    f = zeros(numel(x), numel(datatype));
    C = zeros(numel(datatype), 1);

    for i=1:numel(datatype)
        idx = contains(dataname, datatype{i});
        X = D(idx, 1);
        X = cat(1, X{:});

        h_x = kdebandwidth(x, X, kernelfun, maxwid);
        fprintf('%s: h_x = %3.3f\n', datatype{i}, h_x);
        f(:, i) = kde(x, X, kernelfun, h_x);
        C(i) = trapz(x, f(:, i));
    end

    f = bsxfun(@rdivide, f, C');

    %% plot
    yl = [0, max(f(:))*1.1];

    for i=1:numel(datatype)
        figobj = figure(i);
        figobj.Position = [100, 400, 700, 550];
        plot(x, f(:, i), 'LineWidth', linewidth, 'Color', colorcode{i});
        
        xlabel('Frequency (cent)', 'FontSize', labelfontsize);
        ylabel('Probability density', 'FontSize', labelfontsize);
        title(['F0 distribution (', datatype{i}, ')'], 'FontSize', titlefontsize);
        axis tight;
        ylim(yl);

        ax = gca(figobj);
        ax.FontSize = tickfontsize;

        saveas(figobj, strcat(outputdir, 'F0dist_', datatype{i}, '.png'));
    end

    %%
    figobj = figure(5);
    figobj.Position = [100, 400, 700, 550];

    for i=1:numel(datatype)
        plot(x, f(:, i), 'LineWidth', linewidth, 'Color', colorcode{i});
        hold on
    end
    legend(datatype, 'FontSize', legendfontsize);
    hold off

    xlabel('Frequency (cent)', 'FontSize', labelfontsize);
    ylabel('Probability density', 'FontSize', labelfontsize);
    title(['F0 distribution'], 'FontSize', titlefontsize);
    axis tight;
    ylim(yl);

    ax = gca(figobj);
    ax.FontSize = tickfontsize;

    saveas(figobj, strcat(outputdir, 'F0dist_all', '.png'));
end

function D = h_ETL_f0(dataname, f0dir)
    %%
    D = cell(numel(dataname), 1);
    reffreq = 440;

    %%
    for i=1:numel(dataname)
        f0info = readtable(strcat(f0dir, dataname{i}, '_f0.csv'));
        f0_i = f0info.voice_1(f0info.voice_1 ~= 0);
        D{i} = 1200.*log2(f0_i./reffreq);
    end
end