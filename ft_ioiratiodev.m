function ioiratiodev = ft_ioiratiodev(t_onset, t_break)
    %% 
    [~, ioiratio, ~, ~, ~] = helper.h_ioi(t_onset, t_break);
    X = ioiratio(:);
    
    %% Find the most stable Betti number (Pokorny et al., 2012)
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
    K_unq = [K(1), 1, 1];
    for i=2:numel(K)
        if K(i - 1) ~= K(i)
            K_unq(end + 1, :) = [K(i), i, 1];
        else
            K_unq(end, 3) = K_unq(end, 3) + 1;
        end
    end
    
    [~, idx_K] = max(K_unq(:, 3));
    idx_h = K_unq(idx_K, 2);
    %{
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
    %}
    
    %%
    h_lb = h(idx_h);
    h_ub = h(idx_h + K_unq(idx_K, 3) - 1);
    h_top = h_lb + (h_ub - h_lb)/2*n^(-1/5);

    f_X = arrayfun(@(X_i) normpdf(X, X_i, h_top), X, 'UniformOutput', false);
    f_X = mean(cat(2, f_X{:}), 2);
    thresh = normpdf(0, 0, h_top)/n * 2;
    idx = find(f_X > thresh);

    C = meanshift(X(idx), X(idx)', 1e-8, h_top);
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

    %%
    %{
    fobj = figure;
    fobj.Position = [6, 383, 461, 471];

    support = linspace(0, 1, 512);
    h_opt = h_top;
    f_X = arrayfun(@(x_i) mean(normpdf(x_i, X, h_opt)), support);

    subplot(3, 1, 1);
    plot(h, K);
    yl = ylim();
    hold on
    stem(h(idx_h), yl(2), 'Marker', 'none', 'Linestyle', '-.', 'Color', 'm');
    stem(h(idx_h + K_unq(idx_K, 3) - 1), yl(2), 'Marker', 'none', 'Linestyle', '-.', 'Color', 'm')
    hold off
    title('Change in the number of modes according to bandwidth', 'Fontsize', 10);
    
    subplot(3, 1, 2);
    scatter(support, f_X, 'Marker', '.');
    yl = ylim();
    hold on
    stem(C_h, yl(2).*ones(numel(C_h), 1), 'Marker', 'none');
    scatter(X, zeros(numel(X), 1), 'Marker', '|');
    hold off
    title('KDE that bandwidth is based on the stable modes', 'Fontsize', 10);
    
    subplot(3, 1, 3);
    histogram(ioiratiodev);
    xlim([0, 0.5]);
    title('IOI ratio deviation', 'Fontsize', 10);
    %}
end

%{
h = 0.028;
support = linspace(0, 1, 512)';
f = arrayfun(@(x_i) mean(normpdf(x_i, X, h)), support);

[t_birth, locs, ~, prmn] = findpeaks(f);
t_death = t_birth - prmn;

L = linspace(0, max(t_birth*1.05), 512);
B = zeros(numel(L), 1);
for i=1:numel(t_birth)
    idx_st = find(L < t_birth(i), 1, 'last');
    idx_ed = find(t_death(i) < L, 1, 'first');
    B(idx_ed:idx_st) = B(idx_ed:idx_st) + 1;
end

figure(1);
clf; cla;

subplot(4, 1, 1);
plot(support, f);
hold on
scatter(X, zeros(numel(X), 1), 'Marker', '|');
hold off
title(['\sigma = ', num2str(h, '%3.3f')]);

subplot(4, 1, 2);
scatter(t_death, t_birth);
M = max(t_birth)*1.05;
hold on
plot([0, M], [0, M], '-.m');
hold off
xlim([0, M]);
ylim([0, M]);

subplot(4, 1, 3);
for i=1:numel(t_birth)
    plot([t_birth(i) t_death(i)], [i, i], 'Color', 'k');
    hold on
end
hold off

subplot(4, 1, 4);
plot(L, B);
%}