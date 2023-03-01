function [reject, pval] = equivtest_meta(X, sgm, support, Dlt, al, center)
    %%
    K = numel(sgm);
    sgm2 = sgm.^2;
    V = sum(sgm2.^-1) - sum(sgm2.^-2)/sum(sgm2.^-1);
    mu_F = sum(sgm2.^(-1).*X)/sum(sgm2.^(-1));
    tau2_DL = max((sum(sgm2.^(-1).*(X - mu_F).^2) - (K - 1))/V, 0);

    [~, ~, mu_X] = exactCI(support, X, sgm, al, 0);
    sgm_X = sqrt(mean(tau2_DL + sgm2));
    n = numel(X);
    
    mu_X = mu_X - center;

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