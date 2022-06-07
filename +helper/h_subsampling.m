function Y = h_subsampling(X, M)
    N = numel(X);
    Y = cell(N, 1);

    for i=1:N
        if 2 <= numel(X{i})/M
            A = sort(X{i});
            idx = round(linspace(1, numel(A), M));
            Y{i} = A(idx);
        else
            Y{i} = X{i};
        end
    end
end