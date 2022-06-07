function f = kde2d(x, X, h)
    %%
    kernelfun = @(u) 1/sqrt(2*pi) .* exp(-0.5.*u.^2);
    hessian = @(x, h) (-h^2 + x.^2)./h^4 .* kernelfun(x./h);

    %%
    c = lincount(x, X);
    c = c(:)';

    %%
    n = size(X, 1);
    I = floor(numel(x)/2) + 1;
    z = x - x(I);
    f = fftshift(ifft(fft(c).*fft(hessian(z, h)))) ./ (n*h);
end