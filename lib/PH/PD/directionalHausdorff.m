function d = directionalHausdorff(A, B, numnorm)
    if nargin < 3
        numnorm = 2;
    end
    
    d = max(arrayfun(@(a) min(vecnorm(B - a, numnorm, 2)), A));
end