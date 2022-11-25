function analysis_checkHiltonF0
    %%
    f0dir_pyin = '../data/Automated F0/';
    f0dir_sa = '../data/Pilot data/';
    
    dataname = {...
        'ACO02C', 'ACO02D', 'ACO05C', 'ACO05D', 'ACO09C', 'ACO09D',...
        'BEJ01C', 'BEJ01D', 'BEJ16C', 'BEJ16D', 'BEJ21C', 'BEJ21D',...
        'WEL01C', 'WEL01D', 'WEL21C', 'WEL21D', 'WEL51C', 'WEL51D'...
        };

    %%
    for i=1:numel(dataname)
        f0filepath_pyin = strcat(f0dir_pyin, dataname{i}, '_f0.csv');
        f0filepath_sa = strcat(f0dir_sa, dataname{i}, '_f0.csv');
    
        T = readtable(f0filepath_pyin);
        t0_pyin = table2array(T(:, 1));
        f0_pyin = table2array(T(:, 2));
        f0_pyin(f0_pyin == 0) = nan;
    
        T = readtable(f0filepath_sa);
        t0_sa = table2array(T(:, 1));
        f0_sa = table2array(T(:, 2));
        f0_sa(f0_sa == 0) = nan;
    
        fobj = figure(1);
        fobj.Position = [680, 590, 700, 385];
        scatter(t0_pyin, f0_pyin, 'Marker', '.');
        hold on
        scatter(t0_sa, f0_sa, 'Marker', '.');
        hold off
        title(dataname{i}, 'FontSize', 14)
        ax = gca(fobj);
        ax.FontSize = 14;
        legend({'pYIN', 'Semi-automated'}, 'FontSize', 12, 'Position', [0.737, 0.897, 0.256, 0.096])
        drawnow

        saveas(fobj, strcat('../output/Hilton-sa/', dataname{i}, '_f0.png'));
    end
end