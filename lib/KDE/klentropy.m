function H = klentropy(x, k)
    [n, d] = size(x);
    
    V = pi^(d/2) / gamma(1 + d/2);
    expdg = exp(psi(k));

    % Original: (Leonenko, Pronzato & Savani, 2008; Thomas, Berrett, Samworth & Yuan, 2019)
    %asympt = n - 1;

    % Matching with the expectation (Jiao, Gao & Han, 2018)
    asympt = n;

    const = V*asympt/expdg; 
    
    p = 2;
    H = 0;
    for i=1:n
        val = sort(vecnorm(bsxfun(@minus, x(i, :), x), p, 2), 'asc');
        rho = val(k);
        H = H + log(rho^d * const);
    end

    H = H/n;
end