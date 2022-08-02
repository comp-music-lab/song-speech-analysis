function f = boundarykernel(x, X, h)
    %% Arguments
    % x: evaluation point
    % X: data
    % h: bandwidth
    
    %%
    x = x(:);
    X = X(:);

    %%
    kernelfun = @(t, c) 12./(1 + c).^4 .* (1 + t) .* ((1 - 2.*c).*t + (3.*c.^2 - 2.*c + 1)./2) .* (-1 <= t & t <= c);
    %kernelfun = @(t) 3/4.*(1 - t.^2).*(-1 <= t & t <= 1); % Epanechnikov kernel (c = 1)

    c = min(x./h, 1);
    b_c = 2 - c;
    h_c = b_c.*h;

    f = arrayfun(@(X_i) kernelfun((x - X_i)./h_c, c./b_c)./h_c, X, 'UniformOutput', false);
    f = mean(cat(2, f{:}), 2);
end

%{
support = linspace(1e-8, 1 - 1e-8, 512)';
f = betapdf(support, 3, 2);

X = betarnd(3, 2, [70, 1]);
h = 0.18;
f_X = boundarykernel(support, X, h);
f_X(f_X < 0) = 0;

C = trapz(support, f_X);

figure(1);
plot(support, f);
hold on
scatter(support, f_X, 'Marker', '.');
scatter(X, zeros(numel(X), 1), 'Marker', '|');
hold off
title(['Area = ', num2str(C, '%3.3f')]);
%}