function [y, h_x] = adaptivemeanshift(X, y, eps, h, kernelfun)
    if nargin < 5
        kernelfun = @(u) 1/sqrt(2*pi) .* exp(-0.5.*u.^2);
    end
    
    %%
    n = numel(X);

    support = linspace(min(X) - h*5, max(X) + h*5, 2048);
    density= arrayfun(@(X_i) normpdf(support, X_i, h), X(:)', 'UniformOutput', false);
    density = mean(cat(1, density{:}), 1);
    
    f_X = zeros(n, 1);
    for i=1:n
        [~, idx] = min(abs(support - X(i)));
        f_X(i) = density(idx);
    end

    %{
    f_X = arrayfun(@(X_i) sum(kernelfun((X - X_i)./h)), X)./3;
    %}

    lmd = mean(log(f_X));
    
    h_x = h.*sqrt(lmd./f_X);
    h_x = h_x(:)';

    %%
    d = Inf;

    while eps < d
        D = rdivide((y - X), h_x);
        c = kernelfun(D);
        m = sum(bsxfun(@times, c, X), 1)./sum(c, 1);
        
        d = norm(y - m, 2);

        y = m;
    end
end

%{
support = linspace(min(X) - h*5, max(X) + h*5, 1024);
density= arrayfun(@(X_i) normpdf(support, X_i, h), X(:)', 'UniformOutput', false);
density = mean(cat(1, density{:}), 1);

figure;
plot(support, density);
hold on;
scatter(y, zeros(numel(y), 1));
hold off;
%}