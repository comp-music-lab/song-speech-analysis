function h_x = kdebandwidth(x, X, kernelfun, maxwid, minwid)
    %%
    if nargin == 4
        minwid = 0;
    end

    %%
    c = lincount(x, X);
    c = c(:)';
    
    %%
    K = 300;
    psi = zeros(K, 1);
    h = minwid + rand(K, 1).*(maxwid - minwid);

    T = @(u, h) kernelfun(u./(sqrt(2)*h))./(sqrt(2)*h) - 2.*kernelfun(u./h)./h; 
    M = numel(x);
    z = x - x';
    
    fw = waitbar(0, 'Wait...');
    for k=1:K
        waitbar(k/K, fw, 'Wait...');
        psi_m = 0;

        parfor m=1:M
            if c(m) > 0
                psi_m = psi_m + c(m)*c*T(z(:, m), h(k));
            end
        end

        psi(k) = psi_m;
    end
    
    N = numel(X);
    LSCV = psi./N^2 + 2/N.*kernelfun(0)./h;
    close(fw);
    
    %%
    [~, idx] = min(LSCV);
    h_x = h(idx);
end