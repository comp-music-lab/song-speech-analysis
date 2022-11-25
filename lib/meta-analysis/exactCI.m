function CI = exactCI(Y, sgm, mu, q)
    %%
    K = numel(Y);
    
    %%
    L = 2^K;
    V = zeros(L, K);
    parfor l=1:L
        b = dec2bin(l - 1);
        V(l, :) = [zeros(1, K - length(b)), arrayfun(@(x) str2double(x), b)];
    end
    V = 2.*V - 1;

    %%
    parfor i=1:numel(mu)
        tausq_hat = max((sum((Y - mu(i)).^2) - sum(sgm.^2))/K, 0);
        T_null = V * (abs(Y - mu(i))./(sgm.^2 + tausq_hat));
        T_i = sum((Y - mu(i))./(sgm.^2 + tausq_hat));
        
        T_null = sort(T_null);
        idx = find(T_i < T_null, 1, 'first') - 1;
        if isempty(idx)
            idx = L;
        end

        p(i) = idx/L;
    end
    
    %%
    CI = zeros(numel(q), 1);
    for i=1:numel(q)
        [~, idx] = min(abs(p - q(i)));
        CI(i) = mu(idx);
    end
end

%% two-sided
%{
%%
al = 7;
be = 0.2;
K = 5;

mu_0 = normrnd(0, 2);
tau = gamrnd(al, be);
sgm = gamrnd(al, be, [K, 1]);

%%
al = 0.05;
q = [al/2, 1 - al/2];
mu = linspace(-10, 10, 1024);
p = zeros(numel(mu), 1);
M = 512;
CI = zeros(M, 2);

wf = waitbar(0, 'Waiting...');
for m=1:M
    waitbar(m/M, wf, 'Waiting...');
    Y = normrnd(mu_0, sqrt(tau^2 + sgm.^2));
    CI(m, :) = exactCI(Y, sgm, mu, q)';
end
close(wf);

figure(1);
hit = 0;
for m=1:M
    plot([m, m], [CI(m, 1), CI(m, 2)], 'Color', 'k');
    hold on

    if CI(m, 2) < mu_0 && mu_0 < CI(m, 1)
        hit= hit + 1;
    end
end
plot([1, M], mu_0.*[1, 1], '-.m');
hold off
hit = hit/M * 100;
title([num2str(hit, '%3.4f'), '%']);
%}

%% one-sided
%{
%%
al = 7;
be = 0.2;
K = 13;

mu_0 = normrnd(0, 2);
tau = gamrnd(al, be);
sgm = gamrnd(al, be, [K, 1]);

%%
al = 0.05;
q = al;
mu = linspace(-10, 10, 1024);
p = zeros(numel(mu), 1);
M = 512;
CI = zeros(M, 1);

wf = waitbar(0, 'Waiting...');
for m=1:M
    waitbar(m/M, wf, 'Waiting...');
    Y = normrnd(mu_0, sqrt(tau^2 + sgm.^2));
    CI(m, :) = exactCI(Y, sgm, mu, q)';
end
close(wf);

figure(1);
clf; cla;
plot(1:M, CI, 'Color', 'k');
hold on
plot([1, M], mu_0.*[1, 1], '-.m');
hold off
hit = mean(CI > mu_0) * 100;
title([num2str(hit, '%3.4f'), '%']);
%}