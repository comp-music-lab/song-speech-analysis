 function [reject, pval] = equivtest(X, Dlt, al)
    %%
    mu_X = mean(X);
    sgm_X = std(X, 0);
    n = numel(X);

    %%
    dlt = sqrt(n)*Dlt;
    fun = @(C) normcdf((C - dlt)/sgm_X) - normcdf((-C - dlt)/sgm_X) - al;
    C = fzero(fun, 0);
    
    T = sqrt(n)*abs(mu_X);

    if T < C
        reject = 1;
    else
        reject = 0;
    end

    fun = @(al) fzero(@(C) normcdf((C - dlt)/sgm_X) - normcdf((-C - dlt)/sgm_X) - al, 0) - T;
    pval = fzero(fun, [0, 1 - eps]);
end

%% Test code - null hypothesis
%{
mu = normrnd(0, 3);
sgm = gamrnd(2, 0.4);
center = 0;
Dlt = mu;

n = [8, 16, 24, 32, 40, 48, 64, 80, 96, 128, 256];
hitrate = zeros(numel(n), 1);

M = 4096;
reject = zeros(M, 1);
al = 0.05;

for k=1:numel(n)
    parfor m=1:M
        X = normrnd(mu, sgm, [n(k), 1]);
        reject(m) = equivtest(X - center, Dlt, al)
    end

    hitrate(k) = mean(reject);
    fprintf('N(mu = %3.3f, sgm = %3.3f, N = %d): %3.4f\n', mu, sgm, n(k), hitrate(k));
end
%}

%% Test code - Power
%{
mu = normrnd(0, 3);
sgm = gamrnd(2, 0.4);
n = 64;
al = 0.05;
Dlt = 2.5;

dlt = sqrt(n)*Dlt;
fun = @(C) normcdf((C - dlt)/sgm) - normcdf((-C - dlt)/sgm) - al;
C = fzero(fun, 0);
be = normcdf((C - sqrt(n)*mu)/sgm) - normcdf((-C - sqrt(n)*mu)/sgm);

M = 8192*2;
reject = zeros(M, 1);
parfor m=1:M
    X = normrnd(mu, sgm, [n, 1]);
    reject(m) = equivtest(X, Dlt, al);
end

disp([mean(reject), be]);
%}

%% Test code - p-value
%{
mu = normrnd(0, 3);
sgm = gamrnd(2, 0.4);
n = poissrnd(64);
al = rand*0.1;
Dlt = 3;

M = 8192;
reject = zeros(M, 1);
pval = zeros(M, 1);
parfor m=1:M
    X = normrnd(mu, sgm, [n, 1]);
    reject(m) = equivtest(X, Dlt, al);
    
    mu_X = mean(X);
    sgm_X = std(X, 0);
    dlt = sqrt(n)*Dlt;
    
    T = sqrt(n)*abs(mu_X);
    fun = @(al) fzero(@(C) normcdf((C - dlt)/sgm_X) - normcdf((-C - dlt)/sgm_X) - al, 0) - T;
    pval(m) = fzero(fun, [0, 1 - eps]);
end

disp(all(reject == (pval < al)));
%}