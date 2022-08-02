function f = betakernel(x, X, h)
    %% Arguments
    % x: evaluation point
    % X: data
    % h: bandwidth
    
    %%
    x = x(:);
    X = X(:);

    %%
    f = arrayfun(@(x_i) mean(kernelfun(x_i, X, h)), x);
end

function f = kernelfun(x, X, b)
    kernelfun = @(x, p, q) betapdf(x, p, q);
    rho = @(x, b) 2*b^2 + 2.5 - sqrt(4*b^4 + 6*b^2 + 2.25 - x^2 - x/b);

    if (2*b <= x) && (x <= (1 - 2*b))
        f = kernelfun(X, x/b, (1 - x)/b);
    elseif (0 <= x) && (x < 2*b)
        f = kernelfun(X, rho(x, b), (1 - x)/b);
    elseif (1 - 2*b) < x && (x <= 1)
        f = kernelfun(X, x/b, rho(1 - x, b));
    end
end

%{
support = linspace(1e-8, 1 - 1e-8, 512)';
f = betapdf(support, 3, 2);

X = betarnd(3, 2, [67, 1]);
h = 0.08;
f_X = betakernel(support, X, h);

C = trapz(support, f_X);

figure(1);
plot(support, f);
hold on
scatter(support, f_X, 'Marker', '.');
scatter(X, zeros(numel(X), 1), 'Marker', '|');
hold off
title(['Area = ', num2str(C, '%3.3f')]);
%}