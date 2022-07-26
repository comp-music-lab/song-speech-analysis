function d = hausdorffdist(A, B, numnorm)
    if nargin < 3
        numnorm = 2;
    end

    d = max(directionalHausdorff(A, B, numnorm), directionalHausdorff(B, A, numnorm));
end

%{
A = [1, 7];
B = [3, 6];
numnorm = 2;
d = hausdorffdist(A(:), B(:), numnorm);
%}