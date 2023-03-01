function [n, power] = equivtestpow(mu, sgm, al, be, Dlt)
    %% Sample size estimation
    power = -Inf;
    n = 0;

    while power < be
        n = n + 1;

        fun = @(C) normcdf((C - Dlt*sqrt(n))/sgm) - normcdf((-C - Dlt*sqrt(n))/sgm) - al;
        C = fzero(fun, 0);

        power = normcdf((C - mu*sqrt(n))./sgm) - normcdf((-C - mu*sqrt(n))./sgm);
    end
end