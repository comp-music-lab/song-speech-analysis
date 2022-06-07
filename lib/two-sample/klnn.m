function H = klnn(X, k)
    %% Setting
    [n, d] = size(X);
    const = n*(2*pi)^(d/2);
    p = 2;

    %% Local entropy term
    T = 64;
    if n < (T + 1)
        %lnN = ceil(log(n));
        lnN = n - 4;
    else
        %lnN = max(T, ceil(log(n)));
        lnN = max(T, round(n/2));
    end

    if k > lnN
        k_search = k;
    else
        k_search = lnN;
    end

    H_i = zeros(n, 1);
    
    for i=1:n
        [T, D] = knnsearch(X, X(i, :), 'K', k_search + 1, 'Distance', 'euclidean', 'SortIndices', true);
        rho = D(k + 1);
        X_T = X(T(2:(lnN + 1)), :);

        D = bsxfun(@minus, X_T, X(i, :));
        D_norm = vecnorm(D, p, 2);
        expnt = exp(-(D_norm.^2)/(2*rho^2));
        
        S_0 = sum(expnt);

        S_1 = (1/rho) .* sum(D.*expnt, 1);
        
        DD = 0;
        for j=1:lnN
            DD = DD + D(j, :)'*D(j, :).*expnt(j);
        end
        S_2 = (1/rho^2) * DD;

        Sgm = (S_0.*S_2 - S_1'*S_1)./(S_0^2);

        detSgm = det(Sgm);
        if detSgm < 1e-4
            H_i(i) = 0;
        else
            H_i(i) = log(S_0) - log(const*rho^d*detSgm^0.5) - 0.5*(1/S_0^2)*S_1*inv(Sgm)*S_1';
        end
    end
    
    %% Bias term
    %%{
    B = 0;
    %}
    %{
    m = 512;
    E = exprnd(1, [m, 1]);

    xi = mvnrnd(zeros(d, 1), diag(ones(d, 1)), m);
    xi = bsxfun(@rdivide, xi, vecnorm(xi, 2, 2));
    xi = bsxfun(@times, xi, rand(m, 1).^(1/d));

    C_d = pi^(d/2)/gamma(d/2 + 1);

    E_k = sum(E(1:k));
    E_j = cumsum(E);
    expnt = exp(-0.5.*(E_j.^2)./(E_k.^2));
    
    S_0 = sum(1.*(E_j.^0)./(E_k.^0).*expnt, 1);

    S_1 = sum(xi.*(E_j./E_k).*expnt, 1);

    S_2 = 0;
    for j=1:m
        S_2 = S_2 + (xi(j, :)'*xi(j, :)).*(E_j(j)^2)./(E_k(j)^2).*expnt(j);
    end

    Sgm = (S_0.*S_2 - S_1'*S_1)/S_0^2;
    
    E_lnE_k = psi(k);

    B = E_lnE_k + d/2*log(2*pi) - log(C_d) - log(S_0) + 0.5*log(det(Sgm)) + (0.5*(S_1*inv(Sgm)*S_1')/S_0^2);
    %}

    %% Estimated entropy
    H = -mean(H_i(H_i ~= 0)) - B;
end