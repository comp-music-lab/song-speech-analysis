function d = hausdorffdist(A, B, numnorm)
    if nargin < 3
        numnorm = 2;
    end

    d = max(directionalHausdorff(A, B, numnorm), directionalHausdorff(B, A, numnorm));
end

function d = directionalHausdorff(A, B, numnorm)
    d = max(arrayfun(@(a) min(vecnorm(B - a, numnorm, 2)), A));
end

%{
A = [1, 7];
B = [3, 6];
numnorm = 2;
d = hausdorffdist(A(:), B(:), numnorm);
%}