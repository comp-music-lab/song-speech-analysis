function t = qHausdist(A, B)
    t = max(arrayfun(@(B_i) min(abs(B_i - A)), B));
end