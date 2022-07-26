function demo_1
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
    h = h_hset(X);
    [perbclen, idx_spt, support] = h_PDinfo(X, h);

    %%
    J = numel(h);
    C = cell(J, 1);
    I = cell(J, 1);
    C{1} = support(idx_spt{1});
    I{1} = 1:numel(idx_spt{1});
    totalBL = perbclen{1}./sum(perbclen{1});

    for j=2:J
        C{j} = support(idx_spt{j});
        
        %{
        if numel(C{j - 1}) == 1 && numel(C{j}) == 1
            break;
        end
        %}
        
        I{j} = zeros(numel(C{j}), 1);
        BL_norm = perbclen{j}./sum(perbclen{j});

        for k=1:numel(C{j})
            [~, idx_I] = min(abs(C{j - 1} - C{j}(k)));
            I{j}(k) = I{j - 1}(idx_I);

            totalBL(I{j}(k)) = totalBL(I{j}(k)) + BL_norm(k);
        end
    end
    
    totalBL = totalBL./sum(totalBL);

    [P, idx_P] = sort(totalBL, 'desc');
    P_sum = cumsum(P);
    idx_u = find(P_sum < 0.95, 1, 'last');
    if isempty(idx_u)
        idx_u = find(P_sum >= 0.95, 1, 'first');
    end
    idx_L = idx_P(1:idx_u);

    C_E = C{1}(idx_L);

    %%
    figure(1);
    subplot(1, 2, 1);
    plot(support_X, f);
    hold on
    for j=1:numel(C_E)
        [~, idx_min] = min(abs(support_X - C_E(j)));
        stem(support_X(idx_min), f(idx_min));
    end
    scatter(C_E, zeros(numel(C_E), 1), 'MarkerEdgeColor', '#0072BD', 'Marker', 'x');
    hold off
    subplot(1, 2, 2);
    scatter(1:numel(P_sum), P_sum);
    hold on
    plot([1, numel(P_sum)], 0.95.*[1, 1], '-.k');
    hold off
end

function [perbclen, idx_spt, support] = h_PDinfo(X, h)
    support = linspace(min(X) - max(h)*2, max(X) + max(h)*2, 2048);
    J = numel(h);
    perbclen = cell(J, 1);
    idx_spt = cell(J, 1);
    
    for j=1:J
        f = kde(support, X, h(j));
        [~, idx_spt{j}, ~, perbclen{j}] = findpeaks(f);
    end
end

function h = h_hset(X, J)
    if nargin < 2
        J = 256;
    end
    
    n = numel(X);

    %{
    B = 2000;
    S = floor(n*(1 - exp(-1))) + 1;
    h_B = zeros(B, 1);
    parfor b=1:B
        Y = datasample(X, S);
        while numel(uniquetol(Y, 1e-6)) ~= S
            Y = [Y; datasample(X, 1)];
        end

        h_B(b) = kdebandwidth_lscv(Y);
    end
    h_max = quantile(h_B, 0.99);
    %}

    h_min = std(X)*(log(n)/n);

    h_max = 1.06 * min(1.34^(-1)*(quantile(X, 0.75) - quantile(X, 0.25)), std(X)) * n^(-1/5);
    
    h = linspace(h_min, h_max, J);
end