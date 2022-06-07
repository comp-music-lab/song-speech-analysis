function analysis_fullvsexcerpt
    %%
    dataname = {...
        'John_McBride_English_Irish_Anthem_FieldsOfAthenry_20220219_desc',...
        'John_McBride_English_Irish_Anthem_FieldsOfAthenry_20220219_song',...
        'John_McBride_English_Irish_Anthem_FieldsOfAthenry_20220219_inst',...
        'John_McBride_English_Irish_Anthem_FieldsOfAthenry_20220219_recit'...
        };
    fullonsetdir = './data/Stage 1 RR Full/Patrick/';
    excerptonsetdir = './data/Stage 1 RR Round 2/Patrick/';
    outputdir = './output/20220526/';
    dataid = 'full-vs-excerpt';
    
    %%
    [log10bf, posterior_H0] = h_analysis(dataname, fullonsetdir, excerptonsetdir, outputdir, dataid);

    %%
    dataorder = 1:4;
    h_str = @(X) X{end};
    typelist = cellfun(@(X) h_str(strsplit(X, '_')), dataname, 'UniformOutput', false);
    %plot_20220526(log10bf, posterior_H0, Rvals, T, dataorder, typelist, outputdir);
end

function [log10bf, posterior_H0] = h_analysis(dataname, fullonsetdir, excerptonsetdir, outputdir, dataid)
    %%
    ext = '.csv';
    ioi = cell(numel(dataname), 2);
    ioiratio = cell(numel(dataname), 2);
    onsetdir = {fullonsetdir, excerptonsetdir};
    
    for j=1:2
        for i=1:numel(dataname)
            switch j
                case 1
                    prefix_onset = 'onset_';
                    prefix_break = 'break_';
                case 2
                    prefix_onset = 'onset_(excerpt) ';
                    prefix_break = 'break_(excerpt) ';
            end
            
            onsetfilepath = [onsetdir{j}, prefix_onset, dataname{i}, ext];
            breakfilepath = [onsetdir{j}, prefix_break, dataname{i}, ext];

            T = readtable(onsetfilepath);
            t_onset = unique(T.Var1);
            T = readtable(breakfilepath);
            if isempty(T)
                t_break = [];
            else
                t_break = unique(T.Var1);
            end
            
            [ioi{i, j}, ioiratio{i, j}] = helper.h_ioi(t_onset, t_break);
            ioi{i, j} = ioi{i, j}(:);
            ioiratio{i, j} = ioiratio{i, j}(:);
        end
    end

    %%
    addpath('./lib/KDE/');
    y = linspace(-5, 5, 1024);
    density = zeros(numel(y), 2);

    addpath('./lib/two-sample/');
    nbpobj = nbpfittest(1, 500, 'robust');
    priorodds = 1;
    log10bf = zeros(numel(dataname), 2);
    posterior_H0 = zeros(numel(dataname), 2);
    
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

        %%
        for i=1:numel(dataname)
            lnbf = nbpobj.test(D{i, 1}, D{i, 2});
            [posterior_H0(i, k), ~] = nbpobj.posterior(priorodds, lnbf);
            log10bf(i, k) = lnbf/log(10);

            [h, p] = kstest2(D{i, 1}, D{i, 2})
        end
        
        %%
        f = figure(k);
        f.Position = [50, 75, 650, 900];
        clf; cla;

        x = normcdf(y).*(b - a);
        for i=1:numel(dataname)
            for j=1:2
                X = D{i, j};
                Y = norminv((X - a)./(b - a), 0, 1);
                h = kdebandwidth_lp(Y);
                density(:, j) = kde(y, Y, h);
            end
    
            subplot(numel(dataname), 1, i);
            plot(x, density);
    
            titlestr = [dataname(i), ['Posterior prob. = ', num2str(posterior_H0(i, k), '%3.3f'),...
                    ', log10 Bayes factor = ', num2str(log10bf(i, k), '%3.3f'), ...
                    ', n = (', num2str(numel(ioi{i, 1})), ', ', num2str(numel(ioi{i, 2})), ')']];

            title(titlestr, 'Interpreter', 'none', 'FontSize', 12);
            set(gca,'YTickLabel',[])
    
            if i == 1
                legend({'Full', 'Excerpt'}, 'FontSize', 9, 'Location', 'northeast');
            end
        end
    
        saveas(f, strcat(outputdir, dataid, '_', suffix, '_nbp-two-sample.png'));
    end
end