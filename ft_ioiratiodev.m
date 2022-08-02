function ioiratiodev = ft_ioiratiodev(t_onset, t_break)
    %%
    [~, ioiratio, ~, ~, ~] = helper.h_ioi(t_onset, t_break);
    X = ioiratio(:);
    
    %%
    X = sort(X);
    n = numel(X);
    h = linspace(std(X)*(log(n)/n), 1.06*min(std(X), (quantile(X, 0.75) - quantile(X, 0.25))/1.34)*n^(-0.2), 128);
    C_tol = cell(numel(h), 1);

    for j=1:numel(h)
        f_X = arrayfun(@(X_i) normpdf(X, X_i, h(j)), X, 'UniformOutput', false);
        f_X = mean(cat(2, f_X{:}), 2);
        thresh = normpdf(0, 0, h(j))/n * 2;
        idx = find(f_X > thresh);

        C = meanshift(X(idx), X(idx)', 1e-8, h(j));
        C_tol{j} = uniquetol(C, 1e-6);
    end
    
    %%
    K = cellfun(@(C) numel(C), C_tol);
    K_unq = unique(K);
    L = zeros(numel(K_unq), 1);
    for k=1:numel(L)
        idx_b = find(K == K_unq(k), 1, 'first');
        idx_d = find(K < K_unq(k), 1, 'first');

        if isempty(idx_d)
            idx_d = numel(h);
        end
        L(k) = h(idx_d) - h(idx_b);
    end

    [~, idx] = max(L);
    idx_h = find(K == K_unq(idx), 1, 'first');
    
    %%
    f_X = arrayfun(@(X_i) normpdf(X, X_i, h(idx_h)), X, 'UniformOutput', false);
    f_X = mean(cat(2, f_X{:}), 2);
    thresh = normpdf(0, 0, h(idx_h))/n * 2;
    idx = find(f_X > thresh);

    C = meanshift(X(idx), X(idx)', 1e-8, h(idx_h));
    [C_h, ~, IC] = uniquetol(C, 1e-6);
    
    ioiratiodev = [];
    for k=1:numel(C_h)
        ioiratiodev = [ioiratiodev; abs(C_h(k) - X(idx(IC == k)))];
    end

    %{
    if numel(idx) ~= numel(X)
        idx_d = setdiff(1:numel(X), idx);

        for j=1:numel(idx_d)
            T_i = [T_i; min(abs(X(idx_d(j)) - C_h))];
        end
    end
    %}
end