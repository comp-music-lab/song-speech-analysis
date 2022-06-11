function dx = cwtdiff(x, a, fs, order)
    %%
    padding = false;
    dt = 1/fs;

    if order == 1
        h = @(x) 1./sqrt(2*pi) .* (-x.*exp(-x.^2./2));
    elseif order == 2
        h = @(x) -1./sqrt(2*pi) .* ((x.^2 - 1).*exp(-x.^2./2));
    end
    
    t_h = (-(6*a):dt:(6*a))./a;

    kernel = sqrt(dt/a) .* h(t_h);
    L = numel(kernel);
    
    if size(x, 1) < L
        padding = true;
        L_pad = round(L/2);
        x = [zeros(L_pad, 1); x; zeros(L_pad, 1)];
    end

    M = ceil(L/2);
    
    %%
    phi = fliplr([kernel(M:end), zeros(1, size(x, 1) + L), kernel(1:M - 1)]);
    phi = phi(:);
    PHI = conj(fft(phi));

    %%
    dx = x .* 0;
    for i=1:size(x, 2)
        x_i = x(:, i);
        X = fft([x_i(1:L); x_i; flipud(x_i(end - L + 1:end))]);
        dx_i = ifft(X.*PHI);
        dx(:, i) = dx_i(L + 1:end - L);
    end

    dx = dx./(a^1.5).*sqrt(dt);

    %%
    if padding
        dx = dx((L_pad + 1):end - L_pad);
    end
end