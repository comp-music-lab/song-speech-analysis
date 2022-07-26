function idx = persistentEntropy(L)
    %%
    if numel(L) == 1
        idx = 1;
        return
    end

    L_orig = L;

    %%
    T = max(L);
    r = min(L);
    L = [sort(setdiff(L, [r; T]), 'desc'); r; T];
    
    h_pdent = @(L) -sum(L./sum(L).*log(L./sum(L)));
    h_QE = @(idx, n, T, r) arrayfun(@(i) h_pdent([repmat(T, [i, 1]); repmat(r, [n - i, 1])]), idx);
    
    %%
    n_dash = numel(L);
    L_dash = L;
    L_prev = [];

    while true
        %%
        S_Lj = sum(L_dash);
        m = 0;

        for i=1:(n_dash - 2)
            R_i = L_dash(i + 1:end);
            P_i = sum(R_i);
            l_dash = P_i/exp(h_pdent(R_i));
            S_Li = P_i + i*l_dash;
            C = S_Lj/S_Li;
            m = i;

            if C < 1
                break;
            end

            S_Lj = S_Li;
        end
        
        %%
        E_i = h_QE(0:n_dash, n_dash, T, r);
        [~, Q] = min(E_i);
        Q = Q - 1;

        %%
        if Q < m
            L_dash = [L_dash(1:m); L_dash(end - 1:end)];

            if numel(L_prev) == numel(L_dash) && all(L_prev == L_dash)
                L_dash = [L_dash(1:end - 2); L_dash(end)];
                break;
            end
            L_prev = L_dash;

            n_dash = m + 2;
        else
            L_dash = [L_dash(1:m); L_dash(end)];
            break;
        end
    end

    %%
    idx = arrayfun(@(l) find(L_orig == l, 1, 'first'), L_dash);
end