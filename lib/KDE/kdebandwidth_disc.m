function h_x = kdebandwidth_disc(x, X, maxbwid)
    %%
    % Assuming the use of Gaussian kernels.
    % Silverman, B. W. (1986). Density Estimation for Statistics and Data Analysis.
    %
    % See Chiu (1991) for the case of using general kernel functions.
    % Chi, S.-T. (1991). The Effect of discretization error on bandwidth selection for kernel density estimation.

    %%
    K = 600;
    minbwid = 0;
    h = minbwid + rand(K, 1).*(maxbwid - minbwid);
    
    %% Step 1 - Create the empirical distribution function
    M = 256;
    a = min(x);
    b = max(x);
    dlt = (b - a)/M;
    t = a + (0:(M - 1)).*dlt;
    xi = zeros(M, 1);
    n = numel(X);

    for k=2:numel(t)
        idx = t(k - 1) <= X & X < t(k);
        xi(k - 1) = xi(k - 1) + sum(t(k) - X(idx));
        xi(k) = xi(k) + sum(X(idx) - t(k - 1));
    end
    xi = xi .* n^(-1) .* dlt^(-2);
    assert(abs(sum(xi) - 1/dlt) < 1e-8, 'Check the empirical distribution function');
    
    %% Step 2 - Get the empirical characteristic function via the inverse Fourier transform
    Y = ifft(xi);
    s = 2.*pi.*(1:(M/2)).*(b - a)^(-1);
    s = s(:);
    P = abs(Y(2:(M/2 + 1))).^2;

    %% Step 3 - Calcuate cross-validation for each bandwidth value
    C = b - a;
    tmp = zeros(K, 1);
    parfor k=1:K
        hs_sq = (h(k).*s).^2;
        tmp(k) = C.*sum((exp(-hs_sq) - 2.*exp(-0.5.*hs_sq)).*P) + n^(-1)*h(k)^(-1)*(2*pi)^(-0.5);
    end

    CV = 2.*tmp - 1;
    
    %%
    [~, idx] = min(CV);
    h_x = h(idx);
end