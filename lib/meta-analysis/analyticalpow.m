function power = analyticalpow(sgm, al, mu_0, mu_null, tausq)
    %%
    Z_al = norminv(1 - al/2);
    dlt = mu_0 - mu_null;
    
    %%
    V_R = 1/sum((sgm.^2 + tausq).^-1);
    power = 1 + normcdf(-Z_al - dlt/sqrt(V_R)) - normcdf(Z_al - dlt/sqrt(V_R));
end

%{
%% Test code 1 ************
K = 6;

mu_0 = normrnd(0, 1);
tau = gamrnd(7, 0.2);
sgm = gamrnd(7, 0.2, [K, 1]);

M = 1024;
X = zeros(K, M);
for k=1:K
    X(k, :) = normrnd(mu_0, sqrt(tau^2 + sgm(k)^2), [1, M]);
end
X = X(:);

sgm_m = mean(sqrt(tau^2 + sgm.^2));

figure(1);
clf; cla;
histogram(X, 64, 'Normalization', 'pdf');
hold on
plot(linspace(-8, 8, 1024), normpdf(linspace(-8, 8, 1024), mu_0, sgm_m));
hold off

%% Test code 2 ************
K = 16;

mu_0 = normrnd(0, 1);
tau = gamrnd(7, 0.2);
sgm = gamrnd(7, 0.2, [K, 1]);

al = 0.05;
mu_null = 0.0;
power_twosided = analyticalpow(sgm, al, mu_0, mu_null, tau^2);
power_onesided = analyticalpow(sgm, al*2, mu_0, mu_null, tau^2);

M = 4096;
T_K = zeros(M, 1);
T_H = zeros(M, 1);

parfor m=1:M
    Y = normrnd(mu_0, sqrt(tau^2 + sgm.^2));
    T_K(m) = sum((Y - mu_null)./(sgm.^2 + tau^2))/sqrt(sum(1./(sgm.^2 + tau^2)));
    T_H(m) = sum((Y - mu_0)./(sgm.^2 + tau^2))/sqrt(sum(1./(sgm.^2 + tau^2)));
end

hitrate_twosided = mean(T_K < norminv(al/2, 0, 1) | T_K > norminv(1 - al/2, 0, 1)) * 100;

if mu_0 < mu_null
    hitrate_onesided = mean(T_K < norminv(al, 0, 1)) * 100;
else
    hitrate_onesided = mean(T_K > norminv(1 - al, 0, 1)) * 100;
end

figure(1);
clf; cla;
histogram(T_K, 'Normalization', 'pdf', 'EdgeColor', 'none');
hold on
histogram(T_H, 'Normalization', 'pdf', 'EdgeColor', 'none');
plot(linspace(-5, 5, 1024), normpdf(linspace(-5, 5, 1024), 0, 1), '-.m');
hold off
title(['\beta = ', num2str(power_twosided*100, '%3.3f'), ', ', num2str(power_onesided*100, '%3.3f'), ', (', num2str(hitrate_twosided, '%3.3f'), ', ', num2str(hitrate_onesided, '%3.3f'), ')']);

%% Test code 3 ************
K = 48;

mu_0 = normcdf(0.4/sqrt(2));
tau = gamrnd(1, 0.2);
sgm = gamrnd(1, 0.2, [K, 1]);

al = 0.05/6;
mu_null = 0.5;
power_onesided = analyticalpow(sgm, al*2, mu_0, mu_null, tau^2);

M = 8192;
T_K = zeros(M, 1);
T_H = zeros(M, 1);

parfor m=1:M
    Y = normrnd(mu_0, sqrt(tau^2 + sgm.^2));
    T_K(m) = sum((Y - mu_null)./(sgm.^2 + tau^2))/sqrt(sum(1./(sgm.^2 + tau^2)));
    T_H(m) = sum((Y - mu_0)./(sgm.^2 + tau^2))/sqrt(sum(1./(sgm.^2 + tau^2)));
end

C = norminv(1 - al, 0, 1);
hitrate_onesided = mean(C < T_K) * 100;
mishit_onesided = mean(C < T_H) * 100;

figure(1);
clf; cla;
histogram(T_K, 'Normalization', 'pdf', 'EdgeColor', 'none');
hold on
histogram(T_H, 'Normalization', 'pdf', 'EdgeColor', 'none');
plot(linspace(-5, 5, 1024), normpdf(linspace(-5, 5, 1024), 0, 1), '-.m');
yl = ylim();
plot([C, C], yl, 'k');
hold off
legend({'T_K', 'T_H'});
title(['\beta = ', num2str(power_onesided*100, '%3.3f'), ' (', num2str(hitrate_onesided, '%3.3f'), ')',...
', \alpha = ', num2str(al*100, '%3.3f'), ' (', num2str(mishit_onesided, '%3.3f') ,')']);
%}