function analysis_onsetquality
    %%
    pprm = plotprm();
    outputdir = './output/20220705/';
    
    %% Full-length vs. Excerpt
    pairinfo = readtable('./pairinfo_S1RR_full.csv');
    datadir = './data';

    result = h_scoring(pairinfo, datadir, 'within-subjects_fs');
    h_plot_scoring(result, pprm, outputdir, 'within-subjects_fs');

    %% Onset accuracy
    thresh = [0.020, 0.025, 0.040, 0.050, 0.080, 0.100]';
    
    pairinfo = readtable('./pairinfo_S1RR_IRR.csv');
    datadir = './data';
    result_ss = h_threshcurve(pairinfo, datadir, thresh);
    result_ss.trial = repmat({'within-subjects (re-annotation)'}, [size(result_ss, 1), 1]);

    pairinfo = readtable('./pairinfo_S1RR_R1R2.csv');
    datadir = './data/Stage 1 RR Round 1';
    result_R1 = h_threshcurve(pairinfo, datadir, thresh);
    result_R1.trial = repmat({'between-subjects (w/o texts)'}, [size(result_R1, 1), 1]);

    pairinfo = readtable('./pairinfo_S1RR_R1R2.csv');
    datadir = './data/Stage 1 RR Round 2';
    result_R2 = h_threshcurve(pairinfo, datadir, thresh);
    result_R2.trial = repmat({'between-subjects (w texts)'}, [size(result_R2, 1), 1]);

    result = [result_ss; result_R1; result_R2];
    
    h_plot_oq(result, pprm, outputdir);
    
    

    %%
    h_plot_scoring(result, pprm, outputdir, 'within-subjects_ss');
    
    %% vs. Automated methods


    %% Full-length vs. Excerpt
    result_ss = h_scoring(pairinfo, datadir, 'within-subjects_ss', thresh);
    result_R2 = h_scoring(pairinfo, datadir, 'between-subjects', thresh);

    
    
    

    result = [result_R1; result_R2];
    h_plot_scoring(result, pprm, outputdir, 'between-subjects');
end

function result = h_threshcurve(pairinfo, datadir, thresh)
    %%
    annotatorlist = unique(pairinfo.annotator);
    result = [];
    
    %%
    for i=1:numel(annotatorlist)
        idx = find(strcmp(annotatorlist{i}, pairinfo.annotator));

        for j=1:numel(idx)
            %%
            onsetfilepath = strcat(datadir, pairinfo.relpath_annot{idx(j)}, 'onset_', pairinfo.dataname_annot{idx(j)}, '.csv');
            T = readtable(onsetfilepath);
            t_onset_est = table2array(T(:, 1));

            onsetfilepath = strcat(datadir, pairinfo.relpath_ref{idx(j)}, 'onset_', pairinfo.dataname_ref{idx(j)}, '.csv');
            T = readtable(onsetfilepath);
            t_onset_ref = table2array(T(:, 1));

            %%
            result_j = oq_threshcurve(t_onset_ref, t_onset_est, thresh, annotatorlist(i), pairinfo.language(idx(j)), pairinfo.type(idx(j)));
            result = [result; result_j];
        end
    end
end

function h_plot_oq(result, pprm, outputdir)
    %%
    triallist = unique(result.trial);
    typelist = unique(result.type);
    threshlist = unique(result.thresh);
    
    annotatorlist = unique(result.annotator);
    M_annotatorfacecolor = containers.Map(annotatorlist, {'#0072BD', '#D95319', '#EDB120', '#7E2F8E'});
    h_annotator = zeros(numel(annotatorlist), 1);

    %{
    langlist = unique(result.language);
    h_lang = zeros(numel(langlist), 1);
    h_type = zeros(numel(typelist), 1);
    %}

    %%
    for l=1:numel(threshlist)
        idx_l = result.thresh == threshlist(l);

        figobj = figure();
        figobj.Position = [30, 650, 1280, 310];
            
        for i=1:numel(triallist)
            idx_i = strcmp(result.trial, triallist{i});

            for k=1:numel(typelist)
                idx_k = strcmp(result.type, typelist{k});

                for j=1:numel(annotatorlist)
                    idx_j = strcmp(result.annotator, annotatorlist{j});
                    idx = idx_i & idx_k & idx_l & idx_j;
                    
                    Y = result.F1(idx);
                    X = i.*ones(numel(Y), 1) - ((numel(typelist) + 1)/2 - k).*0.1;
                    scatter(X, Y,...
                        'MarkerFaceColor', M_annotatorfacecolor(annotatorlist{j}), 'Marker', 'o', 'MarkerEdgeColor', 'none');
                    hold on
                end
            end
        end
        
        for i=1:numel(annotatorlist)
            h_annotator(i) = scatter(NaN, NaN, 'Marker', 'o', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', M_annotatorfacecolor(annotatorlist{i}));
        end
        legend(h_annotator, annotatorlist, 'FontSize', pprm.legendfontsize, 'Location', 'northeast');

        %{
        for i=1:numel(langlist)
            h_lang(i) = scatter(NaN, NaN, 'Marker', 'o', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', pprm.langcolormap(langlist{i}));
        end

        for i=1:numel(typelist)
            h_type(i) = scatter(NaN, NaN, 'Marker', pprm.typemarkermap(typelist{i}), 'MarkerEdgeColor', 'k');
        end

        legend([h_lang; h_type], [langlist; typelist], 'FontSize', pprm.legendfontsize);
        %}

        hold off;
        
        xlim([0.5, numel(triallist) + 0.65]);
        ylim([-0.1, 1.1]);
        xticks(1:numel(triallist));
        xticklabels(triallist);
        
        ax = gca(figobj);
        ax.FontSize = pprm.tickfontsize;
        ylabel('F-measure', 'FontSize', pprm.labelfontsize);

        title(['Threshold = ', num2str(threshlist(l), '%3.3f')],...
            'FontSize', pprm.titlefontsize);

        saveas(figobj, strcat(outputdir, 'onsetquality_', '_thresh', num2str(l), '.png'));
    end
end

function result = h_scoring(pairinfo, datadir, experiment, thresh)
    %%
    if nargin < 4
        thresh = 0.02;
    end

    %%
    annotatorlist = unique(pairinfo.annotator);
    result = [];
    addpath('./lib/two-sample/');
    nbpobj = nbpfittest(1, 500, 'robust');
    priorodds = 1;

    %%
    for i=1:numel(annotatorlist)
        idx = find(strcmp(annotatorlist{i}, pairinfo.annotator));

        for j=1:numel(idx)
            %%
            onsetfilepath = strcat(datadir, pairinfo.relpath_annot{idx(j)}, 'onset_', pairinfo.dataname_annot{idx(j)}, '.csv');
            T = readtable(onsetfilepath);
            t_onset_est = table2array(T(:, 1));

            onsetfilepath = strcat(datadir, pairinfo.relpath_ref{idx(j)}, 'onset_', pairinfo.dataname_ref{idx(j)}, '.csv');
            T = readtable(onsetfilepath);
            t_onset_ref = table2array(T(:, 1));

            %%
            breakfilepath = strcat(datadir, pairinfo.relpath_annot{idx(j)}, 'break_', pairinfo.dataname_annot{idx(j)}, '.csv');
            T = readtable(breakfilepath, 'ReadVariableNames', false);
            if ~isempty(T)
                t_break_est = table2array(T(:, 1));

                if iscell(t_break_est)
                    t_break_est = str2double(cell2mat(t_break_est));
                end
            else
                t_break_est = [];
            end

            breakfilepath = strcat(datadir, pairinfo.relpath_ref{idx(j)}, 'break_', pairinfo.dataname_ref{idx(j)}, '.csv');
            T = readtable(breakfilepath, 'ReadVariableNames', false);
            if ~isempty(T)
                t_break_ref = table2array(T(:, 1));

                if iscell(t_break_ref)
                    t_break_ref = str2double(cell2mat(t_break_ref));
                end
            else
                t_break_ref = [];
            end

            %%
            [ioi_est, ioiratio_est] = helper.h_ioi(t_onset_est, t_break_est);
            [ioi_ref, ioiratio_ref] = helper.h_ioi(t_onset_ref, t_break_ref);

            %%
            lnbf_H0_ioi = nbpobj.test(ioi_est(:), ioi_ref(:));
            [posterior_H0_ioi, ~] = nbpobj.posterior(priorodds, lnbf_H0_ioi);
            log10bf_H0_ioi = lnbf_H0_ioi/log(10);
            
            lnbf_H0_ioiratio = nbpobj.test(ioiratio_est(:), ioiratio_ref(:));
            [posterior_H0_ioiratio, ~] = nbpobj.posterior(priorodds, lnbf_H0_ioiratio);
            log10bf_H0_ioiratio = lnbf_H0_ioiratio/log(10);
            
            if strcmp('between-subjects', experiment) || strcmp('within-subjects_ss', experiment)
                [R, F1, PRC, RCL, OS] = ft_rvalue(t_onset_ref, t_onset_est, thresh);

                [~, ix, iy] = dtw(t_onset_ref, t_onset_est);
                dist_average = mean(t_onset_ref(ix) - t_onset_est(iy));
                dist_var = var(t_onset_ref(ix) - t_onset_est(iy), 1);

                result = [...
                result;...
                table(F1, R, PRC, RCL, OS, dist_average, dist_var,...
                posterior_H0_ioi, log10bf_H0_ioi, posterior_H0_ioiratio, log10bf_H0_ioiratio,...
                annotatorlist(i), pairinfo.language(idx(j)), pairinfo.type(idx(j)),...
                'VariableNames', {'F1', 'Rval', 'PRC', 'RCL', 'OS', 'dtwdist_mean', 'dtwdist_var',...
                'posterior_H0_ioi', 'log10bf_H0_ioi', 'posterior_H0_ioiratio', 'log10bf_H0_ioiratio',...
                'annotator', 'lang', 'type'})...
                ];
            elseif strcmp('within-subjects_fs', experiment)
                result = [...
                result;...
                table(posterior_H0_ioi, log10bf_H0_ioi, posterior_H0_ioiratio, log10bf_H0_ioiratio,...
                annotatorlist(i), pairinfo.language(idx(j)), pairinfo.type(idx(j)),...
                'VariableNames', {'posterior_H0_ioi', 'log10bf_H0_ioi', 'posterior_H0_ioiratio', 'log10bf_H0_ioiratio',...
                'annotator', 'lang', 'type'})...
                ];
            end
        end
    end
end

function h_plot_scoring(result, pprm, outputdir, experiment)
    %%
    annotatorlist = unique(result.annotator);
    M = numel(annotatorlist);
    
    %%
    if strcmp('between-subjects', experiment)
        xticklabelstr = {'w/o texts', 'w/ texts'};
        xtickval = [1, 2];
        xl = [0.7, 3.2];
        idx_q = 1:5;
        fileid_expm = 'between';
    elseif strcmp('within-subjects_ss', experiment)
        xticklabelstr = {'re-annotation'};
        xtickval = 1;
        xl = [0.7, 1.3];
        idx_q = 2:7;
        fileid_expm = 'within-ss';
    elseif strcmp('within-subjects_fs', experiment)
        xticklabelstr = {'full vs. excerpt'};
        xtickval = 1;
        xl = [0.7, 1.3];
        idx_q = 2:5;
        fileid_expm = 'within-fs';
    end

    %%
    for m=1:M
        result_m = result(strcmp(annotatorlist{m}, result.annotator), :);
        langlist_m = unique(result_m.lang);
        typelist_m = unique(result_m.type);

        for q=idx_q
            figobj = figure;
            figobj.Position = [400, 200, 500, 720];
            
            switch q
                case 1
                    metric = result_m.F1;
                    yl = [0, 1];
                    ylabelstr = 'F-score';
                    fileid = 'Fscore';
                case 2
                    metric = result_m.posterior_H0_ioi;
                    yl = [0, 1];
                    ylabelstr = 'Posterior(H_0|D)_{IOI}';
                    fileid = 'pstr-ioi';
                case 3
                    metric = result_m.posterior_H0_ioiratio;
                    yl = [0, 1];
                    ylabelstr = 'Posterior(H_0|D)_{IOI ratio}';
                    fileid = 'pstr-ioiratio';
                case 4
                    metric = result_m.log10bf_H0_ioi;
                    yl = [min(result.log10bf_H0_ioi) - 0.5, max(result.log10bf_H0_ioi) + 0.5];
                    ylabelstr = 'log_{10} Bayes Factor_{IOI}';
                    fileid = 'log10BF-ioi';
                case 5
                    metric = result_m.log10bf_H0_ioiratio;
                    yl = [min(result.log10bf_H0_ioiratio) - 0.5, max(result.log10bf_H0_ioiratio) + 0.5];
                    ylabelstr = 'log_{10} Bayes Factor_{IOI ratio}';
                    fileid = 'log10BF-ioiratio';
                 case 6
                    metric = result_m.dtwdist_mean;
                    yl = [min(result.dtwdist_mean) - 0.01, max(result.dtwdist_mean) + 0.01];
                    ylabelstr = 'Mean of the DTW distance of onset';
                    fileid = 'dtwdist-mean';
                 case 7
                    metric = result_m.dtwdist_var;
                    yl = [0, max(result.dtwdist_var) + 0.001];
                    ylabelstr = 'Variance of the DTW distance of onset';
                    fileid = 'dtwdist-var';
            end
    
            for i=1:numel(langlist_m)
                for j=1:numel(typelist_m)
                    idx_ij = strcmp(result_m.lang, langlist_m{i}) & strcmp(result_m.type, typelist_m{j});

                    if strcmp('between-subjects', experiment)
                        xy = [0, 0; 0, 0];
                        for k=1:2
                            idx = find(result_m.round == k & idx_ij);
                            scatter(k, metric(idx), 'SizeData', 45, 'MarkerEdgeColor', pprm.langcolormap(langlist_m{i}), 'Marker', pprm.typemarkermap(typelist_m{j}));
                            xy(k, :) = [k, metric(idx)];
                            hold on
                        end
                        
                        if all(~(xy == 0))
                            plot(xy(:, 1), xy(:, 2), 'Color', [0.4, 0.4, 0.4], 'LineStyle', '-.');
                        end
                    elseif strcmp('within-subjects_ss', experiment) || strcmp('within-subjects_fs', experiment)
                        idx = idx_ij;
                        scatter(1, metric(idx), 'SizeData', 45, 'MarkerEdgeColor', pprm.langcolormap(langlist_m{i}), 'Marker', pprm.typemarkermap(typelist_m{j}));
                        hold on
                    end
                end
            end
            
            h_lang = zeros(numel(langlist_m), 1);
            for i=1:numel(langlist_m)
                h_lang(i) = scatter(NaN, NaN, 'Marker', 'o', 'MarkerEdgeColor', 'none', 'MarkerFaceColor', pprm.langcolormap(langlist_m{i}));
            end
    
            h_type = zeros(numel(typelist_m), 1);
            for i=1:numel(typelist_m)
                h_type(i) = scatter(NaN, NaN, 'Marker', pprm.typemarkermap(typelist_m{i}), 'MarkerEdgeColor', 'k');
            end
    
            legend([h_lang; h_type], [langlist_m; typelist_m], 'FontSize', pprm.legendfontsize);
    
            xlim(xl);
            ylim(yl);
            xticks(xtickval);
            xticklabels(xticklabelstr);
            ax = gca(figobj);
            ax.FontSize = pprm.tickfontsize;
            ylabel(ylabelstr, 'FontSize', pprm.labelfontsize);
            title(['Annotator: ', annotatorlist{m}], 'FontSize', pprm.titlefontsize);
    
            saveas(figobj, strcat(outputdir, 'S1RR_', fileid_expm, '_', annotatorlist{m}, '_', fileid, '.png'));
        end
    end
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