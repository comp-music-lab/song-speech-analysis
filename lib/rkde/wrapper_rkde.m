function f_hm = wrapper_rkde(X, support, h)
    %%
    if nargin < 3
        %b_type: bandwidth type: 1 -> lscv, 2 -> lkcv, 3 -> jakkola heuristic,
        b_type = 1;
        h = bandwidth_select(X, b_type);
    end

    %%
    d = 1;
    support = support(:);
    n = numel(X);
    m = length(support);
    
    type = 1;
    w_hm = robkde(X, h, type);

    %%
    Y = (ones(m, 1)*X' - support*ones(1, n)).^2;
    pd = gauss_kern(Y, h, d);
    f_hm = pd*w_hm;
end