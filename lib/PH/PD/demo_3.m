function demo_3
    %%
    n = [60, 40];

    a = gamrnd(2, 2);
    b = gamrnd(1, 2);
    mu = normrnd(0, 3);
    sgm = gamrnd(2, 1);
    X = [gamrnd(a, b, [n(1), 1]); normrnd(mu, sgm, [n(2), 1])];
    support_X = linspace(min(X) - 4, max(X) + 4);
    f = n(1)/sum(n).*gampdf(support_X, a, b) + n(2)/sum(n).*normpdf(support_X, mu, sgm);
    
    %%
    h_cv = kdebandwidth_lp(X);
    support = linspace(min(X) - 5*h_cv, max(X) + 5*h_cv, 1024);
    f_X = kde(support, X, h_cv);
    [t_b, locs, ~, prmns] = findpeaks(f_X);
    PD = [t_b - prmns; t_b]';

    %%
    B = 3000;
    al = 0.10;
    n = numel(X);
    S = floor(n*(1 - exp(-1))) + 1;
    T = zeros(B, 1);

    parfor b=1:B
        Y = datasample(X, S);
        while numel(uniquetol(Y, 1e-6)) ~= S
            Y = [Y; datasample(X, 1)];
        end
        Y = Y + h_cv.*normrnd(0, 1, size(Y));

        f_Y = kde(support, Y, h_cv);
        [t_b, ~, ~, prmns] = findpeaks(f_Y);
        PD_b = [t_b - prmns; t_b]';

        T(b) = bottleneckdist(PD_b, PD);
    end

    T_al = quantile(T, 1 - al);
    idx_al = ~((PD(:, 1) + T_al) > PD(:, 2) | PD(:, 1) > (PD(:, 2) - T_al));
    C_E = support(locs(idx_al));

    %%
    figure(1);
    subplot(2, 1, 1);
    plot(support_X, f);
    hold on
    plot(support, f_X, '-.m');
    for j=1:numel(C_E)
        [~, idx_min] = min(abs(support_X - C_E(j)));
        stem(support_X(idx_min), f(idx_min));
    end
    scatter(C_E, zeros(numel(C_E), 1), 'MarkerEdgeColor', '#0072BD', 'Marker', 'x');
    hold off
    subplot(2, 1, 2);
    scatter(PD(:, 1), PD(:, 2));
    lmax = max(max(xlim(), max(ylim())));
    xlim([0, lmax]); ylim([0, lmax]);
    hold on
    plot([0, lmax], [0, lmax], '-.m');
    plot([0, lmax - T_al], [T_al, lmax]);
    hold off
end