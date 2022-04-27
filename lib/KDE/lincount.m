function c = lincount(x, X)
    %%
    c = zeros(numel(x), 1);
    d = x(2) - x(1);

    %%
    for i=1:numel(X)
        idx_l = find(x <= X(i), 1, 'last');
        idx_r = find(X(i) <= x, 1, 'first');
        c(idx_l) = c(idx_l) + (x(idx_r) - X(i))/d;
        c(idx_r) = c(idx_r) + (X(i) - x(idx_l))/d;
    end
end