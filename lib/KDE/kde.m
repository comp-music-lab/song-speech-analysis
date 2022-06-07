function f = kde(x, X, h, kernelfun)
    if nargin < 4
        kernelfun = @(u) 1/sqrt(2*pi) .* exp(-0.5.*u.^2);
    end

    %%
    c = lincount(x, X);
    c = c(:)';

    %%
    n = size(X, 1);
    I = floor(numel(x)/2) + 1;
    z = (x - x(I))./h;
    f = fftshift(ifft(fft(c).*fft(kernelfun(z)))) ./ (n*h);

    %%
    f(f < 0) = 0;
end

%{
g = zeros(numel(x), 1);
n = size(X, 1);
for i=1:numel(x)
    g(i) = sum(kernelfun((x(i) - X)./h));
end
g = g./(n*h);
%}