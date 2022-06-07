function [H, D] = energydist(X, Y)
    %%
    n = size(X, 1);
    m = size(Y, 1);
    p = 2;

    %%
    d_X = 0;
    for i=1:(n - 1)
        d_X = d_X + sum(vecnorm(bsxfun(@minus, X(i, :), X((i + 1):n, :)), p, 2))*2;
    end
    d_X = d_X/(n^2);
    
    %%
    d_Y = 0;
    for i=1:(m - 1)
        d_Y = d_Y + sum(vecnorm(bsxfun(@minus, Y(i, :), Y((i + 1):m, :)), p, 2))*2;
    end
    d_Y = d_Y/(m^2);
    

    %%
    d_XY = 0;
    for i=1:n
        d_XY = d_XY + sum(vecnorm(bsxfun(@minus, X(i, :), Y(:, :)), p, 2));
    end
    d_XY = d_XY/(n*m);

    %%
    D = 2*d_XY - d_X - d_Y;
    H = (2*d_XY - d_X - d_Y)/(2*d_XY);
end