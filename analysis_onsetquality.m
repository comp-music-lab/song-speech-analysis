function analysis_onsetquality
    %%
    T = pairing_20220526();
    
    figflag = true;
    outputdir = './output/20220526/';
    
    %%
    typelist = {'desc', 'recit', 'song', 'inst'};
    h_split = @(X) X{end};
    datatype = unique(cellfun(@(d) h_split(strsplit(d, '_')), T.dataname, 'UniformOutput', false));
    assert(isempty(setxor(datatype, typelist)));
    
    %%
    posterior_H0 = [];
    log10bf = [];
    Rvals = [];
    dataorder = [];
    originaldirlist = unique(T.originaldir);
    annotatordirlist = unique(T.annotatordir);

    for i=1:numel(originaldirlist)
        for j=1:numel(annotatordirlist)
            idx = strcmp(originaldirlist{i}, T.originaldir) & strcmp(annotatordirlist{j}, T.annotatordir);
            
            if sum(idx) > 0
                dataname = T.dataname(idx);

                A = unique(T.original(idx));
                B = unique(T.annotator(idx));
                C = unique(T.annotround(idx));
                dataid = [A{:}, '-', B{:}, ' (', C{:}, ')'];
                
                originalonsetdir = originaldirlist{i};
                annotatoronsetdir = annotatordirlist{j};

                [posterior_H0_j, log10bf_j, Rvals_j] = h_analysis(dataid, originalonsetdir, annotatoronsetdir, dataname, outputdir, figflag);

                posterior_H0 = [posterior_H0; posterior_H0_j];
                log10bf = [log10bf; log10bf_j];
                Rvals = [Rvals; Rvals_j];

                dataorder = [dataorder; find(idx)];
            end
        end
    end

    %%
    plot_20220526(log10bf, posterior_H0, Rvals, T, dataorder, typelist, outputdir);
end

function [posterior_H0, log10bf, Rvals] = h_analysis(dataid, finalonsetdir, initialonsetdir, dataname, outputdir, figflag)
    %% ETL
    filedir = {initialonsetdir, finalonsetdir};
    t_onset = cell(numel(dataname), numel(filedir));
    t_break = cell(numel(dataname), numel(filedir));
    ioi = cell(numel(dataname), numel(filedir));
    ioiratio = cell(numel(dataname), numel(filedir));
    
    for j=1:numel(filedir)
        for i=1:numel(dataname)
            onsetfilepath = strcat(filedir{j}, 'onset_', dataname{i}, '.csv');
            T = readtable(onsetfilepath);
            t_onset{i, j} = unique(T.Var1);

            breakfilepath = strcat(filedir{j}, 'break_', dataname{i}, '.csv');
            T = readtable(breakfilepath, 'ReadVariableNames', false);
            if isempty(T)
                t_break{i, j} = [];
            else
                if iscell(T.Var1)
                    t_break{i, j} = str2num(T.Var1{:});
                else
                    t_break{i, j} = unique(T.Var1);
                end
            end
            
            [ioi{i, j}, ioiratio{i, j}] = helper.h_ioi(t_onset{i, j}, t_break{i, j});
            ioi{i, j} = ioi{i, j}(:);
            ioiratio{i, j} = ioiratio{i, j}(:);
        end
    end
    
    %% R-value
    Rvals = zeros(numel(dataname), 6);
    thresh = 0.02;

    for i=1:numel(dataname)
        hit = 0;

        for j=1:numel(t_onset{i, 2})
            boundary_l = t_onset{i, 2}(j) - thresh;
            if j > 1
                preboundary_r = t_onset{i, 2}(j - 1) + thresh;
                
                if boundary_l < preboundary_r
                    boundary_l = boundary_l - (preboundary_r - boundary_l)/2;
                end
            end

            boundary_r = t_onset{i, 2}(j) + thresh;
            if j < numel(t_onset{i, 2})
                postboundary_l = t_onset{i, 2}(j + 1) - thresh;
                
                if postboundary_l < boundary_r
                    boundary_r = boundary_r - (boundary_r - postboundary_l)/2;
                end
            end

            flag = boundary_l <= t_onset{i, 1} & t_onset{i, 1} < boundary_r;
            if sum(flag) > 0
                hit = hit + 1;
            end
        end
        
        HR = hit/numel(t_onset{i, 2}) * 100;
        OS = (numel(t_onset{i, 1})/numel(t_onset{i, 2}) - 1) * 100;
        r1 = sqrt((100 - HR)^2 + OS^2);
        r2 = (-OS + HR - 100)/sqrt(2);
        R = 1 - (abs(r1) + abs(r2))/200;
        PRC = hit/numel(t_onset{i, 1});
        RCL = hit/numel(t_onset{i, 2});
        F = (2*PRC*RCL)/(PRC + RCL);
        Rvals(i, :) = [R, HR, OS, PRC, RCL, F];
    end
    
    Rvals = array2table(Rvals, 'VariableNames', {'R', 'HR', 'OS', 'PRC', 'RCL', 'F'});

    %% Metrical difference
    if figflag
        dist = zeros(numel(dataname), 1);
        reldist = zeros(numel(dataname), 1);
        
        f = figure(1);
        f.Position = [5, 5, 1250, 950];
        clf; cla;
        for i=1:numel(dataname)
            [dist_i, ix, iy] = dtw(t_onset{i, 1}, t_onset{i, 2});
            dist(i) = dist_i/numel(ix);
            reldist(i) = dist(i)/mean(ioi{i, 2});
    
            subplot(numel(dataname), 1, i);
            scatter(t_onset{i, 1}, ones(numel(t_onset{i, 1}), 1), 'MarkerEdgeColor', '#0072BD');
            hold on
            scatter(t_onset{i, 2}, zeros(numel(t_onset{i, 2}), 1), 'MarkerEdgeColor', '#D95319');
            scatter(t_break{i, 1}, ones(numel(t_break{i, 1}), 1), 'MarkerEdgeColor', 'none', 'MarkerFaceColor', '#0072BD', 'Marker', 'v');
            scatter(t_break{i, 2}, zeros(numel(t_break{i, 2}), 1), 'MarkerEdgeColor', 'none', 'MarkerFaceColor', '#D95319', 'Marker', 'v');
    
            for j=1:numel(ix)
                plot([t_onset{i, 1}(ix(j)), t_onset{i, 2}(iy(j))], [1, 0], ':m');
            end
            hold off
            
            xlim([0, 10.4]);
            ylim([-0.5, 1.8]);
            
            if i == 1
                titlestr = {['[', dataid, ']'], '', dataname{i},...
                    ['Average diff = ', num2str(dist(i), '%3.3f'), ', Average diff/Average IOI = ', num2str(reldist(i), '%3.3f')]};
            else
                titlestr = {dataname{i},...
                    ['Average diff = ', num2str(dist(i), '%3.3f'), ', Average diff/Average IOI = ', num2str(reldist(i), '%3.3f')]};
            end
    
            title(titlestr, 'Interpreter', 'none', 'FontSize', 12);
            set(gca,'YTickLabel',[])
    
            if i == 1
                legend({'Variation', 'Original'}, 'FontSize', 9,...
                    'Location', 'none', 'Position', [0.82, 0.92, 0.077, 0.032]);
            end
        end
        xlabel('Time (second)');
    
        saveas(f, strcat(outputdir, dataid, '_dtw.png'));
    end
    
    %% Statistical difference
    addpath('./lib/KDE/');
    addpath('./lib/two-sample/');
    nbpobj = nbpfittest(1, 500, 'robust');
    priorodds = 1;
    log10bf = zeros(numel(dataname), 2);
    posterior_H0 = zeros(numel(dataname), 2);
    y = linspace(-5, 5, 1024);
    
    for k=1:2
        switch k
            case 1
                D = ioi;
                a = 0;
                b = 2.5;
                suffix = 'ioi';
            case 2
                D = ioiratio;
                a = 0;
                b = 1;
                suffix = 'ioiratio';
        end

        for i=1:numel(dataname)
            lnbf = nbpobj.test(D{i, 1}, D{i, 2});
            [posterior_H0(i, k), ~] = nbpobj.posterior(priorodds, lnbf);
            log10bf(i, k) = lnbf/log(10);
        end
        
        if figflag
            f = figure(1 + k);
            f.Position = [50, 75, 650, 900];
            clf; cla;
    
            x = normcdf(y).*(b - a);
            density = zeros(numel(y), 2);
            for i=1:numel(dataname)
                for j=1:2
                    X = D{i, j};
                    Y = norminv((X - a)./(b - a), 0, 1);
                    h = kdebandwidth_lp(Y);
                    density(:, j) = kde(y, Y, h);
                end
        
                subplot(numel(dataname), 1, i);
                plot(x, density);
        
                if i == 1
                    titlestr = {['[', dataid, ']'], '', dataname{i}};
                else
                    titlestr = dataname(i);
                end
                
                titlestr = [titlestr, ['Posterior prob. = ', num2str(posterior_H0(i, k), '%3.3f'),...
                        ', log10 Bayes factor = ', num2str(log10bf(i, k), '%3.3f'), ...
                        ', n = (', num2str(numel(ioi{i, 1})), ', ', num2str(numel(ioi{i, 2})), ')']];
    
                title(titlestr, 'Interpreter', 'none', 'FontSize', 12);
                set(gca,'YTickLabel',[])
        
                if i == 1
                    legend({'Variation', 'Original'}, 'FontSize', 9, 'Location', 'northeast');
                end
            end
        
            saveas(f, strcat(outputdir, dataid, '_', suffix, '_nbp-two-sample.png'));
        end
    end
end