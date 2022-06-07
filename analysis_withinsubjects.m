function analysis_withinsubjects
    %% Data information
    datainfo = readtable('datainfo.csv');
    dataname = datainfo.dataname;
    
    %% Get features
    f0dir = '../f0-annotation-tool/output/';
    ioidir = '../onset-annotation-tool/output/';
    D_intvl = helper.h_ETL_intvl(dataname, f0dir, ioidir);
    D_f0 = helper.h_ETL_f0(dataname, f0dir);
    D = helper.h_ETL_ioi(dataname, ioidir);
    D_ioi = D{1};
    D_ioiratio = D{2};
    clear D;

    %% Analysis
    addpath('./lib/two-sample/');
    addpath('./lib/KDE/');
    addpath('./lib/PH/');
    subjects = unique(datainfo.performer);
    
    support_ioiratio = linspace(0, 1, 512);
    support_intvl = linspace(-2000, 2000, 512);
    support_scaleintvl = linspace(0, 2600, 1024);

    for i=1:numel(subjects)
        %%
        idx = find(contains(datainfo.performer, subjects{i}));
        
        %%
        type = datainfo.type(idx);

        for j=3:5
            switch j
                case 1
                    feature = D_f0(idx);
                    featurename = 'F0';
                    metricname = 'Relative effect';
                    analysisfun = @(x, y) pb_effectsize(x, y);
                case 2
                    feature = D_ioi(idx);
                    featurename = 'IOI';
                    metricname = 'Relative effect';
                    analysisfun = @(x, y) pb_effectsize(x, y);
                case 3
                    support = support_ioiratio;
                    feature = D_ioiratio(idx);
                    featurename = 'IOI ratio';
                    metricname = 'Energy distance';
                    analysisfun = @(x, y) energydist(x, y);
                case 4
                    support = support_intvl;
                    feature = wrapper_interval(D_intvl(idx), 4096);
                    featurename = 'Interval';
                    metricname = 'Energy distance';
                    analysisfun = @(x, y) energydist(x, y);
                case 5
                    support = support_scaleintvl;
                    feature = wrapper_scaleintvl(D_f0(idx), 1024);
                    featurename = 'F0 interval';
                    metricname = 'Energy distance';
                    analysisfun = @(x, y) energydist(x, y);
            end
            
            %%
            idxpair = nchoosek(1:numel(idx), 2);

            for k=1:size(idxpair, 1)
                s = analysisfun(feature{idxpair(k, 1)}, feature{idxpair(k, 2)});

                fprintf('%s (%s) %s vs. %s: %3.3f (%s)\n', subjects{i}, featurename,...
                    type{idxpair(k, 1)}, type{idxpair(k, 2)}, s, metricname);

                %{
                if ~isnan(D)
                    figure(1);
                    subplot(2, 1, 1);
                    plot(support, A);
                    hold on;
                    plot(support, B);
                    hold off;
                    axis tight;
                    yl = ylim();
                    subplot(2, 1, 2);
                    plot(support, D);
                    axis tight;
                    ylim(yl(2).*[-1, 1]);
                    drawnow;
                end
                %}
            end
        end
    end
end

function D = wrapper_interval(Intvl, M)
    D = helper.h_subsampling(Intvl, M);
    %D = cellfun(@(x) x + normrnd(0, 0.8, [M, 1]), D, 'UniformOutput', false);
end

function D = wrapper_scaleintvl(F0, M)
    N = numel(F0);
    D = cell(N, 1);
    
    %%
    F0_subset = helper.h_subsampling(F0, M);
    
    %%
    for i=1:N
        f0intvl = abs(F0_subset{i} - F0_subset{i}');
        O = tril(ones(size(f0intvl)), -1);
        
        O = O(:);
        idx = O ~= 0;

        f0intvl = f0intvl(:);
        D{i} = f0intvl(idx);
    end
end