function demo_4
    %%
    n = [60, 40];

    a = gamrnd(2, 2);
    b = gamrnd(1, 2);
    mu = normrnd(0, 3);
    sgm = gamrnd(2, 1);
    X = [gamrnd(a, b, [n(1), 1]); normrnd(mu, sgm, [n(2), 1])];
    support_X = linspace(min(X) - 6, max(X) + 6);
    f = n(1)/sum(n).*gampdf(support_X, a, b) + n(2)/sum(n).*normpdf(support_X, mu, sgm);
    
    [t_b, ~, ~, prmns_f] = findpeaks(f);
    PD = [t_b - prmns_f; t_b]';

    %%
    M = 200;
    B = 2000;
    al = 0.05;
    S = floor(numel(X)*(1 - exp(-1))) + 1;
    T = zeros(B, 1);
    T_al = zeros(M, 1);
    
    fw = waitbar(0, 'Wait...');
    for m=1:M
        waitbar(m/M, fw, 'Wait...');

        X = [gamrnd(a, b, [n(1), 1]); normrnd(mu, sgm, [n(2), 1])];
        support = linspace(min(X) - 15, max(X) + 15, 512);
        %h_cv = kdebandwidth_lp(X);
        h_cv = kdebandwidth_lscv(X);

        parfor b=1:B
            Y = datasample(X, numel(X));
            %{
            Y = datasample(X, S);
            while numel(uniquetol(Y, 1e-6)) ~= S
                Y = [Y; datasample(X, 1)];
            end
            %}
            Y = Y + h_cv.*normrnd(0, 1, size(Y));
    
            f_Y = kde(support, Y, h_cv);
            %f_Y = arrayfun(@(X_i) normpdf(support, X_i, h_cv), Y, 'UniformOutput', false);
            %f_Y = mean(cat(1, f_Y{:}), 1);

            [t_b, ~, ~, prmns] = findpeaks(f_Y);
            PD_b = [t_b - prmns; t_b]';
    
            T(b) = bottleneckdist(PD_b, PD);
        end

        T_al(m) = quantile(T, 1 - al);
    end
    close(fw);

    %%
    coverage = mean(min(prmns_f) < T_al);

    figure;
    subplot(2, 1, 1)
    plot(support_X, f);
    subplot(2, 1, 2);
    plot(1:M, sort(T_al, 'ascend'));
    hold on
    plot([1, M], min(prmns_f).*[1, 1]);
    hold off
    title(num2str(coverage, '%3.3f'));
end