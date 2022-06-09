function plot_20220517(log10bf, posterior_H0, participant, annotator, typelist, datatype, outputdir)
    %%
    Map_typecolor = containers.Map(typelist, {'#0072BD', '#D95319', '#EDB120', '#7E2F8E'});

    %%
    for k=1:4
        f = figure;

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

        for i=1:numel(participant)
            idx_i = contains(annotator, participant{i});

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
        set(gca, 'XTick', 1:numel(participant));
        set(gca, 'XTickLabel', participant);
        ax = gca(f);
        ax.FontSize = 12;
        xlabel('Annotators', 'FontSize', 12);
        ylabel(ylabelstr, 'FontSize', 12);
        title(titlestr, 'FontSize', 14);
        legend(typelist, 'FontSize', 10);

        saveas(f, strcat(outputdir, fileid, '.png'));
    end
end