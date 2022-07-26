function demo_5
    %%
    n = [60, 40, 50];

    a = gamrnd(2, 2);
    b = gamrnd(1, 2);
    mu = normrnd(0, 3);
    sgm = gamrnd(2, 1);
    mu2 = normrnd(0, 4);
    sgm2 = gamrnd(2, 1);
    X = [gamrnd(a, b, [n(1), 1]); normrnd(mu, sgm, [n(2), 1]); normrnd(mu2, sgm2, [n(3), 1])];
    support_X = linspace(min(X) - 10, max(X) + 10);
    f = n(1)/sum(n).*gampdf(support_X, a, b) + n(2)/sum(n).*normpdf(support_X, mu, sgm)...
         + n(3)/sum(n).*normpdf(support_X, mu2, sgm2);
    
    %%
    h_max = std(X)/2;

    %%
    M = 1024;
    h = sort(rand(M, 1).*h_max);
    support = linspace(min(X) - 3*h_max, max(X) + 3*h_max, 1024);
    L = cell(M, 1);
    idx_modes = cell(M, 1);
    idx_C = cell(M, 1);
    C = cell(M, 1);
    C_E = cell(M, 1);

    for m=1:M
        f_X = kde(support, X, h(m));
        [~, idx_modes{m}, ~, prmn] = findpeaks(f_X);
        L{m} = prmn./sum(prmn);
        C{m} = support(idx_modes{m});

        idx_C{m} = persistentEntropy(L{m}(:));
        C_E{m} = support(idx_modes{m}(idx_C{m}));
    end
    
    %%
    C_all = cat(2, C_E{:});
    C_all = C_all(:);
    d1 = cellfun(@(C_i) directionalHausdorff(C_i(:), C_all), C);
    d2 = cellfun(@(C_i) directionalHausdorff(C_all, C_i(:)), C);
    d3 = cellfun(@(C_i) hausdorffdist(C_i(:), C_all), C);
    
    %% ToDo: d1でhを決める -> mean-shift to infer the centroids -> k-means? tail-heaviness/power-law/kurtosis?

    %%
    h_cv = kdebandwidth_lp(X);
    f_X = kde(support_X, X, h_cv);

    figure(1);
    clf; cla;
    plot(support_X, f);
    hold on
    plot(support_X, f_X, '-.');
    scatter(C_all, zeros(numel(C_all), 1), 'Marker', '|', 'MarkerEdgeColor', 'm');
    scatter(X, zeros(numel(X), 1) + max(f)/2, 'Marker', '.');
    hold off

    figure(2);
    subplot(3, 1, 1);
    plot(d1);
    subplot(3, 1, 2);
    plot(d2);
    subplot(3, 1, 3);
    plot(d3);

    figure(3);
    [~, idx1] = min(d1);
    f_1 = kde(support_X, X, h(idx1));
    [~, idx2] = min(d2);
    f_2 = kde(support_X, X, h(idx2));
    f_2 = f_2./trapz(support_X, f_2);
    [~, idx3] = min(d3);
    f_3 = kde(support_X, X, h(idx3));
    subplot(3, 1, 1);
    plot(support_X, f_1); hold on; plot(support_X, f); hold off;
    title(num2str(idx1));
    subplot(3, 1, 2);
    plot(support_X, f_2); hold on; plot(support_X, f); hold off;
    title(num2str(idx2));
    subplot(3, 1, 3);
    plot(support_X, f_3); hold on; plot(support_X, f); hold off;
    title(num2str(idx3));
end