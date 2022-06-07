function plot_20220526(log10bf, posterior_H0, Rvals, T, dataorder, typelist, outputdir)
    %%
    Map_typecolor = containers.Map(typelist, {'#0072BD', '#D95319', '#EDB120', '#7E2F8E'});
    Map_langshape = containers.Map({'Japanese', 'English', 'Marathi', 'Farsi', 'Yoruba'},...
        {'o', '+', 'x', 's', '-'});

    datatype = T.datatype(dataorder);
    language = T.language(dataorder);
    annotator = strcat(T.annotator(dataorder), ' (', T.annotround(dataorder), ')');
    annotatorlist = unique(annotator);
    
    %%
    f = figure;
    f.Position = [40, 480, 700, 500];

    for i=1:numel(annotatorlist)
        idx = strcmp(annotatorlist{i}, annotator);

        R_i = Rvals.R(idx);
        datatype_i = datatype(idx);
        language_i = language(idx);
        x = normrnd(i, 0.08, [numel(R_i), 1]);

        for j=1:numel(R_i)
            scatter(x(j), R_i(j), 'MarkerEdgeColor', Map_typecolor(datatype_i{j}), 'Marker', Map_langshape(language_i{j}));
            hold on
        end

        scatter(i, mean(R_i), 'MarkerEdgeColor', 'None', 'MarkerFaceColor', 'k', 'MarkerFaceAlpha', 0.5, 'Marker', 'o');
    end

    ylim([0, 1.2]);
    set(gca, 'XTick', 1:numel(annotatorlist));
    set(gca, 'XTickLabel', annotatorlist);
    ax = gca(f);
    ax.FontSize = 10;
    ax.TickLabelInterpreter = 'none';
    xlabel('Annotator', 'FontSize', 12);
    ylabel('R-value', 'FontSize', 12);
    title('Onset quality measure', 'FontSize', 14);

    h = zeros(numel(typelist), 1);
    for i=1:numel(typelist)
        h(i) = scatter(NaN, NaN, 'MarkerEdgeColor', Map_typecolor(typelist{i}));
    end

    langlist = unique(language);
    h_shape = zeros(numel(langlist), 1);
    for i=1:numel(langlist)
        h_shape(i) = scatter(NaN, NaN, 'MarkerEdgeColor', 'k', 'Marker', Map_langshape(langlist{i}));
    end
    legend([h; h_shape], [typelist, langlist'], 'FontSize', 10, 'NumColumns', 2);
    hold off

    saveas(f, strcat(outputdir, 'R-val', '.png'));

    %%
    for k=1:4
        f = figure;
        f.Position = [680, 500, 560, 480];

        switch k
            case 1
                X = log10bf(:, 1);
                titlestr = 'IOI';
                ylabelstr = 'log10 Bayes factor';
                yl = [min(log10bf(:)) - 0.75, max(log10bf(:)) + 0.75];
                fileid = 'bf-ioi';
                referenceval = 1;
            case 2
                X = log10bf(:, 2);
                titlestr = 'IOI ratio';
                ylabelstr = 'log10 Bayes factor';
                yl = [min(log10bf(:)) - 0.75, max(log10bf(:)) + 0.75];
                fileid = 'bf-ioiratio';
                referenceval = 1;
            case 3
                X = posterior_H0(:, 1);
                titlestr = 'IOI';
                ylabelstr = 'Posterior prob.';
                yl = [0, 1.3];
                fileid = 'postprob-ioi';
                referenceval = [];
            case 4
                X = posterior_H0(:, 2);
                titlestr = 'IOI ratio';
                ylabelstr = 'Posterior prob.';
                yl = [0, 1.3];
                fileid = 'postprob-ioiratio';
                referenceval = [];
        end

        for i=1:numel(annotatorlist)
            idx_i = contains(annotator, annotatorlist{i});

            for j=1:numel(typelist)
                idx_j = strcmp(typelist{j}, datatype);
                idx = idx_i & idx_j;
                n = sum(idx);

                scatter(normrnd(i, 0.06, [n, 1]), X(idx), 'MarkerEdgeColor', Map_typecolor(typelist{j}));
                hold on
            end
        end

        if ~isempty(referenceval)
            xl = xlim();
            plot(xl, referenceval.*[1, 1], '-.k');
        end

        hold off
        ylim(yl);
        set(gca, 'XTick', 1:numel(annotatorlist));
        set(gca, 'XTickLabel', annotatorlist);
        ax = gca(f);
        ax.FontSize = 12;
        xlabel('Annotators', 'FontSize', 12);
        ylabel(ylabelstr, 'FontSize', 12);
        title(titlestr, 'FontSize', 14);
        legend(typelist, 'FontSize', 10);

        saveas(f, strcat(outputdir, fileid, '.png'));
    end
end