function f = kde(x, X, kernelfun, h)
    %%
    c = lincount(x, X);
    c = c(:)';

    %%
    f = c' .* 0;
    M = numel(x);
    z = (x - x')./h;

    parfor i=1:M
        f(i) = c*kernelfun(z(:, i));
    end

    N = numel(X);
    f = f./(N*h);
end