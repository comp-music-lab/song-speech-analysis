function power = analyticalpow(sgm, al, mu_0, mu_null, tausq)
    %%
    Z_al = norminv(1 - al/2);
    dlt = mu_0 - mu_null;
    
    %%
    V_R = 1/sum((sgm.^2 + tausq).^-1);
    power = 1 + normcdf(-Z_al - dlt/sqrt(V_R)) - normcdf(Z_al - dlt/sqrt(V_R));
end

%{
%%
al = 7;
be = 0.2;
K = 12;

mu_0 = normrnd(0, 2);
tau = gamrnd(al, be);
sgm = gamrnd(al, be, [K, 1]);

%%
al = 0.05;
mu_null = 0;
power = analyticalpow(sgm, al, mu_0, mu_null, tau^2);

%%
M = 4096;
T_H0 = zeros(M, 1);
T_H1 = zeros(M, 1);
tausq_hat_sim = zeros(M, 1);

for m=1:M
    Y = normrnd(mu_0, sqrt(tau^2 + sgm.^2));
    
    mu_F = sum(sgm.^-2 .* Y)/sum(sgm.^-2);
    tausq_hat = max((sum(sgm.^-2 .* (Y - mu_F).^2) - (K - 1))/(sum(sgm.^-2) - sum(sgm.^-4)/sum(sgm.^-2)), 0);

    T_H0(m) = sum((Y - mu_null)./(sgm.^2 + tausq_hat))/sqrt(sum(1./(sgm.^2 + tausq_hat)));
    T_H1(m) = sum((Y - mu_0)./(sgm.^2 + tausq_hat))/sqrt(sum(1./(sgm.^2 + tausq_hat)));

    tausq_hat_sim(m) = tausq_hat;
end

c_al = quantile(T_H0, [al/2, 1 - al/2]);
if mu_null > mu_0
    power_sim = sum(T_H1 > max(c_al))/numel(T_H1);
else
    power_sim = sum(T_H1 < min(c_al))/numel(T_H1);
end

figure(1);
subplot(1, 2, 1);
histogram(T_H0, 'Normalization', 'pdf');
hold on
histogram(T_H1, 'Normalization', 'pdf');
hold off
title(['Power: ', num2str(power, '%3.4f'), ', ', num2str(power_sim, '%3.4f')]);

subplot(1, 2, 2);
histogram(tausq_hat_sim, 'Normalization', 'pdf');
hold on
yl = ylim();
plot(tau^2.*[1, 1], yl, '-.m');
tausq_hat_sim = sort(tausq_hat_sim);
idx = find(tau^2 > tausq_hat_sim, 1, 'last');
title([num2str(idx/numel(tausq_hat_sim)*100, '%3.4f'), '%']);
hold off
%}