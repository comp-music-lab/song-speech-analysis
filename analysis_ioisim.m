function analysis_ioisim
    %%
    outputdir = './output/20220705/';
    datainfofile = {...
        'datainfo_Marsden-complete_song-desc.csv',...
        'datainfo_Marsden-complete_song-recit.csv',...
        'datainfo_Marsden-complete_inst-desc.csv',...
        };
    L = [10, 15, 20, 25, 30, 40, 50, 60, Inf];
    
    addpath('./lib/KDE/');

    %%
    onsetfilepath = [];
    breakfilepath = [];
    dataname = [];
    for i=1:numel(datainfofile)
        T = readtable(datainfofile{i});
        onsetfilepath = [onsetfilepath; strcat(T.path, 'onset_', T.dataname, '.csv')];
        breakfilepath = [breakfilepath; strcat(T.path, 'break_', T.dataname, '.csv')];
        dataname = [dataname; T.dataname];
    end

    onsetfilepath = unique(onsetfilepath);
    breakfilepath = unique(breakfilepath);
    dataname = unique(dataname);
    
    %%
    h_recurrence(onsetfilepath, breakfilepath, dataname);

    %%
    %h_comparison(onsetfilepath, breakfilepath, dataname);

    %%
    %h_sim(onsetfilepath, breakfilepath, L, dataname, outputdir);
end

function h_recurrence(onsetfilepath, breakfilepath, dataname)
    %%
    s = cellfun(@(X) strsplit(X, '_'), dataname, 'UniformOutput', false);
    dataid = cellfun(@(X) strcat(X{1}), s, 'UniformOutput', false);
    dataidlist = unique(dataid);
    
    datatype = cellfun(@(X) strcat(X{end}), s, 'UniformOutput', false);
    typelist = unique(datatype);

    %%
    H = zeros(numel(dataidlist), 1);

    for i=1:numel(dataidlist)
        idx = find(strcmp(dataidlist{i}, dataid));
        N = numel(idx);
        
        for n=1:N
            [t_onset, t_break] = h_onsetbreak(onsetfilepath{idx(n)}, breakfilepath{idx(n)});
            [ioi, ~] = helper.h_ioi(unique(t_onset), unique(t_break));
            
            H_max = -Inf;
            H_m = 0;
            M = 1;
            while H_max < H_m
                H_max = H_m;
                M = M + 1;
                H_m = recmaxent(ioi, M, 40000);
            end
            
            H(idx(n)) = H_max;
            fprintf('M = %d, %s %s\n', M - 1, datetime, dataname{idx(n)});
        end
    end

    %%
    figobj = figure;
    colorcode = {'#0072BD', '#D95319', '#EDB120', '#7E2F8E'};

    for i=1:numel(typelist)
        idx_i = strcmp(datatype, typelist{i});

        for j=1:numel(dataidlist)
            idx_j = strcmp(dataid, dataidlist{j});
            idx = idx_i & idx_j;

            scatter(i, H(idx), 'MarkerEdgeColor', 'none', 'MarkerFaceColor', colorcode{j});
            hold on
        end
    end
    legend(dataidlist, 'FontSize', 10);
    hold off
    xticks(1:numel(typelist));
    xticklabels(typelist);
    xlim([0.5, numel(typelist) + 0.5]);
    ylabel('Recurrence Entropy (nat)', 'FontSize', 12);
    ax = gca(figobj);
    ax.FontSize = 10;
end

function H_max = recmaxent(X, N, M)
    %%
    L = numel(X) - N + 1;
    I = arrayfun(@(x) [1:(x - 1); repmat(x, [1, x - 1])], 2:L, 'UniformOutput', false);
    I = cat(2, I{:})';
    idx = randperm(size(I, 1))';
    R = zeros(N^2, min(size(idx, 1), M));

    %%
    parfor m=1:size(R, 2)
        idx_st = I(idx(m), 1);
        idx_ed = idx_st + N - 1;
        X_m = X(idx_st:idx_ed);

        idx_st = I(idx(m), 2);
        idx_ed = idx_st + N - 1;
        Y_m = X(idx_st:idx_ed);

        R_m = X_m - Y_m';

        R(:, m) = R_m(:);
    end

    %%
    R = abs(R);
    H = zeros(512, 2);
    eps_max = max(R(:));

    parfor i=1:size(H, 1)
        eps = rand*eps_max;
        H(i, :) = [h_REnt(R, eps), eps];
    end

    H_max = max(H(:, 1));
end

function H = h_REnt(R, eps)
    %%
    B = R';
    B(R <= eps) = 1;
    B(R > eps) = 0;

    %%
    [~, ~, ic] = unique(B, 'rows');

    %%
    C = histcounts(ic, unique(ic));
    N = numel(ic);
    P = C./N;
    H = -sum(P.*log(P));
end

function h_comparison(onsetfilepath, breakfilepath, dataname)
    %%
    s = cellfun(@(X) strsplit(X, '_'), dataname, 'UniformOutput', false);
    dataid = cellfun(@(X) strcat(X{1}, X{2}, X{end - 2}), s, 'UniformOutput', false);
    dataidlist = unique(dataid);

    %%
    for i=1:numel(dataidlist)
        idx = find(strcmp(dataidlist{i}, dataid));
        N = numel(idx);
        density = cell(N, 1);
        support = cell(N, 1);
        datatype = cell(N, 1);
        birth = cell(N, 1);
        death = cell(N, 1);
        pos = cell(N, 1);
        dist = cell(N, 1);
        ioipair = cell(N, 1);
        ioi = cell(N, 1);
        
        for n=1:N
            [t_onset, t_break] = h_onsetbreak(onsetfilepath{idx(n)}, breakfilepath{idx(n)});
            [ioi{n}, ioiratio, ~, ~, ioipair{n}] = helper.h_ioi(unique(t_onset), unique(t_break));
            [density{n}, support{n}] = h_kde(ioiratio, 0, 1);

            s = strsplit(dataname{idx(n)}, '_');
            datatype{n} = s{end};

            [birth{n}, locs, ~, p] = findpeaks(density{n}, 'MinPeakHeight', 1e-10);
	        death{n} = birth{n} - p;
            pos{n} = support{n}(locs);
            dist{n} = 0.5.*(birth{n} - death{n});
        end
        
        %%
        [~, idx] = sort(datatype);
        
        %%{
        figobj = figure();
        figobj.Position = [100, 800, 940, 180];
        for n=1:N
            subplot(1, N, n);
            scatter(ioipair{idx(n)}(:, 1), ioipair{idx(n)}(:, 2), 'Marker', '.');
            title(datatype{idx(n)}, 'FontSize', 12);
        end

        figobj = figure;
        figobj.Position = [55, 653, 1000, 250];
        for n=1:N
            subplot(1, N, n);
            plot(support{idx(n)}, density{idx(n)});
            title(datatype{idx(n)}, 'FontSize', 12);
        end
        %}
        %{
        figure(4);
        clf; cla;
        for n=1:N
            scatter(death{n}, birth{n});
            hold on
        end
        m = max(max(xlim()), max(ylim()));
        xlim([0, m]);
        ylim([0, m]);
        plot([0, m], [0, m], '-.k');
        hold off;
        legend(datatype, 'location', 'southeast');

        figure(5);
        clf; cla;
        for n=1:N
            stem(pos{n}, dist{n});
            hold on
        end
        hold off;
        legend(datatype, 'location', 'northeast');
        %}
    end
end

function h_sim(onsetfilepath, breakfilepath, L, dataname, outputdir)
    %%
    N = numel(onsetfilepath);
    
    %%
    for n=1:N
        [t_onset, t_break] = h_onsetbreak(onsetfilepath{n}, breakfilepath{n});
        T_max = max(max(t_onset), max(t_break));
        I = find(T_max < L, 1, 'first');

        figobj1 = figure(1);
        clf; cla;
        figobj1.Position = [100, 340, 650, 630];

        figobj2 = figure(2);
        clf; cla;
        figobj2.Position = [750, 340, 650, 630];

        for i=1:I
            idx_onset = t_onset < L(i);
            idx_break = t_break < L(i);
            
            [ioi, ioiratio] = helper.h_ioi(t_onset(idx_onset), t_break(idx_break));
            
            ioiratio_rnd = h_randomioiratio(ioi);

            [density, support] = h_kde(ioiratio, 0, 1);
            [density_rnd, ~] = h_kde(ioiratio_rnd, 0, 1);
            
            figure(1);
            subplot(3, 3, i);
            h_plot1(ioiratio, support, density, density_rnd, L(i), dataname{n});

            figure(2);
            subplot(3, 3, i);
            h_plot2(ioiratio, L(i), dataname{n});
        end
        drawnow
       
        saveas(figobj1, strcat(outputdir, dataname{n}, '_ioiratio1.png'));
        saveas(figobj2, strcat(outputdir, dataname{n}, '_ioiratio2.png'));
    end
end

function [t_onset, t_break] = h_onsetbreak(onsetfilepath, breakfilepath)
    %%
    T = readtable(onsetfilepath);
    t_onset = table2array(T(:, 1));
    
    %%
    T = readtable(breakfilepath, 'ReadVariableNames', false);
    
    if isempty(T)
        t_break = [];
    else
        t_break = table2array(T(:, 1));

        if iscell(t_break)
            t_break = str2double(cell2mat(t_break));
        end
    end
end

function ioiratio_rnd = h_randomioiratio(ioi)
    %%
    M = 10000;
    ioi_min = min(ioi);
    ioi_max = max(ioi);
    ioi_rnd = rand(M, 1).*(ioi_max - ioi_min) + ioi_min;
    
    %%
    ioiratio_rnd = [0; ioi_rnd(2:end); 0]./conv(ioi_rnd, [1; 1]);
    ioiratio_rnd = ioiratio_rnd(2:end - 1);
end

function [density, support, C] = h_kde(X, a, b)
    %%
    support_x = linspace(a + 1e-12, b - 1e-12, 1024);

    %%
    h = kdebandwidth_lp(X);
    density = arrayfun(@(X_i) normpdf(support_x, X_i, h), X, 'UniformOutput', false);
    density = mean(cat(1, density{:}), 1);
    support = support_x;
    
    %%
    C = trapz(support, density);
    fprintf('Check: N = %d, h = %3.5f, C = %e\n', numel(X), h, C);
end

function h_plot1(X, support, density, density_rnd, L, dataname)
    %%
    intratio = [1/4, 1/3, 1/2, 2/3, 3/4];

    %%
    s = strsplit(dataname, '_');
    titlestr = {['IOI ratio distribution (t < ', num2str(L, '%d'), ')'], ['N = ', num2str(numel(X), '%d'), ', ', s{1}, '-', s{end}]};

    %%
    figure(1);
    plot(support, density);
    yl = ylim();
    hold on;
    plot(support, density_rnd, '-.m');
    scatter(X, zeros(numel(X), 1), 'Marker', '|')
    for i=1:numel(intratio)
        plot(intratio(i).*[1, 1], yl, ':k');
    end
    hold off;
    title(titlestr, 'Interpreter', 'none', 'FontSize', 11);

    xlim([0, 1]);
end

function h_plot2(X, L, dataname)
    %%
    intratio = [1/4, 1/3, 1/2, 2/3, 3/4];

    %%
    s = strsplit(dataname, '_');
    titlestr = {['sorted IOI ratio data (t < ', num2str(L, '%d'), ')'], [s{1}, '-', s{end}]};
    
    N = numel(X);

    %%
    scatter(1:N, sort(X), 'Marker', '.');
    title(titlestr, 'Interpreter', 'none', 'FontSize', 11);
    xlim([1, N]);
    ylim([0, 1]);
    xl = xlim();
    hold on;
    for i=1:numel(intratio)
        plot(xl, intratio(i).*[1, 1], ':k');
    end
    hold off;
end