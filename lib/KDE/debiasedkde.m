function f = debiasedkde(x, X, h)
    %% Reference
    % Cheng, G. & Chen, Y.-C. (2019). Nonparametric inference via bootstrapping the debiased estimator. Electronic Journal of Statistics, 13, 2194-2256.
    
    %% Assumptions behind the implementation
    % The Gaussian function is used for a kernel function.
    
    %%
    kernelfun = @(u) 1/sqrt(2*pi) .* exp(-0.5.*u.^2);
    kernelfun_2d = @(u) 1/sqrt(2*pi) .* (-1 + u.^2) .* exp(-0.5.*u.^2);
    M = @(u) kernelfun(u) - 0.5.*kernelfun_2d(u);

    %%
    c = lincount(x, X);
    c = c(:)';
    
    %%
    n = numel(X);
    I = floor(numel(x)/2) + 1;
    z = (x - x(I))./h;
    f = fftshift(ifft(fft(c).*fft(M(z)))) ./ (n*h);
end