function y = meanshift(X, y, eps, h, kernelfun)
    if nargin < 5
        kernelfun = @(u) 1/sqrt(2*pi) .* exp(-0.5.*u.^2);
    end

    d = Inf;

    while eps < d
        D = (y - X)./h;
        c = kernelfun(D);
        m = sum(bsxfun(@times, c, X), 1)./sum(c, 1);
        
        d = norm(y - m, 2);

        y = m;
    end
end