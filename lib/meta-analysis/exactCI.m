function [CI, pval, mu_hat] = exactCI(mu, Y, sgm, al, mu_null)
    %%
    mu = mu(:)';
    Y = Y(:);
    sgm = sgm(:);

    %% CI
    V = h_V(numel(Y));

    sgmsqhat = h_sgmhat(mu, Y, sgm);
    T = h_T(mu, Y, sgmsqhat);
    T_null = h_T_nul(V, sgmsqhat);
    c = h_c(T_null, al);
    CI = h_CI(T, c, mu);
    
    %% mu
    p = zeros(numel(mu), 1);
    parfor i=1:numel(mu)
        p(i) = find(T(i) > sort(T_null(:, i)), 1, 'last')/size(T_null, 1);
    end
    [~, idx] = min(abs(p - 0.5));
    mu_hat = mu(idx);

    %% p-value
    sgmsqhat = h_sgmhat(mu_null, Y, sgm);
    T = h_T(mu_null, Y, sgmsqhat);
    T_null = h_T_nul(V, sgmsqhat);
    pval = find(T > sort(T_null), 1, 'last')/numel(T_null);
    if isempty(pval)
        pval = 0;
    end
end

function sgmsqhat = h_sgmhat(mu, Y, sgm)
    K = numel(Y);
    sgmsqhat = sum((Y - mu).^2 - sgm.^2, 1)./K;
    sgmsqhat(sgmsqhat < 0) = 0;
    sgmsqhat = sgm.^2 + sgmsqhat;
end

function V = h_V(K)
    if K <= 13
        L = 2^K;
        V = zeros(L, K);

        b = dec2bin(0:(L - 1));

        parfor l=1:L
            V(l, :) = arrayfun(@str2double, b(l, :));
        end
    else
        L = 12000;
        V = binornd(1, 0.5, [L, K]);
    end

    V(V == 0) = -1;
end

function T_null = h_T_nul(V, sgmsqhat)
    U = 1./sqrt(sgmsqhat);
    T_null = V*U;
end

function c = h_c(T, al)
    c = zeros(2, size(T, 2));

    parfor i=1:size(T, 2)
        c(:, i) = [quantile(T(:, i), al/2), quantile(T(:, i), 1 - al/2)];
    end
end

function T = h_T(mu, Y, sgmhat)
    T = sum(sign(Y - mu)./sqrt(sgmhat), 1);
end

function CI = h_CI(T, c, mu)
    idx = find(T < c(2, :), 1, 'first');
    CI_l = mu(idx);

    idx = find(T > c(1, :), 1, 'last');
    CI_u = mu(idx);
    
    CI = [CI_l, CI_u];
end

%% Test code
%{
K = 11;
mu_0 = normrnd(0, 4);
sgm = gamrnd(0.9, 1.5, [K, 1]);
tau = gamrnd(0.9, 1.5);

M = 2048;
Y = zeros(K, M);
for m=1:M
    Y(:, m) = normrnd(mu_0, sqrt(tau^2 + sgm.^2));
end
writetable(table(Y, sgm, mu_0.*ones(K, 1)), './testdata.csv');

CI = zeros(2, M);
pval = zeros(1, M);
mu_hat = zeros(1, M);
al = 0.05;
mu_null = 0;

wf = waitbar(0, 'Simulating...');
for m=1:M
    waitbar(m/M, wf, 'Simulating...');
    mu = linspace(min(Y(:, m)), max(Y(:, m)), 512);
    [CI(:, m), pval(m), mu_hat(m)] = exactCI(mu, Y(:, m), sgm, al, mu_null);
end
close(wf);

hitrate = 100*mean(CI(1, :) <= mu_0 & mu_0 <= CI(2, :));
hitrate_onesided = 100*mean(pval < al);
hitrate_twosided = 100*mean(pval < al/2 | (1 - al/2) < pval);

figure(1);
clf ;cla;

subplot(2, 2, 1);
plot(CI(1, :));
hold on
plot(CI(2, :));
plot([1, M], [mu_0, mu_0], '-.m');
hold off
title(num2str(hitrate, '%3.4f'));
axis tight

CIlength = CI(2, :) - CI(1, :);
subplot(2, 2, 2);
plot(CIlength);
hold on
plot([1, M], mean(CIlength).*[1, 1], '-.m');
hold off
axis tight

subplot(2, 2, 3);
plot(sort(pval));
hold on
plot([1, M], [0, 1], '-.m');
hold off
title(['one-sided: ', num2str(hitrate_onesided, '%3.4f'), ', two-sided: ', num2str(hitrate_twosided, '%3.4f')]);
axis tight

subplot(2, 2, 4);
histogram(mu_hat, 32, 'Normalization', 'pdf');
hold on
yl = ylim();
plot(mu_0.*[1, 1], yl, '-.m');
hold off
%}