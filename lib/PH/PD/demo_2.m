function demo_2
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
    h_search = std(X);
    dlt = 0.2;
    
    while dlt > 1e-4
        dlt = dlt/2;
    
        while true
            h_search = h_search - dlt;
            support = linspace(min(X) - 3*h_search, max(X) + 3*h_search, 1024);
            f_X = kde(support, X, h_search);
            pks= findpeaks(f_X);
            nummode = numel(pks);
    
            if nummode > 1
                break;
            end
        end
    
        dlt = dlt/2;
    
        while true
            h_search = h_search + dlt;
            support = linspace(min(X) - 3*h_search, max(X) + 3*h_search, 1024);
            f_X = kde(support, X, h_search);
            pks= findpeaks(f_X);
            nummode = numel(pks);
    
            if nummode == 1
                break;
            end
        end
    end

    h_max = h_search;

    %%
    M = 256;
    h = sort(rand(M, 1).*h_max);
    support = linspace(min(X) - 3*h_max, max(X) + 3*h_max, 1024);
    PD = cell(M, 1);
    L = cell(M, 1);
    idx_modes = cell(M, 1);

    for m=1:M
        f_X = kde(support, X, h(m));
        [t_b, idx_modes{m}, ~, prmn] = findpeaks(f_X);
        PD{m} = [t_b - prmn; t_b]';
        L{m} = prmn./sum(prmn);
    end

    %%
    C_al = cell(M, 1);
    al = 0.05;

    for m=1:M
        [L_m, idx_m] = sort(L{m}, 'descend');
        S_m = cumsum(L_m);

        if S_m(1) < (1 - al)
            idx_al = find(S_m < (1 - al), 1, 'last');
        else
            idx_al = 1;
        end

        C_al{m} = support(idx_modes{m}(idx_m(1:idx_al)));
    end
    
    C_all = cat(2, C_al{:})';

    h_C = kdebandwidth_lp(C_all);
    f_C = arrayfun(@(X_i) normpdf(support, X_i, h_C), C_all, 'UniformOutput', false);
    f_C = mean(cat(1, f_C{:}), 1);

    [~, locs_C, ~, prmn] = findpeaks(f_C);
    L_C = prmn./sum(prmn);
    
    idx_C = persistentEntropy(L_C(:));
    C_E = support(locs_C(idx_C));
    
    %%
    figure(1);
    subplot(2, 1, 1);
    plot(support_X, f);
    hold on
    for j=1:numel(C_E)
        [~, idx_min] = min(abs(support_X - C_E(j)));
        stem(support_X(idx_min), f(idx_min));
    end
    scatter(C_E, zeros(numel(C_E), 1), 'MarkerEdgeColor', '#0072BD', 'Marker', 'x');
    hold off
    subplot(2, 1, 2);
    plot(support, f_C);
end