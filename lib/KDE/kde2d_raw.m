function f = kde2d_raw(x, X, h)
    %%
    kernelfun = @(u) 1/sqrt(2*pi) .* exp(-0.5.*u.^2);
    hessian = @(x, h) (-h^2 + x.^2)./h^4 .* kernelfun(x./h);

    %%
    f = zeros(numel(x), 1);
    n = size(X, 1);
    for i=1:numel(x)
        f(i) = sum(hessian(x(i) - X, h));
    end

    f = f./(n*h);
end