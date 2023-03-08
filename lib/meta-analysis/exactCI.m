function [CI, pval, mu_hat] = exactCI(Y, sgm, al, mu_null)
    %%
    L = 15;
    K = numel(Y);
    if K <= L
        L = 2^K;
        V = dec2bin(0:(L - 1))' - '0';
    else
        V = binornd(1, 0.5, [K, 2^L]);
    end

    mu_min = min(Y);
    mu_max = max(Y);

    %% CI
    mu_u = fzero(@(mu) h_upperp(mu, Y, sgm, V, al) - 0.5, [mu_min, mu_max]);
    mu_l = fzero(@(mu) h_lowerp(mu, Y, sgm, V, al) - 0.5, [mu_min, mu_max]);
    CI = [mu_l, mu_u];

    %% mu
    mu_hat = fzero(@(mu) h_upperp(mu, Y, sgm, V, 1) - 0.5, [mu_min, mu_max]);

    %% p-value
    p_ul = h_upperp(mu_null, Y, sgm, V, 0);
    p_uu = h_upperp(mu_null, Y, sgm, V, 1);
    p_ll = h_lowerp(mu_null, Y, sgm, V, 0);
    p_lu = h_lowerp(mu_null, Y, sgm, V, 1);

    if p_ul ~= p_uu
        pval = fzero(@(p) h_upperp(mu_null, Y, sgm, V, p) - 0.5, [0, 1]);
    elseif p_ll ~= p_lu
        pval = fzero(@(p) h_lowerp(mu_null, Y, sgm, V, p) - 0.5, [0, 1]);
    elseif (p_ul == p_uu) && (p_ll == p_lu)
        pval = 0;
    end
end

function s = h_upperp(mu, Y, sgm, V, al)
    [T_mu, T_null] = h_stat(mu, Y, sgm, V);
    c = quantile(T_null, al/2);
    s = c < T_mu;
end

function s = h_lowerp(mu, Y, sgm, V, al)
    [T_mu, T_null] = h_stat(mu, Y, sgm, V);
    c = quantile(T_null, 1 - al/2);
    s = T_mu < c;
end

function [T_mu, T_null] = h_stat(mu, Y, sgm, V)
    sgm_musq = sgm.^2 + max(0, mean((Y - mu).^2 - sgm.^2));
    w = sign(Y - mu)./sqrt(sgm_musq);
    T_mu = sum(w);
    T_null = w'*V;
end

%% Test code
%{
al = 0.05/6;
mu_null = 0;
K = 15;

mu_0 = normrnd(0, 1);
sgm = gamrnd(0.8, 1.0, [K, 1]);
tau_0 = gamrnd(0.8, 1.0);

%%
M = 2048;
CI = zeros(M, 2);
mu_hat = zeros(M, 1);
pval = zeros(M, 1);

X = zeros(K, M);
parfor m=1:M
    X(:, m) = normrnd(mu_0, sqrt(tau_0^2 + sgm.^2));
end

tic;
parfor m=1:M
    Y = X(:, m);
    [CI(m, :), pval(m), mu_hat(m)] = exactCI(Y, sgm, al, mu_null)
end
toc;

%%
figure(1);
clf; cla;
hitrate = mean(CI(:, 1) < mu_0 & mu_0 < CI(:, 2));
plot(CI(:, 1));
hold on
plot(CI(:, 2));
plot([1, M], mu_0.*[1, 1], '-.m');
hold off
title(['alpha level = ', num2str(hitrate*100, '%3.4f')]);

figure(2);
clf; cla;
histogram(mu_hat);
hold on
yl = ylim();
plot(mu_0.*[1, 1], yl, '-.m');
hold off

figure(3);
clf; cla;
histogram(pval);
A = pval > al;
B = CI(:, 1) < mu_null & mu_null < CI(:, 2);
disp([mean(A), mean(B), all(A == B)]);
%}